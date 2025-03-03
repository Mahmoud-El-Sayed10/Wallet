<?php
// API to update card details for a wallet

require_once '../../connection/db_connect.php';
require_once '../../model/Card.php';

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
if (!isset($_POST['wallet_id']) || !isset($_POST['card_id'])) {
    $response['message'] = 'Missing wallet_id or card_id';
    echo json_encode($response);
    exit;
}

$wallet_id = $_POST['wallet_id'];
$card_id = $_POST['card_id'];

try {
    $card = new Card($db);
    $cardData = $card->read($card_id);
    if (!$cardData || $cardData['wallet_id'] != $wallet_id) {
        $response['message'] = 'Card not found or does not belong to wallet';
        echo json_encode($response);
        exit;
    }

    $wallets = $db->query("SELECT wallet_id FROM wallets WHERE user_id = ?", [$user_id])->fetch_all(MYSQLI_ASSOC);
    $userWalletIds = array_column($wallets, 'wallet_id');
    if (!in_array($wallet_id, $userWalletIds)) {
        $response['message'] = 'Wallet does not belong to user';
        echo json_encode($response);
        exit;
    }

    $updateData = [];
    if (isset($_POST['card_nickname'])) $updateData['card_nickname'] = $_POST['card_nickname'];
    if (isset($_POST['status'])) $updateData['status'] = $_POST['status'];

    if ($card->update($card_id, $updateData)) {
        $response['success'] = true;
        $response['message'] = 'Card updated successfully';
    } else {
        $response['message'] = 'Failed to update card';
    }

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>