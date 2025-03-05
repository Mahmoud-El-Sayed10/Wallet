<?php
// API to retrieve transactions for a specific user

require_once '../../Connection/db_connect.php';
require_once '../../Models/User.php';
require_once '../../Models/Transaction.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

session_start();
$response = ['success' => false, 'message' => 'Unauthorized'];
if (!isset($_SESSION['admin_id']) || !isset($_SESSION['role'])) {
    http_response_code(401);
    echo json_encode($response);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET' || !isset($_GET['user_id'])) {
    $response['message'] = 'Method not allowed or missing user_id';
    http_response_code(400);
    echo json_encode($response);
    exit;
}

$user_id = $_GET['user_id'];

try {
    $user = new User($db);
    $userData = $user->read($user_id);
    if (!$userData) {
        $response['message'] = 'User not found';
        echo json_encode($response);
        exit;
    }

    $transaction = new Transaction($db);
    $wallets = $db->query("SELECT wallet_id FROM wallets WHERE user_id = ?", [$user_id])->fetch_all(MYSQLI_ASSOC);
    $transactions = [];
    foreach ($wallets as $wallet) {
        $walletTransactions = $transaction->getByWallet($wallet['wallet_id']);
        $transactions = array_merge($transactions, $walletTransactions);
    }
    $response['success'] = true;
    $response['message'] = 'User transactions retrieved';
    $response['data'] = $transactions;

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(500);
    echo json_encode($response);
}

$db->close();
?>