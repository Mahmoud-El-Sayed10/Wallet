<?php
// API to add a new wallet for a user

require_once '../../connection/db_connect.php';
require_once '../../model/Wallet.php';

header('Content-Type: application/json');

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

if (!isset($_POST['currency_code'])) {
    $response['message'] = 'Missing currency_code';
    echo json_encode($response);
    exit;
}

try {
    $wallet = new Wallet($db);
    $currency_code = $_POST['currency_code'];

    if ($wallet->create($user_id, $currency_code)) {
        $wallet_id = $db->insert_id;
        $stmt = $db->prepare("INSERT INTO timestamps (entity_type, entity_id) VALUES ('WALLET', ?)");
        $stmt->bind_param("i", $wallet_id);
        $stmt->execute();

        $response['success'] = true;
        $response['message'] = 'Wallet created successfully';
        $response['wallet_id'] = $wallet_id;
    } else {
        $response['message'] = 'Failed to create wallet';
    }

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>