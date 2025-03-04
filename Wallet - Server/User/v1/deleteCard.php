<?php
$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/Card.php';
require_once '../../Models/Wallet.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

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

if (!isset($data['card_id'])) {
    $response['message'] = 'Card ID is required';
    echo json_encode($response);
    exit;
}

$card_id = $data['card_id'];

try {
    error_log("Starting deleteCard.php for card_id: $card_id", 3, '../../logs/error.log');
    $card = new Card($db);
    $card_data = $card->readById($card_id);
    error_log("Card data retrieved: " . print_r($card_data, true), 3, '../../logs/error.log');
    if (!$card_data) {
        $response['message'] = 'Card not found';
        echo json_encode($response);
        exit;
    }

    $wallet = new Wallet($db);
    $wallets = $wallet->read($user_id);
    if (!is_array($wallets)) {
        $wallets = []; // Fallback if read returns non-array
        error_log("Wallets is not an array, set to empty: " . print_r($wallets, true), 3, '../../logs/error.log');
    }
    $is_owner = false;
    foreach ($wallets as $w) {
        if (isset($card_data['wallet_id']) && $card_data['wallet_id'] == $w['wallet_id']) {
            $is_owner = true;
            break;
        }
    }
    error_log("Ownership check result: " . ($is_owner ? 'true' : 'false'), 3, '../../logs/error.log');
    if (!$is_owner) {
        $response['message'] = 'Unauthorized to delete this card';
        echo json_encode($response);
        exit;
    }

    if ($card->delete($card_id)) {
        error_log("Delete successful for card_id: $card_id", 3, '../../logs/error.log');
        $stmt = $db->prepare("INSERT INTO timestamps (entity_type, entity_id) VALUES ('CARD', ?)");
        if ($stmt === false) {
            error_log("Prepare failed: " . $db->error, 3, '../../logs/error.log');
        }
        $stmt->bind_param("i", $card_id);
        $stmt->execute();
        $response['success'] = true;
        $response['message'] = 'Card deleted successfully';
    } else {
        $response['message'] = 'Failed to delete card';
        error_log("Delete failed for card_id: $card_id", 3, '../../logs/error.log');
    }

    echo json_encode($response);
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    error_log("Exception caught: " . $e->getMessage(), 3, '../../logs/error.log');
    echo json_encode($response);
}

$db->close();
?>