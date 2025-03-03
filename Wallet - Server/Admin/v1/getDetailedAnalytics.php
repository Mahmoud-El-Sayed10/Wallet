<?php

// API to retrieve detailed analytics data for admins using models

require_once '../../Connection/db_connect.php';
require_once '../../Models/User.php';
require_once '../../Models/Wallet.php';
require_once '../../Models/Transaction.php';
require_once '../../Models/BankAccount.php';
require_once '../../Models/VerificationDocument.php';

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
    $userModel = new User($db);
    $walletModel = new Wallet($db);
    $transactionModel = new Transaction($db);
    $bankAccountModel = new BankAccount($db);
    $verificationModel = new VerificationDocument($db);

    $analytics = [];

    $users = $userModel->read(0); // Fetch all 
    $activeUsers = array_filter($users, fn($u) => $u['account_status'] === 'ACTIVE');
    $analytics['total_active_users'] = count($activeUsers);

    // Wallet activity by status
    $wallets = $walletModel->read(0); // Fetch all wallets
    $walletStatus = [];
    foreach ($wallets as $wallet) {
        $walletStatus[$wallet['wallet_status']] = ($walletStatus[$wallet['wallet_status']] ?? 0) + 1;
    }
    $analytics['wallet_status'] = $walletStatus;

    // Total verified bank accounts
    $bankAccounts = $bankAccountModel->read(0); // Fetch all (adjust if needed)
    $verifiedAccounts = array_filter($bankAccounts, fn($ba) => $ba['is_verified'] === 1);
    $analytics['total_verified_bank_accounts'] = count($verifiedAccounts);

    // Total verified documents
    $verificationDocs = $verificationModel->read(0); // Fetch all (adjust if needed)
    $verifiedDocs = array_filter($verificationDocs, fn($vd) => $vd['verification_status'] === 'VERIFIED');
    $analytics['total_verified_documents'] = count($verifiedDocs);

    // Transaction trends (last 7 days)
    $sevenDaysAgo = date('Y-m-d', strtotime('-7 days'));
    $result = $db->query("SELECT transaction_type, DATE(transaction_date) as trans_date, SUM(amount) as total 
                          FROM transactions WHERE transaction_date >= ? AND status = 'COMPLETED' 
                          GROUP BY transaction_type, trans_date", [$sevenDaysAgo]);
    $transactionTrends = [];
    while ($row = $result->fetch_assoc()) {
        $transactionTrends[] = [
            'date' => $row['trans_date'],
            'type' => $row['transaction_type'],
            'total' => $row['total']
        ];
    }
    $analytics['transaction_trends'] = $transactionTrends;

    $response['success'] = true;
    $response['message'] = 'Detailed analytics retrieved';
    $response['data'] = $analytics;

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(500);
    echo json_encode($response);
}

$db->close();
?>