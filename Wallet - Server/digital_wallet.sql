CREATE DATABASE IF NOT EXISTS digital_wallet;
USE digital_wallet;

-- Table: users
-- Description: Table to store user information
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255), 
    google_id VARCHAR(255) UNIQUE, -- Used for Google login
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