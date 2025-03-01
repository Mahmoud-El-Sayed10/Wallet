<?php
define('DB_HOST', 'localhost');
define('DB_NAME', 'digital_wallet');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

// File Paths
define('UPLOAD_DIR', __DIR__ . '/../uploads/');
define('LOG_PATH', __DIR__ . '/../logs/error.log');


// Prevent direct access
if (basename($_SERVER['PHP_SELF']) === 'config.php') {
    http_response_code(403);
    echo json_encode(['error' => 'Direct access forbidden']);
    exit;
}
?>