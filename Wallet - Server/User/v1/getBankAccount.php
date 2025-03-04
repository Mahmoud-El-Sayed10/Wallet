<?php
$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/BankAccount.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
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

try {
    $bankAccount = new BankAccount($conn);
    $accounts = [];
    $result = $conn->query("SELECT * FROM bank_accounts WHERE user_id = $user_id");
    while ($row = $result->fetch_assoc()) {
        $accounts[] = $row;
    }
    if (empty($accounts)) {
        $response['message'] = 'No bank accounts found';
        echo json_encode($response);
        exit;
    }

    $response['success'] = true;
    $response['message'] = 'Bank accounts retrieved successfully';
    $response['data'] = $accounts;
    echo json_encode($response);
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>