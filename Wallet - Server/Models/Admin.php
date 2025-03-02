<?php
class Admin {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    public function create($username, $email, $password, $first_name, $last_name, $role) {
        $password_hash = password_hash($password, PASSWORD_BCRYPT);
        $stmt = $this->db->prepare(
            "INSERT INTO admins (username, email, password_hash, first_name, last_name, role) 
             VALUES (?, ?, ?, ?, ?, ?)"
        );
        $stmt->bind_param("ssssss", $username, $email, $password_hash, $first_name, $last_name, $role);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function read($username) {
        $stmt = $this->db->prepare("SELECT * FROM admins WHERE username = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        return $result;
    }

    public function update($admin_id, $data) {
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
        if (isset($data['role'])) {
            $set[] = "role = ?";
            $types .= 's';
            $values[] = $data['role'];
        }

        if (empty($set)) return false;

        $query = "UPDATE admins SET " . implode(', ', $set) . " WHERE admin_id = ?";
        $types .= 'i';
        $values[] = $admin_id;

        $stmt = $this->db->prepare($query);
        $stmt->bind_param($types, ...$values);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function delete($admin_id) {
        $stmt = $this->db->prepare("DELETE FROM admins WHERE admin_id = ?");
        $stmt->bind_param("i", $admin_id);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }
}
?>