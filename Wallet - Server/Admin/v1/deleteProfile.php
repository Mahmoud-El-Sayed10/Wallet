<?php
// API to delete an admin profile

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

$logged_in_admin_id = $_SESSION['admin_id'];

if (!isset($_GET['id'])) {
    $response['message'] = 'Missing admin ID';
    echo json_encode($response);
    exit;
}

$admin_id = $_GET['id'];

if ($admin_id != $logged_in_admin_id && $_SESSION['role'] !== 'SUPER_ADMIN') {
    $response['message'] = 'Permission denied: Can only delete your own profile unless SUPER_ADMIN';
    echo json_encode($response);
    exit;
}

try {
    $admin = new Admin($db);
    $adminData = $admin->read($admin_id); 
    if (!$adminData) {
        $response['message'] = 'Admin not found';
        echo json_encode($response);
        exit;
    }

    if ($admin->delete($admin_id)) {
        session_destroy();
        $response['success'] = true;
        $response['message'] = 'Admin profile deleted successfully';
    } else {
        $response['message'] = 'Failed to delete admin profile';
    }

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>