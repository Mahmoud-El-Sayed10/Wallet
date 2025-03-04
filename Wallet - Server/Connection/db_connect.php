<?php
require_once 'config.php';
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Allow-Methods: POST, OPTIONS, GET, DELETE, PUT');
// Replace * with the specific origin (e.g., http://127.0.0.1:5500)
$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : 'http://127.0.0.1:5500';
header("Access-Control-Allow-Origin: $origin");
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Initialize MySQLi connection
$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

// Check connection
if ($conn->connect_error) {    error_log("Database connection failed: " . $conn->connect_error, 3, LOG_PATH);
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Internal server error']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204); // No content for preflight
    exit;
}

// Set charset
if (!$conn->set_charset(DB_CHARSET)) {
    error_log("Error setting charset: " . $conn->error, 3, LOG_PATH);
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Internal server error']);
    exit;
}

// Set UTC timezone
$conn->query("SET time_zone = '+02:00'");

// Prevent direct access
if (basename($_SERVER['PHP_SELF']) === 'db_connect.php') {
    http_response_code(403);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Direct access forbidden']);
    exit;
}

// Return the connection
return $conn;
?>