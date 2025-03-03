<?php

// API to retrieve detailed transaction analytics for admins

require_once '../../connection/db_connect.php';
require_once '../../model/Transaction.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

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
    $transactionModel = new Transaction($db);

    $analytics = [];

    // Total transactions by type
    $result = $db->query("SELECT transaction_type, COUNT(*) as count, SUM(amount) as total 
                          FROM transactions WHERE status = 'COMPLETED' 
                          GROUP BY transaction_type");
    $typeSummary = [];
    while ($row = $result->fetch_assoc()) {
        $typeSummary[$row['transaction_type']] = [
            'count' => $row['count'],
            'total_amount' => $row['total']
        ];
    }
    $analytics['transaction_type_summary'] = $typeSummary;

    // Transaction trends (last 30 days)
    $thirtyDaysAgo = date('Y-m-d', strtotime('-30 days'));
    $result = $db->query("SELECT DATE(transaction_date) as trans_date, SUM(amount) as daily_total 
                          FROM transactions WHERE transaction_date >= ? AND status = 'COMPLETED' 
                          GROUP BY DATE(transaction_date)", [$thirtyDaysAgo]);
    $transactionTrends = [];
    while ($row = $result->fetch_assoc()) {
        $transactionTrends[] = [
            'date' => $row['trans_date'],
            'total' => $row['daily_total']
        ];
    }
    $analytics['transaction_trends'] = $transactionTrends;

    // Top 5 wallets by transaction volume
    $result = $db->query("SELECT wallet_id, SUM(amount) as total 
                          FROM transactions WHERE status = 'COMPLETED' 
                          GROUP BY wallet_id ORDER BY total DESC LIMIT 5");
    $topWallets = [];
    while ($row = $result->fetch_assoc()) {
        $topWallets[] = [
            'wallet_id' => $row['wallet_id'],
            'total_amount' => $row['total']
        ];
    }
    $analytics['top_wallets'] = $topWallets;

    $response['success'] = true;
    $response['message'] = 'Transaction analytics retrieved';
    $response['data'] = $analytics;

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(500);
    echo json_encode($response);
}

$db->close();
?>