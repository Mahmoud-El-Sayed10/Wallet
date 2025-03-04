<?php
$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/Card.php';

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

if (!isset($data['wallet_id']) || !isset($data['cardholder_name']) || !isset($data['card_number_last_four']) || 
    !isset($data['card_type']) || !isset($data['expiry_month']) || !isset($data['expiry_year']) || 
    !isset($data['currency_code'])) {
    $response['message'] = 'Missing required fields';
    echo json_encode($response);
    exit;
}

try {
    $card = new Card($db);
    $wallet_id = $data['wallet_id'];
    $card_nickname = $data['card_nickname'] ?? null;
    $cardholder_name = $data['cardholder_name'];
    $card_number_last_four = $data['card_number_last_four'];
    $card_type = $data['card_type'];
    $expiry_month = $data['expiry_month'];
    $expiry_year = $data['expiry_year'];
    $currency_code = $data['currency_code'];
    $is_primary = $data['is_primary'] ?? false;

    if (!in_array($card_type, ['VISA', 'MASTERCARD', 'AMEX', 'DISCOVER', 'OTHER']) || 
        $expiry_month < 1 || $expiry_month > 12 || $expiry_year < date('Y') || 
        strlen($card_number_last_four) !== 4) {
        $response['message'] = 'Invalid card data';
        echo json_encode($response);
        exit;
    }

    if ($card->create($wallet_id, $card_nickname, $cardholder_name, $card_number_last_four, $card_type, $expiry_month, $expiry_year, $currency_code, $is_primary)) {
        $card_id = $db->insert_id;
        $stmt = $db->prepare("INSERT INTO timestamps (entity_type, entity_id) VALUES ('CARD', ?)");
        $stmt->bind_param("i", $card_id);
        $stmt->execute();
        $response['success'] = true;
        $response['message'] = 'Card added successfully';
        $response['card_id'] = $card_id;
    } else {
        $response['message'] = 'Failed to add card';
    }

    echo json_encode($response);
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>