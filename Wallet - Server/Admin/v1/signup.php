<?php

// API to sign up a new admin

require_once '../../Connection/db_connect.php';
require_once '../../Models/Admin.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$response = ['success' => false, 'message' => 'Missing required parameters'];
if (empty($_POST['username']) || empty($_POST['email']) || empty($_POST['password']) || empty($_POST['first_name']) || empty($_POST['last_name']) || empty($_POST['role'])) {
    echo json_encode($response);
    exit;
}

$username = $_POST['username'];
$email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $response['message'] = 'Invalid email format';
    echo json_encode($response);
    exit;
}

$existingAdmin = $admin->read($username);
if ($existingAdmin) {
    $response['message'] = 'Username already registered';
    echo json_encode($response);
    exit;
}

try {
    $admin = new Admin($db);
    $password = $_POST['password'];
    $first_name = $_POST['first_name'];
    $last_name = $_POST['last_name'];
    $role = $_POST['role'];

    if ($admin->create($username, $email, $password, $first_name, $last_name, $role)) {
        $admin_id = $db->insert_id;
        $stmt = $db->prepare("INSERT INTO timestamps (entity_type, entity_id) VALUES ('ADMIN', ?)");
        $stmt->bind_param("i", $admin_id);
        $stmt->execute();

        $response['success'] = true;
        $response['message'] = 'Admin created successfully';
        $response['admin_id'] = $admin_id;
    } else {
        $response['message'] = 'Failed to create admin';
    }

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>