<?php

// API to manage wallets

require_once '../../connection/db_connect.php';
require_once '../../Models/Wallet.php';

header('Content-Type: application/json');

session_start();
$response = ['success' => false, 'message' => 'Unauthorized'];
if (!isset($_SESSION['admin_id']) || !isset($_SESSION['role']) || $_SESSION['role'] !== 'SUPER_ADMIN') {
    http_response_code(401);
    echo json_encode($response);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // View all wallets
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!isset($_POST['wallet_id']) || !isset($_POST['action'])) {
        $response['message'] = 'Missing wallet_id or action';
        echo json_encode($response);
        exit;
    }
} else {
    $response['message'] = 'Method not allowed';
    http_response_code(405);
    echo json_encode($response);
    exit;
}

try {
    $wallet = new Wallet($db);

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $wallets = $wallet->read(0); 
        $response['success'] = true;
        $response['message'] = 'Wallets retrieved';
        $response['data'] = $wallets;
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $wallet_id = $_POST['wallet_id'];
        $action = $_POST['action']; 
        $new_status = ($action === 'activate') ? 'ACTIVE' : 'SUSPENDED';

        $walletData = $wallet->read($wallet_id);
        if (!$walletData) {
            $response['message'] = 'Wallet not found';
            echo json_encode($response);
            exit;
        }

        $updateData = ['wallet_status' => $new_status];
        if ($wallet->update($wallet_id, $updateData)) {
            $response['success'] = true;
            $response['message'] = "Wallet " . $action . "d successfully";
        } else {
            $response['message'] = 'Failed to ' . $action . ' wallet';
        }
    }

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>