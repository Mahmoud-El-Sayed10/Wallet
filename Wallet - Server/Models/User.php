<?php
class User {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    public function create($email, $password_hash, $first_name, $last_name, $date_of_birth, $phone_number = null) {
        $stmt = $this->db->prepare(
            "INSERT INTO users (email, password_hash, first_name, last_name, date_of_birth, phone_number) 
             VALUES (?, ?, ?, ?, ?, ?)"
        );
        $stmt->bind_param("ssssss", $email, $password_hash, $first_name, $last_name, $date_of_birth, $phone_number);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function read($identifier) {
        if (filter_var($identifier, FILTER_VALIDATE_EMAIL)) {
            $stmt = $this->db->prepare("SELECT * FROM users WHERE email = ?");
            $stmt->bind_param("s", $identifier);
        } else {
            $stmt = $this->db->prepare("SELECT * FROM users WHERE user_id = ?");
            $stmt->bind_param("i", $identifier);
        }
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        return $result;
    }

    public function update($user_id, $data) {
        $set = [];
        $params = [];
        $types = '';
        $values = [];

        if (isset($data['email'])) {
            $set[] = "email = ?";
            $types .= 's';
            $values[] = $data['email'];
        }
        if (isset($data['password_hash'])) {
            $set[] = "password_hash = ?";
            $types .= 's';
            $values[] = $data['password_hash'];
        }
        if (isset($data['first_name'])) {
            $set[] = "first_name = ?";
            $types .= 's';
            $values[] = $data['first_name'];
        }
        if (isset($data['last_name'])) {
            $set[] = "last_name = ?";
            $types .= 's';
            $values[] = $data['last_name'];
        }
        if (isset($data['phone_number'])) {
            $set[] = "phone_number = ?";
            $types .= 's';
            $values[] = $data['phone_number'];
        }
        if (isset($data['date_of_birth'])) {
            $set[] = "date_of_birth = ?";
            $types .= 's';
            $values[] = $data['date_of_birth'];
        }

        if (empty($set)) return false;

        $query = "UPDATE users SET " . implode(', ', $set) . " WHERE user_id = ?";
        $types .= 'i';
        $values[] = $user_id;

        $stmt = $this->db->prepare($query);
        $stmt->bind_param($types, ...$values);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function delete($user_id) {
        $stmt = $this->db->prepare("DELETE FROM users WHERE user_id = ?");
        $stmt->bind_param("i", $user_id);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }
}
?>