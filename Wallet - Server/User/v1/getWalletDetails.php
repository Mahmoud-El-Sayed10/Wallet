<?php
// API to retrieve details of a specific wallet for a user

require_once '../../connection/db_connect.php';
require_once '../../model/Wallet.php';

header('Content-Type: application/json');

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
if (!isset($_GET['wallet_id'])) {
    $response['message'] = 'Missing wallet_id';
    echo json_encode($response);
    exit;
}

$wallet_id = $_GET['wallet_id'];

try {
    $wallet = new Wallet($db);
    $wallets = $db->query("SELECT wallet_id FROM wallets WHERE user_id = ?", [$user_id])->fetch_all(MYSQLI_ASSOC);
    $userWalletIds = array_column($wallets, 'wallet_id');
    if (!in_array($wallet_id, $userWalletIds)) {
        $response['message'] = 'Wallet does not belong to user';
        echo json_encode($response);
        exit;
    }

    $walletData = $wallet->read($wallet_id); 
    if (!$walletData) {
        $response['message'] = 'Wallet not found';
        echo json_encode($response);
        exit;
    }

    $response['success'] = true;
    $response['message'] = 'Wallet details retrieved';
    $response['data'] = $walletData;

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>