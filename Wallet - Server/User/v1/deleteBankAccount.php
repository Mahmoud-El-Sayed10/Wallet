<?php
$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/BankAccount.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
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

if (!isset($data['bank_account_id'])) {
    $response['message'] = 'Bank account ID is required';
    echo json_encode($response);
    exit;
}

$bank_account_id = $data['bank_account_id'];

try {
    $bankAccount = new BankAccount($db);
    
    // Get the bank account to verify ownership
    $accountData = $bankAccount->read($bank_account_id);
    
    // If account not found, it might have been deleted already
    if (!$accountData) {
        $response['success'] = true; // Still consider it a success
        $response['message'] = 'Bank account not found or already deleted';
        echo json_encode($response);
        exit;
    }
    
    // Check if the bank account belongs to the current user
    if ($accountData['user_id'] != $user_id) {
        $response['message'] = 'Unauthorized to delete this bank account';
        http_response_code(403);
        echo json_encode($response);
        exit;
    }
    
    if ($bankAccount->delete($bank_account_id)) {
        // Try/catch block just for the timestamp to isolate potential issues
        try {
            $stmt = $db->prepare("INSERT INTO timestamps (entity_type, entity_id) VALUES ('BANK_ACCOUNT', ?)");
            $stmt->bind_param("i", $bank_account_id);
            $stmt->execute();
        } catch (Exception $e) {
            // Log but don't fail the operation if timestamp fails
            error_log("Timestamp error: " . $e->getMessage());
        }
        
        $response['success'] = true;
        $response['message'] = 'Bank account deleted successfully';
    } else {
        $response['message'] = 'Failed to delete bank account';
    }
    
    echo json_encode($response);
    
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400); // This is likely the issue causing the 400 response
    echo json_encode($response);
}

$db->close();
?>