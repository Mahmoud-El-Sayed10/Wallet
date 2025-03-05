<?php
$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/Wallet.php';
require_once '../../Models/Transaction.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

session_start();
$response = ['success' => false, 'message' => 'Unauthorized'];
if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode($response);
    exit;
}

$user_id = $_SESSION['user_id'];
$data = json_decode(file_get_contents('php://input'), true);

// Check required fields
if (!isset($data['source_wallet_id']) || !isset($data['target_wallet_id']) || !isset($data['amount'])) {
    $response['message'] = 'Missing required fields';
    echo json_encode($response);
    exit;
}

$source_wallet_id = $data['source_wallet_id'];
$target_wallet_id = $data['target_wallet_id'];
$amount = floatval($data['amount']);
$description = isset($data['description']) ? $data['description'] : 'Wallet Transfer';

// Validate amount
if ($amount <= 0) {
    $response['message'] = 'Invalid amount';
    echo json_encode($response);
    exit;
}

try {
    $wallet = new Wallet($db);
    $transaction = new Transaction($db);
    
    // Start transaction
    $db->begin_transaction();
    $inTransaction = true;

    // Get source wallet to validate ownership and check balance
    $sourceWallets = $wallet->read($user_id);
    $sourceWalletFound = false;
    $sourceWallet = null;
    
    foreach ($sourceWallets as $w) {
        if ($w['wallet_id'] == $source_wallet_id) {
            $sourceWalletFound = true;
            $sourceWallet = $w;
            break;
        }
    }
    
    if (!$sourceWalletFound) {
        $db->rollback();
        $response['message'] = 'Source wallet not found or does not belong to user';
        echo json_encode($response);
        exit;
    }
    
    // Get target wallet
    $stmt = $db->prepare("SELECT * FROM wallets WHERE wallet_id = ?");
    $stmt->bind_param("i", $target_wallet_id);
    $stmt->execute();
    $targetWallet = $stmt->get_result()->fetch_assoc();
    $stmt->close();
    
    if (!$targetWallet) {
        $db->rollback();
        $response['message'] = 'Target wallet not found';
        echo json_encode($response);
        exit;
    }
    
    // Check if source wallet has enough balance
    if ($sourceWallet['balance'] < $amount) {
        $db->rollback();
        $response['message'] = 'Insufficient balance';
        echo json_encode($response);
        exit;
    }
    
    // Apply exchange rate if currencies are different
    $exchange_fee = 0;
    $exchange_rate = 1.0;
    $sourceCurrency = $sourceWallet['currency_code'];
    $targetCurrency = $targetWallet['currency_code'];
    
    if ($sourceCurrency != $targetCurrency) {
        // Apply fixed fee for currency conversion (e.g., 2%)
        $exchange_fee = $amount * 0.02;
    }
    
    // Calculate amount after exchange rate and fees
    $target_amount = ($amount - $exchange_fee) * $exchange_rate;
    
    // Update source wallet balance
    $new_source_balance = $sourceWallet['balance'] - $amount;
    $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE wallet_id = ?");
    $stmt->bind_param("di", $new_source_balance, $source_wallet_id);
    
    if (!$stmt->execute()) {
        $db->rollback();
        $response['message'] = 'Failed to update source wallet balance';
        echo json_encode($response);
        exit;
    }
    $stmt->close();
    
    // Update target wallet balance
    $new_target_balance = $targetWallet['balance'] + $target_amount;
    $stmt = $db->prepare("UPDATE wallets SET balance = ? WHERE wallet_id = ?");
    $stmt->bind_param("di", $new_target_balance, $target_wallet_id);
    
    if (!$stmt->execute()) {
        $db->rollback();
        $response['message'] = 'Failed to update target wallet balance';
        echo json_encode($response);
        exit;
    }
    $stmt->close();
    
    // Generate transaction IDs
    $outgoing_transaction_id = $transaction->generateTransactionId();
    $incoming_transaction_id = $transaction->generateTransactionId();
    
    // Insert transactions directly with minimal fields
    $query = "INSERT INTO transactions (transaction_id, wallet_id, transaction_type, amount, currency_code, fee, status, recipient_wallet_id, description) VALUES (?, ?, 'TRANSFER_SENT', ?, ?, ?, 'COMPLETED', ?, ?)";
    $stmt = $db->prepare($query);
    
    // For bind_param, we need to use references for all variables
    $outTxnId = $outgoing_transaction_id;
    $sourceWalletId = $source_wallet_id;
    $amountValue = $amount;
    $sourceCurrencyValue = $sourceCurrency;
    $exchangeFeeValue = $exchange_fee;
    $targetWalletId = $target_wallet_id;
    $descriptionValue = $description;
    
    $stmt->bind_param("siddids", 
        $outTxnId, 
        $sourceWalletId, 
        $amountValue, 
        $sourceCurrencyValue, 
        $exchangeFeeValue, 
        $targetWalletId, 
        $descriptionValue
    );
    
    if (!$stmt->execute()) {
        $error = $db->error;
        $db->rollback();
        $response['message'] = 'Failed to create outgoing transaction: ' . $error;
        echo json_encode($response);
        exit;
    }
    $stmt->close();
    
    // Insert incoming transaction
    $query = "INSERT INTO transactions (transaction_id, wallet_id, transaction_type, amount, currency_code, fee, status, recipient_wallet_id, description) VALUES (?, ?, 'TRANSFER_RECEIVED', ?, ?, 0, 'COMPLETED', ?, ?)";
    $stmt = $db->prepare($query);
    
    // For bind_param, we need to use references for all variables
    $inTxnId = $incoming_transaction_id;
    $targetWalletIdParam = $target_wallet_id;
    $targetAmountValue = $target_amount;
    $targetCurrencyValue = $targetCurrency;
    $sourceWalletIdParam = $source_wallet_id;
    $descriptionParam = $description;
    
    $stmt->bind_param("siddis", 
        $inTxnId, 
        $targetWalletIdParam, 
        $targetAmountValue, 
        $targetCurrencyValue, 
        $sourceWalletIdParam, 
        $descriptionParam
    );
    
    if (!$stmt->execute()) {
        $error = $db->error;
        $db->rollback();
        $response['message'] = 'Failed to create incoming transaction: ' . $error;
        echo json_encode($response);
        exit;
    }
    $stmt->close();
    
    // Record timestamps
    $stmt = $db->prepare("INSERT INTO timestamps (entity_type, entity_id) VALUES ('TRANSACTION', ?)");
    $outTxnIdTs = $outgoing_transaction_id;
    $stmt->bind_param("s", $outTxnIdTs);
    $stmt->execute();
    $stmt->close();
    
    $stmt = $db->prepare("INSERT INTO timestamps (entity_type, entity_id) VALUES ('TRANSACTION', ?)");
    $inTxnIdTs = $incoming_transaction_id;
    $stmt->bind_param("s", $inTxnIdTs);
    $stmt->execute();
    $stmt->close();
    
    // Commit transaction
    $db->commit();
    $inTransaction = false;
    
    // Prepare response with detailed information
    $response['success'] = true;
    $response['message'] = 'Transfer completed successfully';
    $response['data'] = [
        'transaction_id' => $outgoing_transaction_id,
        'amount_sent' => $amount,
        'currency_sent' => $sourceCurrency,
        'amount_received' => $target_amount,
        'currency_received' => $targetCurrency,
        'exchange_rate' => $exchange_rate,
        'exchange_fee' => $exchange_fee,
        'new_source_balance' => $new_source_balance,
        'new_target_balance' => $new_target_balance
    ];
    
    echo json_encode($response);
    
} catch (Exception $e) {
    // Rollback transaction in case of error
    if (isset($inTransaction) && $inTransaction) {
        $db->rollback();
    }
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>