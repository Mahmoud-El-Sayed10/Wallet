<?php

// API to log in an admin with username and password

require_once '../../Connection/db_connect.php';
require_once '../../Models/Admin.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$response = ['success' => false, 'message' => 'Missing credentials'];
if (empty($_POST['username']) || empty($_POST['password'])) {
    echo json_encode($response);
    exit;
}

$username = $_POST['username'];
$password = $_POST['password'];

try {
    $admin = new Admin($db);
    $adminData = $admin->read($username);
    if (!$adminData || !password_verify($password, $adminData['password_hash'])) {
        $response['message'] = 'Invalid username or password';
        echo json_encode($response);
        exit;
    }

    session_start();
    $_SESSION['admin_id'] = $adminData['admin_id'];
    $_SESSION['role'] = $adminData['role']; 

    $response['success'] = true;
    $response['message'] = 'Login successful';
    $response['admin_id'] = $adminData['admin_id'];
    $response['role'] = $adminData['role'];

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(401);
    echo json_encode($response);
}

$db->close();
?>