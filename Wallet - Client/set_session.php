<?php
session_start();
$_SESSION['user_id'] = 1; // Set for test@example.com
echo "Session set. Proceed to getWallets.php";
?>