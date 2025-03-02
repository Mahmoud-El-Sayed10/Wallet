<?php

// API to manage users for SUPER_ADMIN

require_once '../../connection/db_connect.php';
require_once '../../model/User.php';

header('Content-Type: application/json');

session_start();
$response = ['success' => false, 'message' => 'Unauthorized'];
if (!isset($_SESSION['admin_id']) || !isset($_SESSION['role']) || $_SESSION['role'] !== 'SUPER_ADMIN') {
    http_response_code(401);
    echo json_encode($response);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!isset($_POST['user_id']) || !isset($_POST['action'])) {
        $response['message'] = 'Missing user_id or action';
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
    $user = new User($db);

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $users = [];
        $result = $db->query("SELECT user_id, email, first_name, last_name, account_status, registration_date FROM users");
        while ($row = $result->fetch_assoc()) {
            $users[] = $row;
        }
        $response['success'] = true;
        $response['message'] = 'Users retrieved';
        $response['data'] = $users;
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $user_id = $_POST['user_id'];
        $action = $_POST['action']; 
        $new_status = ($action === 'activate') ? 'ACTIVE' : 'SUSPENDED';

        $userData = $user->read($user_id);
        if (!$userData) {
            $response['message'] = 'User not found';
            echo json_encode($response);
            exit;
        }

        $updateData = ['account_status' => $new_status];
        if ($user->update($user_id, $updateData)) {
            $response['success'] = true;
            $response['message'] = "User " . $action . "d successfully";
        } else {
            $response['message'] = 'Failed to ' . $action . ' user';
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