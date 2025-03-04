<?php
// API to log in a user with email and password
$db = require_once '../../Connection/db_connect.php'; // Capture the returned connection
require_once '../../Models/User.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

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

if (!$db) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database connection failed']);
    exit;
}

try {
    $user = new User($db);
    $email = filter_var($data['email'], FILTER_SANITIZE_EMAIL);
    $password = $data['password'];
    $userData = $user->read($email);
    if (!$userData || !password_verify($password, $userData['password_hash'])) {
        throw new Exception('Invalid email or password');
    }

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