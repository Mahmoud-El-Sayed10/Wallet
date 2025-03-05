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
        $types = '';
        $values = [];

        $fields = ['email', 'password_hash', 'first_name', 'last_name', 'phone_number', 'date_of_birth'];
        foreach ($fields as $field) {
            if (isset($data[$field])) {
                $set[] = "$field = ?";
                $types .= 's';
                $values[] = $data[$field];
            }
        }

        if (empty($set)) {
            return false;
        }

        $types .= 'i';
        $values[] = $user_id;

        $query = "UPDATE users SET " . implode(', ', $set) . " WHERE user_id = ?";
        $stmt = $this->db->prepare($query);

        if ($stmt === false) {
            error_log("Prepare failed: " . $this->db->error, 3, '../../logs/error.log');
            return false;
        }

        $bindParams = [$stmt, $types];
        foreach ($values as $value) {
            $bindParams[] = $value;
        }
        call_user_func_array([$stmt, 'bind_param'], $bindParams);

        $success = $stmt->execute();
        if ($success === false) {
            error_log("Execute failed: " . $stmt->error, 3, '../../logs/error.log');
        }

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