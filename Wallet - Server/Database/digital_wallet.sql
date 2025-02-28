CREATE DATABASE IF NOT EXISTS digital_wallet;
USE digital_wallet;

-- Table: timestamps
-- Description: Stores creation and update timestamps for all entities to reduce redundancy.
CREATE TABLE timestamps (
    timestamp_id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type ENUM('USER', 'ADMIN', 'WALLET', 'TRANSACTION', 'BANK_ACCOUNT', 'PAYMENT_CARD', 
                     'VERIFICATION_DOCUMENT', 'RECURRING_PAYMENT', 'QR_CODE', 'NOTIFICATION', 
                     'API_KEY', 'SUPPORT_TICKET', 'TICKET_RESPONSE', 'SYSTEM_LOG', 'API_REQUEST_LOG', 
                     'ANALYTICS_EVENT', 'EXCHANGE_RATE', 'ACCOUNT_LIMIT') NOT NULL,
    entity_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_entity (entity_type, entity_id)
);

-- Table: currencies
-- Description: Stores supported currencies with ISO 4217 codes (e.g., USD, EUR) for multi-currency transactions.
CREATE TABLE currencies (
    currency_code CHAR(3) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    symbol CHAR(3) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Table: users
-- Description: Stores core user account details, including support for Google Authentication.
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255),
    google_id VARCHAR(255) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    verification_level ENUM('UNVERIFIED', 'BASIC', 'FULL') DEFAULT 'UNVERIFIED',
    account_status ENUM('ACTIVE', 'SUSPENDED', 'BLOCKED') DEFAULT 'ACTIVE',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_phone_number (phone_number),
    INDEX idx_google_id (google_id)
);

-- Table: user_profiles
-- Description: Stores optional user profile details like address and image.
CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    profile_image VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Table: admins
-- Description: Stores admin accounts for managing the platform.
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
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_user_id (user_id)
);

-- Table: exchange_rates
-- Description: Stores real-time exchange rates for currency conversion, updated via external API.
CREATE TABLE exchange_rates (
    rate_id INT AUTO_INCREMENT PRIMARY KEY,
    base_currency_code CHAR(3) NOT NULL,
    target_currency_code CHAR(3) NOT NULL,
    exchange_rate DECIMAL(12, 6) NOT NULL,
    source VARCHAR(50) NOT NULL,
    FOREIGN KEY (base_currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    FOREIGN KEY (target_currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    UNIQUE KEY unique_rate_pair (base_currency_code, target_currency_code)
);

-- Table: account_limits
-- Description: Defines global transaction limits in USD, applied across all currencies after conversion.
CREATE TABLE account_limits (
    limit_id INT AUTO_INCREMENT PRIMARY KEY,
    verification_level ENUM('UNVERIFIED', 'BASIC', 'FULL') NOT NULL,
    transaction_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER') NOT NULL,
    daily_limit DECIMAL(19, 4) NOT NULL,
    weekly_limit DECIMAL(19, 4) NOT NULL,
    monthly_limit DECIMAL(19, 4) NOT NULL,
    single_transaction_limit DECIMAL(19, 4) NOT NULL,
    UNIQUE KEY unique_limit_level_type (verification_level, transaction_type)
);

-- Table: transactions
-- Description: Records all wallet transactions, optimized for admin history views with global limit enforcement.
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
    FOREIGN KEY (wallet_id) REFERENCES wallets(wallet_id) ON DELETE RESTRICT,
    FOREIGN KEY (recipient_wallet_id) REFERENCES wallets(wallet_id) ON DELETE SET NULL,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    FOREIGN KEY (base_currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_wallet_id (wallet_id)
);

-- Table: bank_accounts
-- Description: Stores user's linked bank accounts for deposits and withdrawals.
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
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_user_id (user_id)
);

-- Table: payment_cards
-- Description: Stores user's linked payment cards for deposits and payments.
CREATE TABLE payment_cards (
    card_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    card_nickname VARCHAR(100),
    cardholder_name VARCHAR(255) NOT NULL,
    card_number_last_four CHAR(4) NOT NULL,
    card_type ENUM('VISA', 'MASTERCARD', 'AMEX', 'DISCOVER', 'OTHER') NOT NULL,
    expiry_month TINYINT NOT NULL CHECK (expiry_month BETWEEN 1 AND 12),
    expiry_year SMALLINT NOT NULL,
    currency_code CHAR(3) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    status ENUM('ACTIVE', 'INACTIVE', 'EXPIRED', 'BLOCKED') DEFAULT 'ACTIVE',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_user_id (user_id)
);

-- Table: card_billing_addresses
-- Description: Stores optional billing address details for payment cards.
CREATE TABLE card_billing_addresses (
    card_id INT PRIMARY KEY,
    billing_address_line1 VARCHAR(255),
    billing_address_line2 VARCHAR(255),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_postal_code VARCHAR(20),
    billing_country VARCHAR(100),
    FOREIGN KEY (card_id) REFERENCES payment_cards(card_id) ON DELETE CASCADE
);

-- Table: verification_documents
-- Description: Stores passport or ID documents for user identity verification; verification_level remains UNVERIFIED until approved.
CREATE TABLE verification_documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    document_type ENUM('PASSPORT', 'ID_CARD') NOT NULL,
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

-- Table: recurring_payments
-- Description: Manages scheduled or recurring payments set by users.
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
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_wallet_id) REFERENCES wallets(wallet_id) ON DELETE SET NULL,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_next_payment_date (next_payment_date)
);

-- Table: qr_codes
-- Description: Stores QR codes for seamless payments or transfers.
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
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (wallet_id) REFERENCES wallets(wallet_id) ON DELETE CASCADE,
    FOREIGN KEY (currency_code) REFERENCES currencies(currency_code) ON DELETE RESTRICT,
    INDEX idx_wallet_id (wallet_id)
);

-- Table: password_reset_tokens
-- Description: Stores tokens for password reset requests.
CREATE TABLE password_reset_tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_token (token)
);

-- Table: notifications
-- Description: Stores user notifications for transactions, security, etc.
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('TRANSACTION', 'SECURITY', 'ACCOUNT', 'PROMOTIONAL', 'OTHER') NOT NULL,
    channel ENUM('EMAIL', 'PUSH', 'SMS') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
);

-- Table: api_keys
-- Description: Stores API keys for third-party integrations.
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
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_api_key (api_key)
);

-- Table: support_tickets
-- Description: Manages user support tickets for inquiries and issues.
CREATE TABLE support_tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    ticket_type ENUM('ACCOUNT', 'TRANSACTION', 'TECHNICAL', 'SUGGESTION', 'OTHER') NOT NULL,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
    status ENUM('OPEN', 'IN_PROGRESS', 'WAITING_USER', 'RESOLVED', 'CLOSED') DEFAULT 'OPEN',
    assigned_to INT NULL,
    closed_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES admins(admin_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
);

-- Table: ticket_responses
-- Description: Stores responses to support tickets from users or admins.
CREATE TABLE ticket_responses (
    response_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    responder_id INT NOT NULL,
    responder_type ENUM('USER', 'ADMIN') NOT NULL,
    message TEXT NOT NULL,
    attachment_path VARCHAR(255) NULL,
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(ticket_id) ON DELETE CASCADE,
    INDEX idx_ticket_id (ticket_id)
);

-- Table: system_logs
-- Description: Logs system events, errors, and admin actions for auditing.
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
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_admin_id (admin_id)
);

-- Table: api_request_logs
-- Description: Logs API requests for debugging and monitoring.
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
    FOREIGN KEY (api_key_id) REFERENCES api_keys(api_key_id) ON DELETE SET NULL
);

-- Table: analytics_events
-- Description: Stores events for analytics and reporting (e.g., transaction volume).
CREATE TABLE analytics_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_type ENUM('USER_SIGNUP', 'TRANSACTION', 'DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'API_REQUEST', 'SUPPORT_TICKET') NOT NULL,
    event_data JSON NOT NULL,
    user_id INT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_event_type (event_type)
);

-- Default Data
-- Default Currencies: Initial set of supported currencies.
INSERT INTO currencies (currency_code, name, symbol, is_active) VALUES
('USD', 'United States Dollar', '$', TRUE),
('EUR', 'Euro', '€', TRUE),
('GBP', 'British Pound Sterling', '£', TRUE),
('JPY', 'Japanese Yen', '¥', TRUE),
('CAD', 'Canadian Dollar', '$', TRUE),
('AUD', 'Australian Dollar', '$', TRUE);

-- Default Exchange Rates: Example exchange rates (USD base), to be updated real-time via API.
INSERT INTO exchange_rates (rate_id, base_currency_code, target_currency_code, exchange_rate, source) VALUES
(1, 'USD', 'EUR', 0.850000, 'MANUAL'),
(2, 'USD', 'GBP', 0.730000, 'MANUAL'),
(3, 'USD', 'JPY', 145.000000, 'MANUAL'),
(4, 'USD', 'CAD', 1.350000, 'MANUAL'),
(5, 'USD', 'AUD', 1.500000, 'MANUAL');

-- Default Timestamps for Exchange Rates
INSERT INTO timestamps (entity_type, entity_id, created_at, updated_at) VALUES
('EXCHANGE_RATE', 1, NOW(), NOW()),
('EXCHANGE_RATE', 2, NOW(), NOW()),
('EXCHANGE_RATE', 3, NOW(), NOW()),
('EXCHANGE_RATE', 4, NOW(), NOW()),
('EXCHANGE_RATE', 5, NOW(), NOW());

-- Default Account Limits: Global transaction limits in USD, applied across all currencies after conversion.
INSERT INTO account_limits (limit_id, verification_level, transaction_type, daily_limit, weekly_limit, monthly_limit, single_transaction_limit) VALUES
(1, 'UNVERIFIED', 'DEPOSIT', 500.00, 1000.00, 2000.00, 200.00),
(2, 'UNVERIFIED', 'WITHDRAWAL', 300.00, 600.00, 1500.00, 200.00),
(3, 'UNVERIFIED', 'TRANSFER', 300.00, 600.00, 1500.00, 200.00),
(4, 'BASIC', 'DEPOSIT', 2000.00, 5000.00, 10000.00, 1000.00),
(5, 'BASIC', 'WITHDRAWAL', 1000.00, 3000.00, 7000.00, 1000.00),
(6, 'BASIC', 'TRANSFER', 1000.00, 3000.00, 7000.00, 1000.00),
(7, 'FULL', 'DEPOSIT', 10000.00, 20000.00, 50000.00, 5000.00),
(8, 'FULL', 'WITHDRAWAL', 5000.00, 10000.00, 25000.00, 5000.00),
(9, 'FULL', 'TRANSFER', 5000.00, 10000.00, 25000.00, 5000.00);

-- Default Timestamps for Account Limits
INSERT INTO timestamps (entity_type, entity_id, created_at, updated_at) VALUES
('ACCOUNT_LIMIT', 1, NOW(), NOW()),
('ACCOUNT_LIMIT', 2, NOW(), NOW()),
('ACCOUNT_LIMIT', 3, NOW(), NOW()),
('ACCOUNT_LIMIT', 4, NOW(), NOW()),
('ACCOUNT_LIMIT', 5, NOW(), NOW()),
('ACCOUNT_LIMIT', 6, NOW(), NOW()),
('ACCOUNT_LIMIT', 7, NOW(), NOW()),
('ACCOUNT_LIMIT', 8, NOW(), NOW()),
('ACCOUNT_LIMIT', 9, NOW(), NOW());

-- Default Super Admin: Initial super admin account for system management (password: Admin@123).
INSERT INTO admins (admin_id, username, email, password_hash, first_name, last_name, role) 
VALUES (1, 'admin', 'admin@digitalwallet.com', '$2y$10$92Ii80t1QWNqKkPQUVG10OFmNzVUOD99lfA2KIPYzsEAIKbXQX.6i', 'System', 'Administrator', 'SUPER_ADMIN');

-- Default Timestamp for Super Admin
INSERT INTO timestamps (entity_type, entity_id, created_at, updated_at) VALUES
('ADMIN', 1, NOW(), NOW());