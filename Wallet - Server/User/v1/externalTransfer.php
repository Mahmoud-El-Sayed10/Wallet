<?php
$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/Wallet.php';
require_once '../../Models/Transaction.php';

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
if (!isset($data['source_wallet_id']) || !isset($data['recipient_name']) || 
    !isset($data['account_number']) || !isset($data['bank_name']) || !isset($data['amount'])) {
    $response['message'] = 'Missing required fields';
    echo json_encode($response);
    exit;
}

$source_wallet_id = $data['source_wallet_id'];
$recipient_name = $data['recipient_name'];
$account_number = $data['account_number'];
$bank_name = $data['bank_name'];
$amount = $data['amount'];
$description = isset($data['description']) ? $data['description'] : 'External Transfer';

// Validate amount
if (!is_numeric($amount) || $amount <= 0) {
    $response['message'] = 'Invalid amount';
    echo json_encode($response);
    exit;
}

try {
    $wallet = new Wallet($db);
    $transaction = new Transaction($db);
    
    // Start transaction
    $db->begin_transaction();
    
    // Get wallet to validate ownership and check balance
    $wallets = $wallet->read($user_id);
    $sourceWalletFound = false;
    $sourceWallet = null;
    
    foreach ($wallets as $w) {
        if ($w['wallet_id'] == $source_wallet_id) {
            $sourceWalletFound = true;
            $sourceWallet = $w;
            break;
        }
    }
    
    if (!$sourceWalletFound) {
        $db->rollback();
        $response['message'] = 'Wallet not found or does not belong to user';
        echo json_encode($response);
        exit;
    }
    
    // Check if source wallet has enough balance
    if ($sourceWallet['balance'] < $amount) {
        $db->rollback();
        $response['message'] = 'Insufficient balance in wallet';
        echo json_encode($response);
        exit;
    }
    
    // Create external transfer transaction
    $transaction_id = $transaction->create(
        $source_wallet_id,
        'EXTERNAL_TRANSFER',
        $amount,
        $sourceWallet['currency_code']
    );
    
    if (!$transaction_id) {
        $db->rollback();
        $response['message'] = 'Failed to create transaction';
        echo json_encode($response);
        exit;
    }
    
    // Store external transfer details in a separate table
    $stmt = $db->prepare(
        "INSERT INTO external_transfers (transaction_id, recipient_name, account_number, bank_name, description) 
         VALUES (?, ?, ?, ?, ?)"
    );
    $stmt->bind_param("sssss", $transaction_id, $recipient_name, $account_number, $bank_name, $description);
    
    if (!$stmt->execute()) {
        $db->rollback();
        $response['message'] = 'Failed to record external transfer details';
        echo json_encode($response);
        exit;
    }
    
    // Update source wallet balance
    $new_source_balance = $sourceWallet['balance'] - $amount;
    if (!$wallet->update($source_wallet_id, $new_source_balance)) {
        $db->rollback();
        $response['message'] = 'Failed to update wallet balance';
        echo json_encode($response);
        exit;
    }
    
    // Update transaction status to pending (external transfers need verification)
    $transaction->update($transaction_id, ['status' => 'PENDING']);
    
    // Record timestamp
    $stmt = $db->prepare("INSERT INTO timestamps (entity_type, entity_id) VALUES ('TRANSACTION', ?)");
    $stmt->bind_param("s", $transaction_id);
    $stmt->execute();
    
    // Commit transaction
    $db->commit();
    
    $response['success'] = true;
    $response['message'] = 'External transfer initiated successfully';
    $response['transaction_id'] = $transaction_id;
    
    echo json_encode($response);
} catch (Exception $e) {
    $db->rollback();
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>