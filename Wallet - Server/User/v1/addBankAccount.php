<?php

$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/BankAccount.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

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

if (!isset($data['account_holder_name']) || !isset($data['bank_name']) || !isset($data['account_number']) || 
    !isset($data['routing_number']) || !isset($data['account_type']) || !isset($data['currency_code'])) {
    $response['message'] = 'Missing required fields';
    echo json_encode($response);
    exit;
}

try {
    $bankAccount = new BankAccount($conn);
    $account_nickname = $data['account_nickname'] ?? null;
    $account_holder_name = $data['account_holder_name'];
    $bank_name = $data['bank_name'];
    $account_number = $data['account_number'];
    $routing_number = $data['routing_number'];
    $account_type = $data['account_type'];
    $currency_code = $data['currency_code'];
    $is_primary = $data['is_primary'] ?? false;
    $is_verified = $data['is_verified'] ?? false;

    if (!in_array($account_type, ['CHECKING', 'SAVINGS', 'OTHER'])) {
        $response['message'] = 'Invalid account type';
        echo json_encode($response);
        exit;
    }

    if ($bankAccount->create($user_id, $account_nickname, $account_holder_name, $bank_name, $account_number, $routing_number, $account_type, $currency_code)) {
        $bank_account_id = $conn->insert_id;
        $stmt = $conn->prepare("INSERT INTO timestamps (entity_type, entity_id) VALUES ('BANK_ACCOUNT', ?)");
        $stmt->bind_param("i", $bank_account_id);
        $stmt->execute();
        $response['success'] = true;
        $response['message'] = 'Bank account added successfully';
        $response['bank_account_id'] = $bank_account_id;
    } else {
        $response['message'] = 'Failed to add bank account';
    }

    echo json_encode($response);
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>