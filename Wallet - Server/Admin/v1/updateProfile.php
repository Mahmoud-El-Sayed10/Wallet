<?php

// API to update admin profile details

require_once '../../Connection/db_connect.php';
require_once '../../Models/Admin.php';

header('Content-Type: application/json');

session_start();
$response = ['success' => false, 'message' => 'Unauthorized'];
if (!isset($_SESSION['admin_id']) || !isset($_SESSION['role'])) {
    http_response_code(401);
    echo json_encode($response);
    exit;
}

$admin_id = $_SESSION['admin_id'];

if (empty($_POST)) {
    $response['message'] = 'No data provided';
    echo json_encode($response);
    exit;
}

$updateData = [];
if (isset($_POST['email'])) $updateData['email'] = $_POST['email'];
if (isset($_POST['first_name'])) $updateData['first_name'] = $_POST['first_name'];
if (isset($_POST['last_name'])) $updateData['last_name'] = $_POST['last_name'];
if (isset($_POST['password'])) $updateData['password_hash'] = password_hash($_POST['password'], PASSWORD_BCRYPT);

if (empty($updateData)) {
    $response['message'] = 'No valid fields to update';
    echo json_encode($response);
    exit;
}

try {
    $admin = new Admin($db);
    if ($admin->update($admin_id, $updateData)) {
        $response['success'] = true;
        $response['message'] = 'Profile updated successfully';
    } else {
        $response['message'] = 'Failed to update profile';
    }

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>