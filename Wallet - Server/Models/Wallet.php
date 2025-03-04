<?php

class Wallet{
    private $conn;

    public function __construct($db)
    {
        $this->conn = $db;    
    }

    public function create($user_id, $currency_code = 'USD'){
        $stmt = $this->conn->prepare("INSERT INTO wallets(user_id, currency_code) VALUES (?,?)");
        $stmt->bind_param("is", $user_id, $currency_code);
        return $stmt->execute();
    }

    public function read($user_id) {
        $stmt = $this->conn->prepare("SELECT * FROM wallets WHERE user_id = ?");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        $stmt->close();
        return $result ?: []; 
    }
    public function update($wallet_id, $balance){
        $stmt = $this->conn->prepare("UPDATE wallets SET balance = ? WHERE wallet_id = ?");
        $stmt->bind_param("di", $balance, $wallet_id);
        return $stmt->execute();
    }

    public function delete($wallet_id){
        $stmt = $this->conn->prepare("DELETE FROM wallets WHERE wallet_id =?");
        $stmt->bind_param("i", $wallet_id);
        return $stmt->execute();
    }
}
?>