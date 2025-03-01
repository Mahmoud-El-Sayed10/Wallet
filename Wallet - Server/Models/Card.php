<?php

class Card{
    private $conn;

    public function __construct($db){
        $this->conn = $db;
    }

    public function create($wallet_id, $card_nickname, $cardholder_name, $card_number_last_four, $card_type, $expiry_month, $expiry_year, $currency_code) {
        $stmt = $this->conn->prepare("INSERT INTO cards (wallet_id, card_nickname, cardholder_name, card_number_last_four, card_type, expiry_month, expiry_year, currency_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("issssiis", $wallet_id, $card_nickname, $cardholder_name, $card_number_last_four, $card_type, $expiry_month, $expiry_year, $currency_code);
        return $stmt->execute();
    }

    public function read($wallet_id) {
        $stmt = $this->conn->prepare("SELECT * FROM cards WHERE wallet_id = ?");
        $stmt->bind_param("i", $wallet_id);
        $stmt->execute();
        return $stmt->get_result()->fetch_assoc();
    }

    public function update($card_id, $data){
        $set = [];
        $params = [];
        $types = '';
        $values = [];

        if (isset($data['card_nickname'])){
            $set[] = "card_nickname = ?";
            $types = 's';
            $values[] = $data['card_nickname'];
        }

        if (empty($set)) return false;

        $stmt = $this->conn->prepare("UPDATE cards SET " . implode(', ', $set) . " WHERE card_id = ?");
        $types .= 'i';
        $values[] = $card_id;
        $stmt->bind_param($types, ...$values);
        return $stmt->execute();
    }

    public function delete($card_id) {
        $stmt = $this->conn->prepare("DELETE FROM cards WHERE card_id = ?");
        $stmt->bind_param("i", $card_id);
        return $stmt->execute();
    }

}
?>