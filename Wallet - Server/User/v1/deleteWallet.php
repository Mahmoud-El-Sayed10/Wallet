<?php
$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/Wallet.php';

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

if (!isset($data['wallet_id'])) {
    $response['message'] = 'Wallet ID is required';
    echo json_encode($response);
    exit;
}

$wallet_id = $data['wallet_id'];

try {
    $wallet = new Wallet($db);
    
    // Get all wallets for the user
    $wallets = $wallet->read($user_id);
    
    // Check if the wallet belongs to the user
    $walletFound = false;
    if (is_array($wallets)) {
        foreach ($wallets as $w) {
            if ($w['wallet_id'] == $wallet_id) {
                $walletFound = true;
                break;
            }
        }
    }
    
    if (!$walletFound) {
        $response['message'] = 'Wallet not found or does not belong to user';
        http_response_code(403);
        echo json_encode($response);
        exit;
    }
    
    // Check if there are any cards associated with this wallet
    $stmt = $db->prepare("SELECT COUNT(*) as card_count FROM cards WHERE wallet_id = ?");
    $stmt->bind_param("i", $wallet_id);
    $stmt->execute();
    $cardCount = $stmt->get_result()->fetch_assoc()['card_count'];
    
    if ($cardCount > 0) {
        $response['message'] = 'Cannot delete wallet with associated cards. Please delete all cards first.';
        echo json_encode($response);
        exit;
    }
    
    // Check if this is the user's only wallet
    if (count($wallets) <= 1) {
        $response['message'] = 'Cannot delete your only wallet. Please create another wallet first.';
        echo json_encode($response);
        exit;
    }
    
    if ($wallet->delete($wallet_id)) {
        $stmt = $db->prepare("INSERT INTO timestamps (entity_type, entity_id) VALUES ('WALLET', ?)");
        $stmt->bind_param("i", $wallet_id);
        $stmt->execute();
        $response['success'] = true;
        $response['message'] = 'Wallet deleted successfully';
    } else {
        $response['message'] = 'Failed to delete wallet';
    }
    
    echo json_encode($response);
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>