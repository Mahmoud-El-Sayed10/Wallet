<?php
// Wallet - Server/test_db.php
// Tests MySQLi database connection by querying the admins table

require_once 'Connection/db_connect.php';

header('Content-Type: application/json');

// Query the admins table
$result = $conn->query("SELECT COUNT(*) as admin_count FROM admins");

if ($result) {
    $row = $result->fetch_assoc();
    echo json_encode([
        'status' => 'success',
        'admin_count' => $row['admin_count'],
        'message' => 'Database connection successful'
    ]);
} else {
    error_log("Test failed: " . $conn->error, 3, LOG_PATH);
    http_response_code(500);
    echo json_encode(['error' => 'Database query failed: ' . $conn->error]);
}
?>