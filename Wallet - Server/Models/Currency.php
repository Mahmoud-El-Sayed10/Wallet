<?php
class Currency {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    public function create($currency_code, $name, $symbol) {
        $stmt = $this->db->prepare(
            "INSERT INTO currencies (currency_code, name, symbol, is_active) 
             VALUES (?, ?, ?, TRUE)"
        );
        $stmt->bind_param("sss", $currency_code, $name, $symbol);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function read($currency_code) {
        $stmt = $this->db->prepare("SELECT * FROM currencies WHERE currency_code = ?");
        $stmt->bind_param("s", $currency_code);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        return $result;
    }

    public function update($currency_code, $data) {
        $set = [];
        $params = [];
        $types = '';
        $values = [];

        if (isset($data['name'])) {
            $set[] = "name = ?";
            $types .= 's';
            $values[] = $data['name'];
        }
        if (isset($data['symbol'])) {
            $set[] = "symbol = ?";
            $types .= 's';
            $values[] = $data['symbol'];
        }
        if (isset($data['is_active'])) {
            $set[] = "is_active = ?";
            $types .= 'i';
            $values[] = $data['is_active'];
        }

        if (empty($set)) return false;

        $query = "UPDATE currencies SET " . implode(', ', $set) . " WHERE currency_code = ?";
        $types .= 's';
        $values[] = $currency_code;

        $stmt = $this->db->prepare($query);
        $stmt->bind_param($types, ...$values);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function delete($currency_code) {
        $stmt = $this->db->prepare("DELETE FROM currencies WHERE currency_code = ?");
        $stmt->bind_param("s", $currency_code);
        $success = $stmt->execute();
        $stmt->close();
        return $success;
    }

    public function getAll() {
        $result = $this->db->query("SELECT * FROM currencies");
        $currencies = $result->fetch_all(MYSQLI_ASSOC);
        $result->close();
        return $currencies;
    }
}
?>