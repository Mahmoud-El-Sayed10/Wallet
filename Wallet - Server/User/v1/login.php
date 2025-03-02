<?php

// API to log in a user with email and password

require_once '../../Connection/db_connect.php';
require_once '../../Models/User.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);
if (!$data || !isset($data['email']) || !isset($data['password'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid or missing email/password']);
    exit;
}

try {
    $user = new User($db);

    $email = $data['email'];
    $password = $data['password'];

    $userData = $user->read($email);
    if (!$userData || !password_verify($password, $userData['password_hash'])) {
        throw new Exception('Invalid email or password');
    }

    // Simulate session (replace with JWT later)
    session_start();
    $_SESSION['user_id'] = $userData['user_id'];

    echo json_encode([
        'success' => true,
        'message' => 'Login successful',
        'user_id' => $userData['user_id']
    ]);

} catch (Exception $e) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}

$db->close();
?>