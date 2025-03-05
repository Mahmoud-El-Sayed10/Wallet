<?php
$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/Wallet.php';

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
    $wallet = new Wallet($db);
    $wallets = $wallet->read($user_id);
    if (empty($wallets)) {
        $response['message'] = 'No wallets found';
        echo json_encode($response);
        exit;
    }

    $response['success'] = true;
    $response['message'] = 'Wallets retrieved successfully';
    $response['data'] = $wallets;
    echo json_encode($response);
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>