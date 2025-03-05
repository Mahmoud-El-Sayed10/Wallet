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
        $types = '';
        $values = [];
    
        // Build the SET part of the query based on provided data
        foreach ($data as $key => $value) {
            $set[] = "$key = ?";
            
            // Determine data type for bind_param
            if (is_int($value) || is_bool($value)) {
                $types .= 'i';
            } else {
                $types .= 's';
            }
            
            $values[] = $value;
        }
    
        if (empty($set)) return false;
    
        // Add bank_account_id to values and types
        $types .= 'i';
        $values[] = $bank_account_id;
    
        $query = "UPDATE bank_accounts SET " . implode(', ', $set) . " WHERE bank_account_id = ?";
        
        $stmt = $this->db->prepare($query);
        if ($stmt === false) {
            return false;
        }
        
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