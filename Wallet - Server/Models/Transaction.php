<?php
class Transaction {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    public function create($wallet_id, $transaction_type, $amount, $currency_code) {
        $transaction_id = $this->generateTransactionId(); // Generate a unique ID
        $stmt = $this->db->prepare(
            "INSERT INTO transactions (transaction_id, wallet_id, transaction_type, amount, currency_code, status) 
             VALUES (?, ?, ?, ?, ?, 'PENDING')"
        );
        $stmt->bind_param("sissd", $transaction_id, $wallet_id, $transaction_type, $amount, $currency_code);
        $success = $stmt->execute();
        $stmt->close();
        return $success ? $transaction_id : false;
    }

    public function read($transaction_id) {
        $stmt = $this->db->prepare("SELECT * FROM transactions WHERE transaction_id = ?");
        $stmt->bind_param("s", $transaction_id);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        return $result;
    }

    public function update($transaction_id, $data) {
        $set = [];
        $params = [];
        $types = '';
        $values = [];

        if (isset($data['status'])) {
            $set[] = "status = ?";
            $types .= 's';
            $values[] = $data['status'];
        }
        if (isset($data['amount'])) {
            $set[] = "amount = ?";
            $types .= 'd';
            $values[] = $data['amount'];
        }

        if (empty($set)) return false;

        $query = "UPDATE transactions SET " . implode(', ', $set) . " WHERE transaction_id = ?";
        $types .= 's';
        $values[] = $transaction_id;

        $stmt = $this->db->prepare($query);
        $stmt->bind_param($types, ...$values);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function delete($transaction_id) {
        $stmt = $this->db->prepare("DELETE FROM transactions WHERE transaction_id = ?");
        $stmt->bind_param("s", $transaction_id);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function getTotalByWallet($wallet_id) {
        $stmt = $this->db->prepare("SELECT SUM(amount) as total FROM transactions WHERE wallet_id = ? AND status = 'COMPLETED'");
        $stmt->bind_param("i", $wallet_id);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        return $result['total'] ?: 0;
    }

    public function getByWallet($wallet_id) {
        $stmt = $this->db->prepare("SELECT * FROM transactions WHERE wallet_id = ?");
        $stmt->bind_param("i", $wallet_id);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        $stmt->close();
        return $result;
    }

    private function generateTransactionId() {
        return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }
}
?>