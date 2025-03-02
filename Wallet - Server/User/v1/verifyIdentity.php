<?php
// API to upload verification documents for identity verification

require_once '../../connection/db_connect.php';
require_once '../../model/VerificationDocument.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

session_start();
$response = ['success' => false, 'message' => 'Unauthorized'];
if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode($response);
    exit;
}

$user_id = $_SESSION['user_id'];

if (!isset($_FILES['document']) || !isset($_POST['document_type'])) {
    $response['message'] = 'Missing document or document_type';
    echo json_encode($response);
    exit;
}

$document_type = $_POST['document_type'];
if (!in_array($document_type, ['PASSPORT', 'ID_CARD'])) {
    $response['message'] = 'Invalid document type';
    echo json_encode($response);
    exit;
}

try {
    $document = new VerificationDocument($db);
    $uploadDir = __DIR__ . '/../../uploads/';
    if (!file_exists($uploadDir)) mkdir($uploadDir, 0777, true);

    $file = $_FILES['document'];
    $fileName = uniqid() . '_' . basename($file['name']);
    $targetFile = $uploadDir . $fileName;

    if (move_uploaded_file($file['tmp_name'], $targetFile)) {
        if ($document->create($user_id, $document_type, $fileName)) {
            $response['success'] = true;
            $response['message'] = 'Verification document uploaded successfully';
            $response['document_path'] = $fileName;
        } else {
            unlink($targetFile); 
            $response['message'] = 'Failed to save document record';
        }
    } else {
        $response['message'] = 'Failed to upload file';
    }

    echo json_encode($response);

} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
    echo json_encode($response);
}

$db->close();
?>