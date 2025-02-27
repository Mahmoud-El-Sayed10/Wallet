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
-- Description: Stores user account details, including support for Google Authentication.
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
--Description: Stores admin accounts for managing the platform.
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
-- Description: Represents user wallets, each tied to a specific currency.
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
-- Description: Stores real-time exchange rates for currency conversion, updated via external API.
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

-- Table: Account limits
-- Description: Stores transaction limits based on user verification level and transaction type.
CREATE TABLE account_limits (
    limit_id INT AUTO_INCREMENT PRIMARY KEY,
    verification_level ENUM('UNVERIFIED', 'BASIC', 'FULL') NOT NULL,
    transaction_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER') NOT NULL,
    daily_limit DECIMAL(19, 4) NOT NULL, -- In base currency (USD)
    weekly_limit DECIMAL(19, 4) NOT NULL,
    monthly_limit DECIMAL(19, 4) NOT NULL,
    single_transaction_limit DECIMAL(19, 4) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_limit_level_type (verification_level, transaction_type)
);

-- Table: transactions
-- Description: Stores transaction details for deposits, withdrawals, transfers, payments, etc.
CREATE TABLE transactions (
    transaction_id VARCHAR(36) PRIMARY KEY,
    wallet_id INT NOT NULL,
    transaction_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER_SENT', 'TRANSFER_RECEIVED', 'PAYMENT', 'REFUND') NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    fee DECIMAL(19, 4) DEFAULT 0.0000,
    status ENUM('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED') DEFAULT 'PENDING',
    recipient_wallet_id INT NULL,
    recipient_type ENUM('USER', 'MERCHANT', 'EXTERNAL') NULL,
    source_id INT NULL,
    source_type ENUM('BANK_ACCOUNT', 'CARD', 'WALLET') NULL,
    exchange_rate_applied DECIMAL(12, 6) NOT NULL, 
    amount_in_base_currency DECIMAL(19, 4) NOT NULL,
    base_currency_code CHAR(3) DEFAULT 'USD',
    description VARCHAR(255),
    reference_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (wallet_id) REFERENCES wallets(wallet_id) ON DELETE RESTRICT,
    FOREIGN KEY (recipient_wallet_id) REFERENCES wallets(wallet_id) ON DELETE SET NULL,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    FOREIGN KEY (base_currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_wallet_id (wallet_id),
    INDEX idx_user_id_created_at ((SELECT user_id FROM wallets WHERE wallet_id = transactions.wallet_id), created_at),
    INDEX idx_created_at_status (created_at, status) 
);

-- Table: Bank Accounts
-- Description: Stores user bank account details for ACH transactions.
CREATE TABLE bank_accounts (
    bank_account_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    account_nickname VARCHAR(100),
    account_holder_name VARCHAR(255) NOT NULL,
    bank_name VARCHAR(255) NOT NULL,
    account_number VARCHAR(255) NOT NULL,
    routing_number VARCHAR(255) NOT NULL,
    account_type ENUM('CHECKING', 'SAVINGS', 'OTHER') NOT NULL,
    currency_code CHAR(3) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    status ENUM('ACTIVE', 'INACTIVE', 'PENDING') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_user_id (user_id)
);

-- Table: Payment Cards
-- Description: Stores user payment card details for card transactions.
CREATE TABLE payment_cards (
    card_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    card_nickname VARCHAR(100),
    cardholder_name VARCHAR(255) NOT NULL,
    card_number_last_four CHAR(4) NOT NULL,
    card_type ENUM('VISA', 'MASTERCARD', 'AMEX', 'DISCOVER', 'OTHER') NOT NULL,
    expiry_month TINYINT NOT NULL CHECK (expiry_month BETWEEN 1 AND 12),
    expiry_year SMALLINT NOT NULL CHECK (expiry_year >= YEAR(CURRENT_DATE)),
    billing_address_line1 VARCHAR(255),
    billing_address_line2 VARCHAR(255),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_postal_code VARCHAR(20),
    billing_country VARCHAR(100),
    currency_code CHAR(3) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    status ENUM('ACTIVE', 'INACTIVE', 'EXPIRED', 'BLOCKED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_user_id (user_id)
);

-- Table: Verfication Documents
-- Description: Stores user verification documents for KYC/AML compliance.
CREATE TABLE verification_documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    document_type ENUM('ID_CARD', 'PASSPORT', 'DRIVERS_LICENSE', 'UTILITY_BILL', 'OTHER') NOT NULL,
    document_path VARCHAR(255) NOT NULL,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verification_status ENUM('PENDING', 'VERIFIED', 'REJECTED') DEFAULT 'PENDING',
    verified_by INT NULL,
    verification_date TIMESTAMP NULL,
    rejection_reason VARCHAR(255) NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES admins(admin_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id)
);

-- Table: Recurring Payments
-- Description: Stores recurring payment details for subscriptions, bill payments, etc.
CREATE TABLE recurring_payments (
    recurring_payment_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    recipient_wallet_id INT NULL,
    recipient_type ENUM('USER', 'MERCHANT', 'EXTERNAL') NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    frequency ENUM('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    next_payment_date DATE NOT NULL,
    last_payment_date DATE NULL,
    description VARCHAR(255),
    status ENUM('ACTIVE', 'PAUSED', 'CANCELLED', 'COMPLETED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_wallet_id) REFERENCES wallets(wallet_id) ON DELETE SET NULL,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_next_payment_date (next_payment_date)
);

-- Table: QR Codes
-- Description: Stores QR codes for payments, with support for single-use and expiry.
CREATE TABLE qr_codes (
    qr_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    wallet_id INT NOT NULL,
    amount DECIMAL(19, 4) NULL,
    currency_code CHAR(3) NOT NULL,
    description VARCHAR(255) NULL,
    qr_code_path VARCHAR(255) NOT NULL,
    expiry_date TIMESTAMP NULL,
    is_single_use BOOLEAN DEFAULT FALSE,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (wallet_id) REFERENCES wallets(wallet_id) ON DELETE CASCADE,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_wallet_id (wallet_id)
);

-- Table: Password Reset Tokens
-- Description: Stores tokens for password reset requests, with expiry and usage status.
CREATE TABLE password_reset_tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_token (token)
);

-- Table: Notifications
-- Description: Stores notifications for users, with support for different types and channels.
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('TRANSACTION', 'SECURITY', 'ACCOUNT', 'PROMOTIONAL', 'OTHER') NOT NULL,
    channel ENUM('EMAIL', 'PUSH', 'SMS') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id_created_at (user_id, created_at)
);

-- Table: API Keys
-- Description: Stores API keys for user accounts, with permissions and usage tracking.
CREATE TABLE api_keys (
    api_key_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    api_key VARCHAR(255) UNIQUE NOT NULL,
    api_secret VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    permissions JSON NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_used TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_api_key (api_key)
);

-- Table: Support Tickets
-- Description: Stores support tickets raised by users, with status and assigned admin.
CREATE TABLE support_tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    ticket_type ENUM('ACCOUNT', 'TRANSACTION', 'TECHNICAL', 'SUGGESTION', 'OTHER') NOT NULL,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
    status ENUM('OPEN', 'IN_PROGRESS', 'WAITING_USER', 'RESOLVED', 'CLOSED') DEFAULT 'OPEN',
    assigned_to INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    closed_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES admins(admin_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
);

-- Table: Ticket Responses
-- Description: Stores responses to support tickets, with attachments if needed.
CREATE TABLE ticket_responses (
    response_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    responder_id INT NOT NULL,
    responder_type ENUM('USER', 'ADMIN') NOT NULL,
    message TEXT NOT NULL,
    attachment_path VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(ticket_id) ON DELETE CASCADE,
    INDEX idx_ticket_id (ticket_id)
);

-- Table: System Logs
-- Description: Stores logs for system events, errors, warnings, etc.
CREATE TABLE system_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    log_level ENUM('INFO', 'WARNING', 'ERROR', 'CRITICAL') NOT NULL,
    source VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    context JSON NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    user_id INT NULL,
    admin_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id) ON DELETE SET NULL,
    INDEX idx_created_at (created_at),
    INDEX idx_user_id (user_id),
    INDEX idx_admin_id (admin_id)
);

-- Table: API Request Logs
-- Description: Stores logs of API requests made by users, with request and response details.
CREATE TABLE api_request_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    api_key_id INT NULL,
    endpoint VARCHAR(255) NOT NULL,
    method ENUM('GET', 'POST', 'PUT', 'DELETE') NOT NULL,
    status_code SMALLINT NOT NULL,
    request_body JSON NULL,
    response_body JSON NULL,
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT NULL,
    processing_time INT NULL,
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (api_key_id) REFERENCES api_keys(api_key_id) ON DELETE SET NULL,
    INDEX idx_request_time (request_time)
);

-- Table: Analytics Events
-- Description: Stores various events for analytics and tracking purposes.
CREATE TABLE analytics_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_type ENUM('USER_SIGNUP', 'TRANSACTION', 'DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'API_REQUEST', 'SUPPORT_TICKET') NOT NULL,
    event_data JSON NOT NULL,
    user_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_event_type_created_at (event_type, created_at)
);


-- Default Data --
-- Default Currencies
INSERT INTO currencies (currency_code, name, symbol, is_active) VALUES
('USD', 'United States Dollar', '$', TRUE),
('EUR', 'Euro', '€', TRUE),
('GBP', 'British Pound Sterling', '£', TRUE),
('JPY', 'Japanese Yen', '¥', TRUE),
('CAD', 'Canadian Dollar', '$', TRUE),
('AUD', 'Australian Dollar', '$', TRUE);

-- Default Exchange Rates (Example values, to be updated real-time(if possible))
INSERT INTO exchange_rates (base_currency_code, target_currency_code, exchange_rate, source) VALUES
('USD', 'EUR', 0.850000, 'MANUAL'),
('USD', 'GBP', 0.730000, 'MANUAL'),
('USD', 'JPY', 145.000000, 'MANUAL'),
('USD', 'CAD', 1.350000, 'MANUAL'),
('USD', 'AUD', 1.500000, 'MANUAL');

-- Default Account Limits (Global in USD)
INSERT INTO account_limits (verification_level, transaction_type, daily_limit, weekly_limit, monthly_limit, single_transaction_limit) VALUES
('UNVERIFIED', 'DEPOSIT', 500.00, 1000.00, 2000.00, 200.00),
('UNVERIFIED', 'WITHDRAWAL', 300.00, 600.00, 1500.00, 200.00),
('UNVERIFIED', 'TRANSFER', 300.00, 600.00, 1500.00, 200.00),
('BASIC', 'DEPOSIT', 2000.00, 5000.00, 10000.00, 1000.00),
('BASIC', 'WITHDRAWAL', 1000.00, 3000.00, 7000.00, 1000.00),
('BASIC', 'TRANSFER', 1000.00, 3000.00, 7000.00, 1000.00),
('FULL', 'DEPOSIT', 10000.00, 20000.00, 50000.00, 5000.00),
('FULL', 'WITHDRAWAL', 5000.00, 10000.00, 25000.00, 5000.00),
('FULL', 'TRANSFER', 5000.00, 10000.00, 25000.00, 5000.00);

-- Default Super Admin
INSERT INTO admins (username, email, password_hash, first_name, last_name, role) 
VALUES ('admin', 'admin@digitalwallet.com', '$2y$10$92Ii80t1QWNqKkPQUVG10OFmNzVUOD99lfA2KIPYzsEAIKbXQX.6i', 'System', 'Administrator', 'SUPER_ADMIN');