<?php
// API to retrieve user details by ID

$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/User.php';

header('Content-Type: application/json');

$response = ['success' => false, 'message' => 'Missing user ID'];
if (!isset($_GET['id'])) {
    echo json_encode($response);
    exit;
}

$user_id = $_GET['id'];

session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['user_id'] != $user_id) {
    http_response_code(401);
    $response['message'] = 'Unauthorized: Invalid session or user mismatch';
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

    $response['success'] = true;
    $response['message'] = 'User details retrieved';
    $response['data'] = [
        'user_id' => $userData['user_id'],
        'email' => $userData['email'],
        'first_name' => $userData['first_name'],
        'last_name' => $userData['last_name'],
        'phone_number' => $userData['phone_number'],
        'date_of_birth' => $userData['date_of_birth']
    ];
    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>