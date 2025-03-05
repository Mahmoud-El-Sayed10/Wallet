<?php
// verifyTransaction.php
$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/QRCode.php';
require_once '../../Models/Transaction.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

// Check required fields
if (!isset($data['verification_code'])) {
    $response = ['success' => false, 'message' => 'Missing verification code'];
    echo json_encode($response);
    exit;
}

$verification_code = $data['verification_code'];

try {
    $qrCode = new QRCode($db);
    $transaction = new Transaction($db);
    
    // Verify the code
    $qrData = $qrCode->verify($verification_code);
    
    if (!$qrData) {
        $response = ['success' => false, 'message' => 'Invalid or expired verification code'];
        echo json_encode($response);
        exit;
    }
    
    // Get the associated transaction
    $transaction_id = $qrData['reference_id'];
    $transaction_data = $transaction->read($transaction_id);
    
    if (!$transaction_data) {
        $response = ['success' => false, 'message' => 'Transaction not found'];
        echo json_encode($response);
        exit;
    }
    
    // Update transaction status to COMPLETED
    $update_result = $transaction->update($transaction_id, ['status' => 'COMPLETED']);
    
    if ($update_result) {
        $response = [
            'success' => true, 
            'message' => 'Transaction verified successfully',
            'transaction' => $transaction_data
        ];
    } else {
        $response = ['success' => false, 'message' => 'Failed to complete transaction'];
    }
    
    echo json_encode($response);
} catch (Exception $e) {
    $response = ['success' => false, 'message' => $e->getMessage()];
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>