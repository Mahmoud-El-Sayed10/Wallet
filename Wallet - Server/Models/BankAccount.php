<?php
class BankAccount {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    public function create($user_id, $account_nickname, $account_holder_name, $bank_name, $account_number, $routing_number, $account_type, $currency_code) {
        $stmt = $this->db->prepare(
            "INSERT INTO bank_accounts (user_id, account_nickname, account_holder_name, bank_name, account_number, routing_number, account_type, currency_code) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
        );
        $stmt->bind_param("isssssss", $user_id, $account_nickname, $account_holder_name, $bank_name, $account_number, $routing_number, $account_type, $currency_code);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function read($bank_account_id) {
        $stmt = $this->db->prepare("SELECT * FROM bank_accounts WHERE bank_account_id = ?");
        $stmt->bind_param("i", $bank_account_id);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        return $result;
    }

    public function update($bank_account_id, $data) {
        $set = [];
        $params = [];
        $types = '';
        $values = [];

        if (isset($data['account_nickname'])) {
            $set[] = "account_nickname = ?";
            $types .= 's';
            $values[] = $data['account_nickname'];
        }
        if (isset($data['is_verified'])) {
            $set[] = "is_verified = ?";
            $types .= 'i';
            $values[] = $data['is_verified'];
        }
        // Add more fields as needed

        if (empty($set)) return false;

        $query = "UPDATE bank_accounts SET " . implode(', ', $set) . " WHERE bank_account_id = ?";
        $types .= 'i';
        $values[] = $bank_account_id;

        $stmt = $this->db->prepare($query);
        $stmt->bind_param($types, ...$values);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function delete($bank_account_id) {
        $stmt = $this->db->prepare("DELETE FROM bank_accounts WHERE bank_account_id = ?");
        $stmt->bind_param("i", $bank_account_id);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }
}
?>