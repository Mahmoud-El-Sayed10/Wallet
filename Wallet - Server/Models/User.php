<?php
class User{

    private $conn;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function create($email, $password, $first_name, $last_name, $date_of_birth, $phone_number = null) {
        $password_hash = password_hash($password, PASSWORD_BCRYPT);
        $stmt = $this->conn->prepare("INSERT INTO users (email, password_hash, phone_number, first_name, last_name, date_of_birth, verification_level) VALUES (?, ?, ?, ?, ?, ?, 'UNVERIFIED')");
        $stmt->bind_param("ssssss", $email, $password_hash, $phone_number, $first_name, $last_name, $date_of_birth);
        return $stmt->execute();
    }

    public function read($email){
        $stmt = $this->conn->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->bind_param("s","email");
        $stmt->execute();
        return $stmt->get_result()->fetch_assoc();
    }

    public function update($user_id, $data){
        $set = [];
        $params = [];
        $types = '';
        $values = [];

        if (isset($data['last_login'])){
            $set[] = "last_login = ?";
            $types = 's';
            $values[] = $data['last_login'];
        }

        if (empty($set)) return false;

        $stmt = $this->conn->prepare("UPDATE users SET " . implode(', ', $set) . " WHERE user_id = ?");
        $types .= 'i';
        $values[] = $user_id;
        $stmt->bind_param($types, ...$values);
        return $stmt->execute();

    }

        public function delete($user_id){
            $stmt = $this->conn->prepare ("DELETE FROM users WHERE user_id = ?");
            $stmt->bind_param("i", $user_id);
            return $stmt->execute();
        }
}
?>