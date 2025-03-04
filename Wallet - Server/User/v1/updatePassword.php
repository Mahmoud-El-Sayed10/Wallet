<?php
// API to update user password with verification of current password

$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/User.php';

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

if (!isset($data['current_password']) || !isset($data['password'])) {
    $response['message'] = 'Missing required fields';
    echo json_encode($response);
    exit;
}

try {
    $user = new User($db);
    $userData = $user->read($user_id);
    
    if (!$userData) {
        $response['message'] = 'User not found';
        echo json_encode($response);
        exit;
    }
    
    // Verify current password
    if (!password_verify($data['current_password'], $userData['password_hash'])) {
        $response['message'] = 'Current password is incorrect';
        echo json_encode($response);
        exit;
    }
    
    // Validate new password (at least 8 characters)
    if (strlen($data['password']) < 8) {
        $response['message'] = 'New password must be at least 8 characters long';
        echo json_encode($response);
        exit;
    }
    
    // Update with new password
    $new_password_hash = password_hash($data['password'], PASSWORD_BCRYPT);
    $updateData = ['password_hash' => $new_password_hash];
    
    if ($user->update($user_id, $updateData)) {
        $response['success'] = true;
        $response['message'] = 'Password updated successfully';
    } else {
        $response['message'] = 'Failed to update password';
    }
    
    echo json_encode($response);
    
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>