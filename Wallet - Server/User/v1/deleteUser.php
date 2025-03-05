<?php
// Wallet - Server/user/v1/deleteUser.php
// API to delete a user by ID

$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/User.php';

// Step 1: Check for user_id
$response = ['success' => false, 'message' => 'Missing user ID'];
if (!isset($_GET['id'])) {
    echo json_encode($response);
    exit;
}

$user_id = $_GET['id'];

try {
    // Step 2: Verify user exists
    $user = new User($db);
    $userData = $user->read($user_id); 
    if (!$userData) {
        $response['message'] = 'User not found';
        echo json_encode($response);
        exit;
    }

    // Step 3: Delete user
    if ($user->delete($user_id)) {
        $response['success'] = true;
        $response['message'] = 'User deleted successfully';
    } else {
        $response['message'] = 'Failed to delete user';
    }

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>