CREATE DATABASE IF NOT EXISTS digital_wallet;
USE digital_wallet;

-- Table: currencies
-- Description: Table to store currency information
CREATE TABLE currencies (
    currency_code CHAR(3) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    symbol CHAR(3) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- Table: users
-- Description: Table to store user information
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255),
    google_id VARCHAR(255) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    profile_image VARCHAR(255),
    verification_level ENUM('UNVERIFIED', 'BASIC', 'FULL') DEFAULT 'UNVERIFIED',
    account_status ENUM('ACTIVE', 'SUSPENDED', 'BLOCKED') DEFAULT 'ACTIVE',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_phone_number (phone_number),
    INDEX idx_google_id (google_id)
);

--Table: admins
--Description: Table to store admin information
CREATE TABLE admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role ENUM('SUPER_ADMIN', 'ADMIN', 'SUPPORT', 'VIEWER') NOT NULL,
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED') DEFAULT 'ACTIVE',
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username)
);

-- Table: wallets
CREATE TABLE wallets (
    wallet_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    balance DECIMAL(19, 4) DEFAULT 0.0000,
    currency_code CHAR(3) NOT NULL,
    wallet_status ENUM('ACTIVE', 'SUSPENDED', 'CLOSED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_user_id (user_id)
);

-- Table: exchange rates
CREATE TABLE exchange_rates (
    rate_id INT AUTO_INCREMENT PRIMARY KEY,
    base_currency_code CHAR(3) NOT NULL,
    target_currency_code CHAR(3) NOT NULL,
    exchange_rate DECIMAL(12, 6) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    source VARCHAR(50) NOT NULL,
    FOREIGN KEY (base_currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    FOREIGN KEY (target_currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    UNIQUE KEY unique_rate_pair (base_currency_code, target_currency_code),
    INDEX idx_last_updated (last_updated)
);