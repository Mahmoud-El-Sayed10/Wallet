<?php

// API to retrieve analytics data for admins

require_once '../../Connection/db_connect.php';

header('Content-Type: application/json');

session_start();
$response = ['success' => false, 'message' => 'Unauthorized'];
if (!isset($_SESSION['admin_id']) || !isset($_SESSION['role']) || $_SESSION['role'] !== 'SUPER_ADMIN') {
    http_response_code(401);
    echo json_encode($response);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    $response['message'] = 'Method not allowed';
    http_response_code(405);
    echo json_encode($response);
    exit;
}

try {
    $analytics = [];

    // Total number of users
    $result = $db->query("SELECT COUNT(*) as total_users FROM users WHERE account_status = 'ACTIVE'");
    $analytics['total_users'] = $result->fetch_assoc()['total_users'];

    // Total number of active wallets
    $result = $db->query("SELECT COUNT(*) as total_wallets FROM wallets WHERE wallet_status = 'ACTIVE'");
    $analytics['total_wallets'] = $result->fetch_assoc()['total_wallets'];

    // Total transaction amount (in USD base currency)
    $result = $db->query("SELECT SUM(amount_in_base_currency) as total_transactions FROM transactions WHERE status = 'COMPLETED'");
    $analytics['total_transactions'] = $result->fetch_assoc()['total_transactions'] ?: 0;

    $response['success'] = true;
    $response['message'] = 'Analytics data retrieved';
    $response['data'] = $analytics;

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(500);
    echo json_encode($response);
}

$db->close();
?>