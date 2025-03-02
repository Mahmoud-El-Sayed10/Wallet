<?php

class VerificationDocument {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    public function create($user_id, $document_type, $document_path) {
        $stmt = $this->db->prepare(
            "INSERT INTO verification_documents (user_id, document_type, document_path) 
             VALUES (?, ?, ?)"
        );
        $stmt->bind_param("iss", $user_id, $document_type, $document_path);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function read($document_id) {
        $stmt = $this->db->prepare("SELECT * FROM verification_documents WHERE document_id = ?");
        $stmt->bind_param("i", $document_id);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        return $result;
    }

    public function update($document_id, $data) {
        $set = [];
        $params = [];
        $types = '';
        $values = [];

        if (isset($data['verification_status'])) {
            $set[] = "verification_status = ?";
            $types .= 's';
            $values[] = $data['verification_status'];
        }
        if (isset($data['verified_by'])) {
            $set[] = "verified_by = ?";
            $types .= 'i';
            $values[] = $data['verified_by'];
        }
        // Add more fields as needed

        if (empty($set)) return false;

        $query = "UPDATE verification_documents SET " . implode(', ', $set) . " WHERE document_id = ?";
        $types .= 'i';
        $values[] = $document_id;

        $stmt = $this->db->prepare($query);
        $stmt->bind_param($types, ...$values);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function delete($document_id) {
        $stmt = $this->db->prepare("DELETE FROM verification_documents WHERE document_id = ?");
        $stmt->bind_param("i", $document_id);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }
}
?>