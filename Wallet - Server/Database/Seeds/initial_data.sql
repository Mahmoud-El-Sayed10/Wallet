INSERT INTO currencies (currency_code, name, symbol, is_active) VALUES
('USD', 'United States Dollar', '$', TRUE),
('EUR', 'Euro', '€', TRUE),
('GBP', 'British Pound Sterling', '£', TRUE),
('JPY', 'Japanese Yen', '¥', TRUE),
('CAD', 'Canadian Dollar', '$', TRUE),
('AUD', 'Australian Dollar', '$', TRUE);

INSERT INTO exchange_rates (rate_id, base_currency_code, target_currency_code, exchange_rate, source) VALUES
(1, 'USD', 'EUR', 0.85, 'Fixed'),
(2, 'USD', 'GBP', 0.73, 'Fixed'),
(3, 'USD', 'JPY', 145.00, 'Fixed'),
(4, 'USD', 'CAD', 1.35, 'Fixed'),
(5, 'USD', 'AUD', 1.50, 'Fixed');

INSERT INTO timestamps (entity_type, entity_id, created_at, updated_at) VALUES
('EXCHANGE_RATE', 1, NOW(), NOW()),
('EXCHANGE_RATE', 2, NOW(), NOW()),
('EXCHANGE_RATE', 3, NOW(), NOW()),
('EXCHANGE_RATE', 4, NOW(), NOW()),
('EXCHANGE_RATE', 5, NOW(), NOW());

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

INSERT INTO admins (admin_id, username, email, password_hash, first_name, last_name, role) 
VALUES (1, 'admin', 'admin@digitalwallet.com', '$2y$10$92Ii80t1QWNqKkPQUVG10OFmNzVUOD99lfA2KIPYzsEAIKbXQX.6i', 'System', 'Administrator', 'SUPER_ADMIN');

INSERT INTO timestamps (entity_type, entity_id, created_at, updated_at) VALUES
('ADMIN', 1, NOW(), NOW());