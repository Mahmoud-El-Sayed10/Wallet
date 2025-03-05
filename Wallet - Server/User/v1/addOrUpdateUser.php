<?php

// API to add or update a user with dynamic profile updates

$db = require_once '../../Connection/db_connect.php';
require_once '../../Models/User.php';


$response = ['success' => false, 'message' => 'Missing id'];

if (isset($_GET['id']) && $_GET['id'] === 'add') {
    $is_new = true;
} elseif (isset($_GET['id'])) {
    $is_new = false;
} else {
    echo json_encode($response);
    exit;
}

// Required fields for new user
if ($is_new && (!isset($_POST['email']) || !isset($_POST['password']) || !isset($_POST['first_name']) || !isset($_POST['last_name']) || !isset($_POST['date_of_birth']))) {
    $response['message'] = 'Missing required parameters for new user';
    echo json_encode($response);
    exit;
}

try {
    $user = new User($db);

    $email = $_POST['email'] ?? null;
    $password = $_POST['password'] ?? null;
    $first_name = $_POST['first_name'] ?? null;
    $last_name = $_POST['last_name'] ?? null;
    $date_of_birth = $_POST['date_of_birth'] ?? null;
    $phone_number = $_POST['phone_number'] ?? null;

    if ($is_new) {
        $existingUser = $user->read($email);
        if ($existingUser) {
            $response['message'] = 'Email already registered';
            echo json_encode($response);
            exit;
        }

        $password_hash = password_hash($password, PASSWORD_BCRYPT);
        if ($user->create($email, $password_hash, $first_name, $last_name, $date_of_birth, $phone_number)) {
            $user_id = $conn->insert_id;
            $stmt = $conn->prepare("INSERT INTO wallets (user_id, currency_code) VALUES (?, 'USD')");
            $stmt->bind_param("i", $user_id);
            $stmt->execute();

            $stmt = $conn->prepare("INSERT INTO timestamps (entity_type, entity_id) VALUES ('USER', ?)");
            $stmt->bind_param("i", $user_id);
            $stmt->execute();

            $response['success'] = true;
            $response['message'] = 'User created successfully';
            $response['user_id'] = $user_id;
        } else {
            $response['message'] = 'Failed to create user';
        }
    } else {
        $user_id = $_GET['id'];
        $updateData = [];
        if (isset($_POST['email'])) $updateData['email'] = $_POST['email'];
        if (isset($_POST['password'])) $updateData['password'] = password_hash($_POST['password'], PASSWORD_BCRYPT);
        if (isset($_POST['first_name'])) $updateData['first_name'] = $_POST['first_name'];
        if (isset($_POST['last_name'])) $updateData['last_name'] = $_POST['last_name'];
        if (isset($_POST['phone_number'])) $updateData['phone_number'] = $_POST['phone_number'];
        if (isset($_POST['date_of_birth'])) $updateData['date_of_birth'] = $_POST['date_of_birth'];

        if (empty($updateData)) {
            $response['message'] = 'No fields to update';
        } elseif ($user->update($user_id, $updateData)) {
            $response['success'] = true;
            $response['message'] = 'User updated successfully';
        } else {
            $response['message'] = 'User update failed';
        }
    }

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    error_log("Add/Update user failed: " . $e->getMessage(), 3, LOG_PATH);
    echo json_encode($response);
}

$db->close();

?>