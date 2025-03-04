<?php
$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/Card.php';


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
    $cards = [];
    $stmt = $db->prepare("SELECT c.* FROM cards c JOIN wallets w ON c.wallet_id = w.wallet_id WHERE w.user_id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    while ($row = $result->fetch_assoc()) {
        $cards[] = $row;
    }
    $stmt->close();

    if (empty($cards)) {
        $response['message'] = 'No cards found';
        echo json_encode($response);
        exit;
    }

    $response['success'] = true;
    $response['message'] = 'Cards retrieved successfully';
    $response['data'] = $cards;
    echo json_encode($response);
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>