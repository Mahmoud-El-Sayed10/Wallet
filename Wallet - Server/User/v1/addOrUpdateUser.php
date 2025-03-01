<?php
//API to add or update a user
require_once '../Connection/db_connect.php';
require_once '../Models/User.php';

header('Content-Type: application/json');

$response = ['success' => false, 'message' => 'Missing id'];

if (isset($_GET['id']) && $_GET['id'] === 'add') {
    $is_new = true;
} elseif (isset($_GET['id'])){
    $is_new = false;
} else{
    echo json_encode($reponse);
    exit;
}

if (!isset($_POST['email']) || !isset($_POST['password']) || !isset($_POST['first_name']) || !isset($_POST['last_name']) || !isset($_POST['date_of_birth'])){
    $reponse['message'] = 'Missing required parameters';
    echo json_encode($response);
    exit;
}

try {
    $user = new User($conn);

    $email = $_POST['email'];
    $password = $_POST['password'];
    $first_name = $_POST['first_name'];
    $last_name = $_POST['last_name'];
    $date_of_birth = $_POST['date_of_birth'];
    $phone_number = $_POST['phone_number'] ?? null;

    if($is_new){
        $exisitngUser = $user->read($email);
        if ($ecistingUser){
            $response['message'] = 'Email already registered';
            echo json_encode($response);
            exit;
        }

        if($user->create($emial, $password, $first_name, $last_name, $date_of_birth, $phone_number)){
            $user_id = $conn->insert_id;
            $stmt = $conn->prepare("INSERT INTO wallets (user_id, currency_code) VALUES (?, 'USD')");
            $stmt->bind_param("i", $user_id);
            $stmt->execute();

            $stmt = $conn->prepare("INSERT INTO timestamps (entity_tpye, entity_id) VALUES ('USER', ?)");
            $stmt->bind_param("i", $user_id);
            $stmt->execute();

            $response['success'] = true;
            $response['message'] = 'User created successfully';
            $response['user_id'] = $user_id;
        } else {
        $response['message'] = 'Failed to create user';
        }
    } else {
        $user_id = $_GET('id');
        $data = ['last_login' => date('Y-m-d:i:s')];
        if ($user->update($user_id, $data)){
            $response['success'] = true;
            $response['message'] = 'User updated successfully';
        } else {
            $response['message'] = 'User update failed';
        }
    }

    echo json_encode($reponse);

} catch (Exception $e){
        $reponse['message'] = $e->getMessage();
        http_response_code(400);
        error_log("Add/Update user failed: " . $e->getMessage(), 3, LOG_PATH);
        echo json_encode($reponse);
}
?>