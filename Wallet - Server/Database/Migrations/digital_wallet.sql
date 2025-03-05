-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 05, 2025 at 06:33 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `digital_wallet`
--

-- --------------------------------------------------------

--
-- Table structure for table `account_limits`
--

CREATE TABLE `account_limits` (
  `limit_id` int(11) NOT NULL,
  `verification_level` enum('UNVERIFIED','BASIC','FULL') NOT NULL,
  `transaction_type` enum('DEPOSIT','WITHDRAWAL','TRANSFER') NOT NULL,
  `daily_limit` decimal(19,4) NOT NULL,
  `weekly_limit` decimal(19,4) NOT NULL,
  `monthly_limit` decimal(19,4) NOT NULL,
  `single_transaction_limit` decimal(19,4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `account_limits`
--

INSERT INTO `account_limits` (`limit_id`, `verification_level`, `transaction_type`, `daily_limit`, `weekly_limit`, `monthly_limit`, `single_transaction_limit`) VALUES
(1, 'UNVERIFIED', 'DEPOSIT', 500.0000, 1000.0000, 2000.0000, 200.0000),
(2, 'UNVERIFIED', 'WITHDRAWAL', 300.0000, 600.0000, 1500.0000, 200.0000),
(3, 'UNVERIFIED', 'TRANSFER', 300.0000, 600.0000, 1500.0000, 200.0000),
(4, 'BASIC', 'DEPOSIT', 2000.0000, 5000.0000, 10000.0000, 1000.0000),
(5, 'BASIC', 'WITHDRAWAL', 1000.0000, 3000.0000, 7000.0000, 1000.0000),
(6, 'BASIC', 'TRANSFER', 1000.0000, 3000.0000, 7000.0000, 1000.0000),
(7, 'FULL', 'DEPOSIT', 10000.0000, 20000.0000, 50000.0000, 5000.0000),
(8, 'FULL', 'WITHDRAWAL', 5000.0000, 10000.0000, 25000.0000, 5000.0000),
(9, 'FULL', 'TRANSFER', 5000.0000, 10000.0000, 25000.0000, 5000.0000);

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `admin_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `role` enum('SUPER_ADMIN','ADMIN','SUPPORT','VIEWER') NOT NULL,
  `status` enum('ACTIVE','INACTIVE','SUSPENDED') DEFAULT 'ACTIVE',
  `last_login` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`admin_id`, `username`, `email`, `password_hash`, `first_name`, `last_name`, `role`, `status`, `last_login`) VALUES
(1, 'admin', 'admin@digitalwallet.com', '$2y$10$92Ii80t1QWNqKkPQUVG10OFmNzVUOD99lfA2KIPYzsEAIKbXQX.6i', 'System', 'Administrator', 'SUPER_ADMIN', 'ACTIVE', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `analytics_events`
--

CREATE TABLE `analytics_events` (
  `event_id` int(11) NOT NULL,
  `event_type` enum('USER_SIGNUP','TRANSACTION','DEPOSIT','WITHDRAWAL','TRANSFER','API_REQUEST','SUPPORT_TICKET') NOT NULL,
  `event_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`event_data`)),
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `api_keys`
--

CREATE TABLE `api_keys` (
  `api_key_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `api_key` varchar(255) NOT NULL,
  `api_secret` varchar(255) NOT NULL,
  `name` varchar(100) NOT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`permissions`)),
  `is_active` tinyint(1) DEFAULT 1,
  `last_used` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `api_request_logs`
--

CREATE TABLE `api_request_logs` (
  `log_id` int(11) NOT NULL,
  `api_key_id` int(11) DEFAULT NULL,
  `endpoint` varchar(255) NOT NULL,
  `method` enum('GET','POST','PUT','DELETE') NOT NULL,
  `status_code` smallint(6) NOT NULL,
  `request_body` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`request_body`)),
  `response_body` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`response_body`)),
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text DEFAULT NULL,
  `processing_time` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bank_accounts`
--

CREATE TABLE `bank_accounts` (
  `bank_account_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `account_nickname` varchar(100) DEFAULT NULL,
  `account_holder_name` varchar(255) NOT NULL,
  `bank_name` varchar(255) NOT NULL,
  `account_number` varchar(255) NOT NULL,
  `routing_number` varchar(255) NOT NULL,
  `account_type` enum('CHECKING','SAVINGS','OTHER') NOT NULL,
  `currency_code` char(3) NOT NULL,
  `is_primary` tinyint(1) DEFAULT 0,
  `is_verified` tinyint(1) DEFAULT 0,
  `status` enum('ACTIVE','INACTIVE','PENDING') DEFAULT 'PENDING'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bank_accounts`
--

INSERT INTO `bank_accounts` (`bank_account_id`, `user_id`, `account_nickname`, `account_holder_name`, `bank_name`, `account_number`, `routing_number`, `account_type`, `currency_code`, `is_primary`, `is_verified`, `status`) VALUES
(4, 1, NULL, 'Mahmoud El Sayed', 'Blom', '1547689521', '112545879', 'SAVINGS', 'GBP', 0, 0, 'PENDING');

-- --------------------------------------------------------

--
-- Table structure for table `cards`
--

CREATE TABLE `cards` (
  `card_id` int(11) NOT NULL,
  `wallet_id` int(11) NOT NULL,
  `card_nickname` varchar(100) DEFAULT NULL,
  `cardholder_name` varchar(255) NOT NULL,
  `card_number_last_four` char(4) NOT NULL,
  `card_type` enum('VISA','MASTERCARD','AMEX','DISCOVER','OTHER') NOT NULL,
  `expiry_month` tinyint(4) NOT NULL CHECK (`expiry_month` between 1 and 12),
  `expiry_year` smallint(6) NOT NULL,
  `currency_code` char(3) NOT NULL,
  `is_primary` tinyint(1) DEFAULT 0,
  `status` enum('ACTIVE','INACTIVE','EXPIRED','BLOCKED') DEFAULT 'ACTIVE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cards`
--

INSERT INTO `cards` (`card_id`, `wallet_id`, `card_nickname`, `cardholder_name`, `card_number_last_four`, `card_type`, `expiry_month`, `expiry_year`, `currency_code`, `is_primary`, `status`) VALUES
(3, 4, NULL, 'TEST', '7894', 'MASTERCARD', 3, 2027, 'GBP', 1, 'ACTIVE');

-- --------------------------------------------------------

--
-- Table structure for table `currencies`
--

CREATE TABLE `currencies` (
  `currency_code` char(3) NOT NULL,
  `name` varchar(50) NOT NULL,
  `symbol` char(3) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `currencies`
--

INSERT INTO `currencies` (`currency_code`, `name`, `symbol`, `is_active`) VALUES
('AUD', 'Australian Dollar', '$', 1),
('CAD', 'Canadian Dollar', '$', 1),
('EUR', 'Euro', '€', 1),
('GBP', 'British Pound Sterling', '£', 1),
('JPY', 'Japanese Yen', '¥', 1),
('USD', 'United States Dollar', '$', 1);

-- --------------------------------------------------------

--
-- Table structure for table `exchange_rates`
--

CREATE TABLE `exchange_rates` (
  `rate_id` int(11) NOT NULL,
  `base_currency_code` char(3) NOT NULL,
  `target_currency_code` char(3) NOT NULL,
  `exchange_rate` decimal(12,6) NOT NULL,
  `source` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exchange_rates`
--

INSERT INTO `exchange_rates` (`rate_id`, `base_currency_code`, `target_currency_code`, `exchange_rate`, `source`) VALUES
(1, 'USD', 'EUR', 0.850000, 'Fixed'),
(2, 'USD', 'GBP', 0.730000, 'Fixed'),
(3, 'USD', 'JPY', 145.000000, 'Fixed'),
(4, 'USD', 'CAD', 1.350000, 'Fixed'),
(5, 'USD', 'AUD', 1.500000, 'Fixed');

-- --------------------------------------------------------

--
-- Table structure for table `external_transfers`
--

CREATE TABLE `external_transfers` (
  `transfer_id` int(11) NOT NULL,
  `transaction_id` varchar(36) NOT NULL,
  `recipient_name` varchar(255) NOT NULL,
  `account_number` varchar(255) NOT NULL,
  `bank_name` varchar(255) NOT NULL,
  `routing_number` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `login_attempts`
--

CREATE TABLE `login_attempts` (
  `attempt_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `ip_address` varchar(45) NOT NULL,
  `attempt_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `success` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `notification_type` enum('TRANSACTION','SECURITY','ACCOUNT','PROMOTIONAL','OTHER') NOT NULL,
  `channel` enum('EMAIL','PUSH','SMS') NOT NULL,
  `is_read` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `token_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_used` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `qr_codes`
--

CREATE TABLE `qr_codes` (
  `qr_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `wallet_id` int(11) NOT NULL,
  `qr_type` varchar(50) NOT NULL DEFAULT 'DEFAULT_TYPE',
  `qr_data` varchar(255) NOT NULL,
  `reference_id` varchar(36) DEFAULT NULL,
  `amount` decimal(19,4) DEFAULT NULL,
  `currency_code` char(3) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `qr_code_path` varchar(255) NOT NULL,
  `expiry_date` timestamp NULL DEFAULT NULL,
  `is_single_use` tinyint(1) DEFAULT 0,
  `is_used` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `qr_codes`
--

INSERT INTO `qr_codes` (`qr_id`, `user_id`, `wallet_id`, `qr_type`, `qr_data`, `reference_id`, `amount`, `currency_code`, `description`, `qr_code_path`, `expiry_date`, `is_single_use`, `is_used`) VALUES
(2, 1, 3, 'TRANSACTION_VERIFICATION', '5a967bb68714fc8da802316fcf20fc57', '02bc29b6-bbf6-4258-9c7b-509608e9b61b', NULL, 'GBP', NULL, '', '2025-03-06 14:54:37', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `recurring_payments`
--

CREATE TABLE `recurring_payments` (
  `recurring_payment_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `wallet_id` int(11) NOT NULL,
  `recipient_type` enum('USER','MERCHANT','EXTERNAL') NOT NULL,
  `amount` decimal(19,4) NOT NULL,
  `currency_code` char(3) NOT NULL,
  `frequency` enum('DAILY','WEEKLY','BIWEEKLY','MONTHLY','QUARTERLY','YEARLY') NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `next_payment_date` date NOT NULL,
  `last_payment_date` date DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `status` enum('ACTIVE','PAUSED','CANCELLED','COMPLETED') DEFAULT 'ACTIVE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `support_tickets`
--

CREATE TABLE `support_tickets` (
  `ticket_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `ticket_type` enum('ACCOUNT','TRANSACTION','TECHNICAL','SUGGESTION','OTHER') NOT NULL,
  `priority` enum('LOW','MEDIUM','HIGH','URGENT') DEFAULT 'MEDIUM',
  `status` enum('OPEN','IN_PROGRESS','WAITING_USER','RESOLVED','CLOSED') DEFAULT 'OPEN',
  `assigned_to` int(11) DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_logs`
--

CREATE TABLE `system_logs` (
  `log_id` int(11) NOT NULL,
  `log_level` enum('INFO','WARNING','ERROR','CRITICAL') NOT NULL,
  `source` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `context` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`context`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ticket_responses`
--

CREATE TABLE `ticket_responses` (
  `response_id` int(11) NOT NULL,
  `ticket_id` int(11) NOT NULL,
  `responder_id` int(11) NOT NULL,
  `responder_type` enum('USER','ADMIN') NOT NULL,
  `message` text NOT NULL,
  `attachment_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `timestamps`
--

CREATE TABLE `timestamps` (
  `timestamp_id` int(11) NOT NULL,
  `entity_type` enum('USER','ADMIN','WALLET','TRANSACTION','CARD','BANK_ACCOUNT','VERIFICATION_DOCUMENT','RECURRING_PAYMENT','QR_CODE','NOTIFICATION','API_KEY','SUPPORT_TICKET','TICKET_RESPONSE','SYSTEM_LOG','API_REQUEST_LOG','ANALYTICS_EVENT','EXCHANGE_RATE','ACCOUNT_LIMIT','LOGIN_ATTEMPT') NOT NULL,
  `entity_id` varchar(36) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `timestamps`
--

INSERT INTO `timestamps` (`timestamp_id`, `entity_type`, `entity_id`, `created_at`, `updated_at`) VALUES
(1, 'EXCHANGE_RATE', '1', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(2, 'EXCHANGE_RATE', '2', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(3, 'EXCHANGE_RATE', '3', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(4, 'EXCHANGE_RATE', '4', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(5, 'EXCHANGE_RATE', '5', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(6, 'ACCOUNT_LIMIT', '1', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(7, 'ACCOUNT_LIMIT', '2', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(8, 'ACCOUNT_LIMIT', '3', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(9, 'ACCOUNT_LIMIT', '4', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(10, 'ACCOUNT_LIMIT', '5', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(11, 'ACCOUNT_LIMIT', '6', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(12, 'ACCOUNT_LIMIT', '7', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(13, 'ACCOUNT_LIMIT', '8', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(14, 'ACCOUNT_LIMIT', '9', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(15, 'ADMIN', '1', '2025-03-02 20:23:54', '2025-03-02 20:23:54'),
(16, 'USER', '1', '2025-03-04 08:34:29', '2025-03-04 08:34:29'),
(20, 'TRANSACTION', 'a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6', '2025-03-03 08:00:00', '2025-03-04 12:53:44'),
(21, 'TRANSACTION', 'b2c3d4e5-f6g7-h8i9-j0k1-l2m3n4o5p6q7', '2025-03-04 07:00:00', '2025-03-04 12:53:44'),
(22, 'TRANSACTION', 'c3d4e5f6-g7h8-i9j0-k1l2-m3n4o5p6q7r8', '2025-03-04 09:00:00', '2025-03-04 12:53:44'),
(23, 'CARD', '1', '2025-03-04 13:34:41', '2025-03-04 13:34:41'),
(24, 'BANK_ACCOUNT', '1', '2025-03-04 14:17:40', '2025-03-04 14:17:40'),
(25, 'BANK_ACCOUNT', '2', '2025-03-04 14:17:59', '2025-03-04 14:17:59'),
(27, 'CARD', '2', '2025-03-04 17:21:30', '2025-03-04 17:21:30'),
(29, 'BANK_ACCOUNT', '3', '2025-03-04 18:06:53', '2025-03-04 18:06:53'),
(30, 'BANK_ACCOUNT', '4', '2025-03-04 18:43:38', '2025-03-04 18:43:38'),
(31, 'WALLET', '3', '2025-03-04 21:09:12', '2025-03-04 21:09:12'),
(32, 'WALLET', '2', '2025-03-04 21:11:09', '2025-03-04 21:11:09'),
(33, 'BANK_ACCOUNT', '5', '2025-03-04 21:18:27', '2025-03-04 21:18:27'),
(38, 'BANK_ACCOUNT', '6', '2025-03-04 21:43:29', '2025-03-04 21:43:29'),
(40, 'WALLET', '4', '2025-03-05 08:09:59', '2025-03-05 08:09:59'),
(41, 'TRANSACTION', '43480d91-7d6d-441e-9266-8bf94a534b22', '2025-03-05 11:58:41', '2025-03-05 11:58:41'),
(42, 'TRANSACTION', '9923364e-b570-4de8-a9d8-edc29f8d015b', '2025-03-05 11:58:41', '2025-03-05 11:58:41'),
(43, 'TRANSACTION', '25a954be-9302-4efe-a2b2-5ad99969f92b', '2025-03-05 12:32:50', '2025-03-05 12:32:50'),
(44, 'TRANSACTION', '225436c2-ee79-4de2-af2c-2a35d1efa693', '2025-03-05 12:32:50', '2025-03-05 12:32:50'),
(45, 'CARD', '3', '2025-03-05 12:37:10', '2025-03-05 12:37:10'),
(46, 'USER', '2', '2025-03-05 12:53:39', '2025-03-05 12:53:39'),
(47, 'WALLET', '46', '2025-03-05 12:53:39', '2025-03-05 12:53:39'),
(48, 'WALLET', '6', '2025-03-05 12:53:40', '2025-03-05 12:53:40'),
(49, 'TRANSACTION', '0303540d-9290-463b-9dec-c864cf798c8d', '2025-03-05 12:54:59', '2025-03-05 12:54:59'),
(50, 'TRANSACTION', 'd732428c-e3a2-46b2-9851-84213ad57c56', '2025-03-05 12:54:59', '2025-03-05 12:54:59'),
(51, 'TRANSACTION', '188066aa-0505-42c8-bb53-fd1cc9e921ed', '2025-03-05 12:55:33', '2025-03-05 12:55:33'),
(52, 'TRANSACTION', '8539f8a2-3a41-49b5-bdf6-0ff3c0ecc4c5', '2025-03-05 12:55:33', '2025-03-05 12:55:33'),
(53, 'TRANSACTION', '9322a81f-e774-4b9f-bcc8-e19149d8caf3', '2025-03-05 14:35:58', '2025-03-05 14:35:58'),
(54, 'TRANSACTION', 'cc4b0049-c3b0-4cb0-999a-58f794bdaabc', '2025-03-05 14:35:58', '2025-03-05 14:35:58'),
(55, 'TRANSACTION', '1cd724b4-1b3d-4fb7-b047-f069cec6da32', '2025-03-05 14:46:31', '2025-03-05 14:46:31'),
(56, 'TRANSACTION', 'f99691d4-ec61-4a62-97db-e4d954159152', '2025-03-05 14:46:31', '2025-03-05 14:46:31'),
(57, 'TRANSACTION', '1899af9f-4ccc-4a5e-ba7c-fff9e50a3214', '2025-03-05 14:52:54', '2025-03-05 14:52:54'),
(58, 'TRANSACTION', '318aaba0-dcd7-470c-9a35-823e9c4591c2', '2025-03-05 14:52:54', '2025-03-05 14:52:54'),
(59, 'TRANSACTION', '02bc29b6-bbf6-4258-9c7b-509608e9b61b', '2025-03-05 14:54:37', '2025-03-05 14:54:37'),
(60, 'TRANSACTION', '24213154-fa5f-46d6-b351-ed0bef1015f2', '2025-03-05 14:54:37', '2025-03-05 14:54:37'),
(61, 'TRANSACTION', '5871d1ce-d8ce-4d01-9012-4380e916d2dc', '2025-03-05 14:57:35', '2025-03-05 14:57:35'),
(62, 'TRANSACTION', 'b0c31db7-82fa-4ba6-9e11-8441c0f895c8', '2025-03-05 14:57:35', '2025-03-05 14:57:35'),
(63, 'TRANSACTION', '2a408189-b0b5-4570-80d8-fdc3845d06e1', '2025-03-05 14:57:51', '2025-03-05 14:57:51'),
(64, 'TRANSACTION', '3ff080a4-eda5-45d7-a9ea-0efc8bec7e32', '2025-03-05 14:57:51', '2025-03-05 14:57:51'),
(65, 'TRANSACTION', '85b15987-4d08-45a3-90b7-687d50e916c9', '2025-03-05 15:02:07', '2025-03-05 15:02:07'),
(66, 'TRANSACTION', '1b51b231-6638-466c-bfde-d1af0aeb8fbc', '2025-03-05 15:02:07', '2025-03-05 15:02:07'),
(67, 'TRANSACTION', 'f431205d-862a-47b1-acde-d8d1b9c3b42b', '2025-03-05 15:05:12', '2025-03-05 15:05:12'),
(68, 'TRANSACTION', 'd6db415a-02cc-47b4-b5c5-a3d190f266fe', '2025-03-05 15:05:12', '2025-03-05 15:05:12'),
(69, 'USER', '3', '2025-03-05 16:43:18', '2025-03-05 16:43:18'),
(70, 'USER', '4', '2025-03-05 16:45:52', '2025-03-05 16:45:52'),
(71, 'USER', '5', '2025-03-05 16:47:57', '2025-03-05 16:47:57');

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `transaction_id` varchar(36) NOT NULL,
  `wallet_id` int(11) NOT NULL,
  `transaction_type` enum('DEPOSIT','WITHDRAWAL','TRANSFER_SENT','TRANSFER_RECEIVED','PAYMENT','REFUND') NOT NULL,
  `amount` decimal(19,4) NOT NULL,
  `currency_code` char(3) NOT NULL,
  `fee` decimal(19,4) DEFAULT 0.0000,
  `status` enum('PENDING','COMPLETED','FAILED','CANCELLED') DEFAULT 'PENDING',
  `recipient_wallet_id` int(11) DEFAULT NULL,
  `recipient_type` enum('USER','MERCHANT','EXTERNAL') DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `source_type` enum('BANK_ACCOUNT','CARD','WALLET') DEFAULT NULL,
  `exchange_rate_applied` decimal(12,6) NOT NULL,
  `amount_in_base_currency` decimal(19,4) NOT NULL,
  `base_currency_code` char(3) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `reference_id` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`transaction_id`, `wallet_id`, `transaction_type`, `amount`, `currency_code`, `fee`, `status`, `recipient_wallet_id`, `recipient_type`, `source_id`, `source_type`, `exchange_rate_applied`, `amount_in_base_currency`, `base_currency_code`, `description`, `reference_id`) VALUES
('02bc29b6-bbf6-4258-9c7b-509608e9b61b', 3, 'TRANSFER_SENT', 30.0000, '0', 0.0000, 'COMPLETED', 1, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('0303540d-9290-463b-9dec-c864cf798c8d', 1, 'TRANSFER_SENT', 100.0000, 'USD', 0.0000, 'COMPLETED', 5, NULL, NULL, NULL, 0.000000, 0.0000, NULL, ' (To User: 2)', NULL),
('188066aa-0505-42c8-bb53-fd1cc9e921ed', 4, 'TRANSFER_SENT', 90.0000, 'USD', 0.0000, 'COMPLETED', 5, NULL, NULL, NULL, 0.000000, 0.0000, NULL, ' (To User: 2)', NULL),
('1899af9f-4ccc-4a5e-ba7c-fff9e50a3214', 1, 'TRANSFER_SENT', 22.0000, '0', 0.0000, 'COMPLETED', 3, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('1b51b231-6638-466c-bfde-d1af0aeb8fbc', 1, 'TRANSFER_RECEIVED', 49.0000, '0', 0.0000, 'COMPLETED', 3, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('1cd724b4-1b3d-4fb7-b047-f069cec6da32', 1, 'TRANSFER_SENT', 35.0000, '0', 0.0000, 'COMPLETED', 3, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('225436c2-ee79-4de2-af2c-2a35d1efa693', 3, 'TRANSFER_RECEIVED', 117.6000, 'GBP', 0.0000, 'COMPLETED', 1, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('24213154-fa5f-46d6-b351-ed0bef1015f2', 1, 'TRANSFER_RECEIVED', 29.4000, '0', 0.0000, 'COMPLETED', 3, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('25a954be-9302-4efe-a2b2-5ad99969f92b', 1, 'TRANSFER_SENT', 120.0000, 'USD', 2.0000, 'COMPLETED', 3, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('2a408189-b0b5-4570-80d8-fdc3845d06e1', 1, 'TRANSFER_SENT', 20.0000, '0', 0.0000, 'COMPLETED', 3, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('318aaba0-dcd7-470c-9a35-823e9c4591c2', 3, 'TRANSFER_RECEIVED', 21.5600, '0', 0.0000, 'COMPLETED', 1, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('3ff080a4-eda5-45d7-a9ea-0efc8bec7e32', 3, 'TRANSFER_RECEIVED', 19.6000, '0', 0.0000, 'COMPLETED', 1, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('43480d91-7d6d-441e-9266-8bf94a534b22', 1, 'TRANSFER_SENT', 100.0000, 'USD', 0.0000, 'COMPLETED', 4, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('5871d1ce-d8ce-4d01-9012-4380e916d2dc', 1, 'TRANSFER_SENT', 20.0000, '0', 0.0000, 'COMPLETED', 3, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('8539f8a2-3a41-49b5-bdf6-0ff3c0ecc4c5', 5, 'TRANSFER_RECEIVED', 90.0000, 'USD', 0.0000, 'COMPLETED', 4, NULL, NULL, NULL, 0.000000, 0.0000, NULL, ' (To User: 2)', NULL),
('85b15987-4d08-45a3-90b7-687d50e916c9', 3, 'TRANSFER_SENT', 50.0000, '0', 1.0000, 'COMPLETED', 1, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('9322a81f-e774-4b9f-bcc8-e19149d8caf3', 1, 'TRANSFER_SENT', 57.0000, '0', 0.0000, 'COMPLETED', 4, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('9923364e-b570-4de8-a9d8-edc29f8d015b', 4, 'TRANSFER_RECEIVED', 100.0000, 'USD', 0.0000, 'COMPLETED', 1, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6', 1, 'DEPOSIT', 300.0000, 'USD', 0.0000, 'COMPLETED', NULL, NULL, NULL, NULL, 1.000000, 300.0000, 'USD', 'Initial deposit', 'REF001'),
('b0c31db7-82fa-4ba6-9e11-8441c0f895c8', 3, 'TRANSFER_RECEIVED', 19.6000, '0', 0.0000, 'COMPLETED', 1, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('b2c3d4e5-f6g7-h8i9-j0k1-l2m3n4o5p6q7', 1, 'WITHDRAWAL', 50.0000, 'USD', 1.0000, 'COMPLETED', NULL, NULL, NULL, NULL, 1.000000, 50.0000, 'USD', 'Cash withdrawal', 'REF002'),
('c3d4e5f6-g7h8-i9j0-k1l2-m3n4o5p6q7r8', 1, '', 100.0000, 'USD', 0.5000, 'PENDING', NULL, '', 1, 'WALLET', 1.000000, 100.0000, 'USD', 'Transfer to savings', 'REF003'),
('cc4b0049-c3b0-4cb0-999a-58f794bdaabc', 4, 'TRANSFER_RECEIVED', 57.0000, '0', 0.0000, 'COMPLETED', 1, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('d6db415a-02cc-47b4-b5c5-a3d190f266fe', 1, 'TRANSFER_RECEIVED', 49.0000, '0', 0.0000, 'COMPLETED', 3, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('d732428c-e3a2-46b2-9851-84213ad57c56', 5, 'TRANSFER_RECEIVED', 100.0000, 'USD', 0.0000, 'COMPLETED', 1, NULL, NULL, NULL, 0.000000, 0.0000, NULL, ' (To User: 2)', NULL),
('f431205d-862a-47b1-acde-d8d1b9c3b42b', 3, 'TRANSFER_SENT', 50.0000, '0', 1.0000, 'COMPLETED', 1, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL),
('f99691d4-ec61-4a62-97db-e4d954159152', 3, 'TRANSFER_RECEIVED', 34.3000, '0', 0.0000, 'COMPLETED', 1, NULL, NULL, NULL, 0.000000, 0.0000, NULL, '', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `date_of_birth` date NOT NULL,
  `verification_level` enum('UNVERIFIED','BASIC','FULL') DEFAULT 'UNVERIFIED',
  `account_status` enum('ACTIVE','SUSPENDED','BLOCKED') DEFAULT 'ACTIVE',
  `registration_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `email`, `phone_number`, `password_hash`, `first_name`, `last_name`, `date_of_birth`, `verification_level`, `account_status`, `registration_date`, `last_login`) VALUES
(1, 'test@example.com', NULL, '$2y$10$DkLppRJ/gbAwKviwRTfH1uB.QBgZtfere.L3lkV49L30KlI8UtWX.', 'Test', 'user', '1990-01-01', 'UNVERIFIED', 'ACTIVE', '2025-03-04 08:34:29', NULL),
(2, 'testuser@example.com', NULL, '$2y$10$abcdefghijklmnopqrstuuWVVVfnOpLFxSr3/PJ1NaIEA4L2Rqmq', 'Test', 'User', '1990-01-01', 'BASIC', 'ACTIVE', '2025-03-05 12:53:39', NULL),
(3, 'mahmoud.a.elsayed@gmail.com', NULL, '$2y$10$i2YkMtpmSHugKzRQABKpPuqcrKUIJ4IPfguaErrrUo12hSDPctnvq', 'Mahmoud', 'El Sayed', '1999-12-09', 'UNVERIFIED', 'ACTIVE', '2025-03-05 16:43:18', NULL),
(4, 'Tester@example.com', NULL, '$2y$10$jpW9mlrsBc6lIXxf.gCU6ODxXnLOmDm1wrsNPH4RFctBxJdaL9CUO', 'Testest', 'testest', '1999-12-09', 'UNVERIFIED', 'ACTIVE', '2025-03-05 16:45:52', NULL),
(5, 'Test3@example.com', NULL, '$2y$10$66mJ1r3rTBkoQN4Sg3WJSOKuXwgr8VcXlN3dnY1.I4HdFQGbzHCh2', 'Test3', 'Test3', '2000-04-05', 'UNVERIFIED', 'ACTIVE', '2025-03-05 16:47:57', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `verification_documents`
--

CREATE TABLE `verification_documents` (
  `document_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `document_type` enum('PASSPORT','ID_CARD') NOT NULL,
  `document_path` varchar(255) NOT NULL,
  `upload_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `verification_status` enum('PENDING','VERIFIED','REJECTED') DEFAULT 'PENDING',
  `verified_by` int(11) DEFAULT NULL,
  `verification_date` timestamp NULL DEFAULT NULL,
  `rejection_reason` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wallets`
--

CREATE TABLE `wallets` (
  `wallet_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `balance` decimal(19,4) DEFAULT 0.0000,
  `currency_code` char(3) NOT NULL,
  `wallet_status` enum('ACTIVE','SUSPENDED','CLOSED') DEFAULT 'ACTIVE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `wallets`
--

INSERT INTO `wallets` (`wallet_id`, `user_id`, `balance`, `currency_code`, `wallet_status`) VALUES
(1, 1, 153.4000, 'USD', 'ACTIVE'),
(3, 1, 82.6600, 'GBP', 'ACTIVE'),
(4, 1, 67.0000, 'USD', 'ACTIVE'),
(5, 2, 690.0000, 'USD', 'ACTIVE'),
(6, 2, 400.0000, 'EUR', 'ACTIVE'),
(7, 3, 0.0000, 'USD', 'ACTIVE'),
(8, 4, 0.0000, 'USD', 'ACTIVE'),
(9, 5, 0.0000, 'USD', 'ACTIVE');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `account_limits`
--
ALTER TABLE `account_limits`
  ADD PRIMARY KEY (`limit_id`),
  ADD UNIQUE KEY `unique_limit_level_type` (`verification_level`,`transaction_type`);

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_username` (`username`);

--
-- Indexes for table `analytics_events`
--
ALTER TABLE `analytics_events`
  ADD PRIMARY KEY (`event_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_event_type` (`event_type`);

--
-- Indexes for table `api_keys`
--
ALTER TABLE `api_keys`
  ADD PRIMARY KEY (`api_key_id`),
  ADD UNIQUE KEY `api_key` (`api_key`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_api_key` (`api_key`);

--
-- Indexes for table `api_request_logs`
--
ALTER TABLE `api_request_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `api_key_id` (`api_key_id`);

--
-- Indexes for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  ADD PRIMARY KEY (`bank_account_id`),
  ADD KEY `currency_code` (`currency_code`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- Indexes for table `cards`
--
ALTER TABLE `cards`
  ADD PRIMARY KEY (`card_id`),
  ADD UNIQUE KEY `wallet_id` (`wallet_id`),
  ADD KEY `currency_code` (`currency_code`),
  ADD KEY `idx_wallet_id` (`wallet_id`);

--
-- Indexes for table `currencies`
--
ALTER TABLE `currencies`
  ADD PRIMARY KEY (`currency_code`);

--
-- Indexes for table `exchange_rates`
--
ALTER TABLE `exchange_rates`
  ADD PRIMARY KEY (`rate_id`),
  ADD UNIQUE KEY `unique_rate_pair` (`base_currency_code`,`target_currency_code`),
  ADD KEY `target_currency_code` (`target_currency_code`);

--
-- Indexes for table `external_transfers`
--
ALTER TABLE `external_transfers`
  ADD PRIMARY KEY (`transfer_id`),
  ADD KEY `idx_transaction_id` (`transaction_id`);

--
-- Indexes for table `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`attempt_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_attempt_time` (`attempt_time`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`token_id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_token` (`token`);

--
-- Indexes for table `qr_codes`
--
ALTER TABLE `qr_codes`
  ADD PRIMARY KEY (`qr_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `currency_code` (`currency_code`),
  ADD KEY `idx_wallet_id` (`wallet_id`);

--
-- Indexes for table `recurring_payments`
--
ALTER TABLE `recurring_payments`
  ADD PRIMARY KEY (`recurring_payment_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `wallet_id` (`wallet_id`),
  ADD KEY `currency_code` (`currency_code`),
  ADD KEY `idx_next_payment_date` (`next_payment_date`);

--
-- Indexes for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `assigned_to` (`assigned_to`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `system_logs`
--
ALTER TABLE `system_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_admin_id` (`admin_id`);

--
-- Indexes for table `ticket_responses`
--
ALTER TABLE `ticket_responses`
  ADD PRIMARY KEY (`response_id`),
  ADD KEY `idx_ticket_id` (`ticket_id`);

--
-- Indexes for table `timestamps`
--
ALTER TABLE `timestamps`
  ADD PRIMARY KEY (`timestamp_id`),
  ADD UNIQUE KEY `unique_entity` (`entity_type`,`entity_id`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `recipient_wallet_id` (`recipient_wallet_id`),
  ADD KEY `currency_code` (`currency_code`),
  ADD KEY `base_currency_code` (`base_currency_code`),
  ADD KEY `idx_wallet_id` (`wallet_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone_number` (`phone_number`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_phone_number` (`phone_number`);

--
-- Indexes for table `verification_documents`
--
ALTER TABLE `verification_documents`
  ADD PRIMARY KEY (`document_id`),
  ADD KEY `verified_by` (`verified_by`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- Indexes for table `wallets`
--
ALTER TABLE `wallets`
  ADD PRIMARY KEY (`wallet_id`),
  ADD KEY `currency_code` (`currency_code`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `account_limits`
--
ALTER TABLE `account_limits`
  MODIFY `limit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `analytics_events`
--
ALTER TABLE `analytics_events`
  MODIFY `event_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `api_keys`
--
ALTER TABLE `api_keys`
  MODIFY `api_key_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `api_request_logs`
--
ALTER TABLE `api_request_logs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  MODIFY `bank_account_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `cards`
--
ALTER TABLE `cards`
  MODIFY `card_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `exchange_rates`
--
ALTER TABLE `exchange_rates`
  MODIFY `rate_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `external_transfers`
--
ALTER TABLE `external_transfers`
  MODIFY `transfer_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `attempt_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  MODIFY `token_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `qr_codes`
--
ALTER TABLE `qr_codes`
  MODIFY `qr_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `recurring_payments`
--
ALTER TABLE `recurring_payments`
  MODIFY `recurring_payment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `support_tickets`
--
ALTER TABLE `support_tickets`
  MODIFY `ticket_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_logs`
--
ALTER TABLE `system_logs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ticket_responses`
--
ALTER TABLE `ticket_responses`
  MODIFY `response_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `timestamps`
--
ALTER TABLE `timestamps`
  MODIFY `timestamp_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `verification_documents`
--
ALTER TABLE `verification_documents`
  MODIFY `document_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `wallets`
--
ALTER TABLE `wallets`
  MODIFY `wallet_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `analytics_events`
--
ALTER TABLE `analytics_events`
  ADD CONSTRAINT `analytics_events_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `api_keys`
--
ALTER TABLE `api_keys`
  ADD CONSTRAINT `api_keys_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `api_request_logs`
--
ALTER TABLE `api_request_logs`
  ADD CONSTRAINT `api_request_logs_ibfk_1` FOREIGN KEY (`api_key_id`) REFERENCES `api_keys` (`api_key_id`) ON DELETE SET NULL;

--
-- Constraints for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  ADD CONSTRAINT `bank_accounts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bank_accounts_ibfk_2` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`currency_code`);

--
-- Constraints for table `cards`
--
ALTER TABLE `cards`
  ADD CONSTRAINT `cards_ibfk_1` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`wallet_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cards_ibfk_2` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`currency_code`);

--
-- Constraints for table `exchange_rates`
--
ALTER TABLE `exchange_rates`
  ADD CONSTRAINT `exchange_rates_ibfk_1` FOREIGN KEY (`base_currency_code`) REFERENCES `currencies` (`currency_code`),
  ADD CONSTRAINT `exchange_rates_ibfk_2` FOREIGN KEY (`target_currency_code`) REFERENCES `currencies` (`currency_code`);

--
-- Constraints for table `external_transfers`
--
ALTER TABLE `external_transfers`
  ADD CONSTRAINT `external_transfers_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`) ON DELETE CASCADE;

--
-- Constraints for table `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD CONSTRAINT `login_attempts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD CONSTRAINT `password_reset_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `qr_codes`
--
ALTER TABLE `qr_codes`
  ADD CONSTRAINT `qr_codes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `qr_codes_ibfk_2` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`wallet_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `qr_codes_ibfk_3` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`currency_code`);

--
-- Constraints for table `recurring_payments`
--
ALTER TABLE `recurring_payments`
  ADD CONSTRAINT `recurring_payments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `recurring_payments_ibfk_2` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`wallet_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `recurring_payments_ibfk_3` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`currency_code`);

--
-- Constraints for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD CONSTRAINT `support_tickets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `support_tickets_ibfk_2` FOREIGN KEY (`assigned_to`) REFERENCES `admins` (`admin_id`) ON DELETE SET NULL;

--
-- Constraints for table `system_logs`
--
ALTER TABLE `system_logs`
  ADD CONSTRAINT `system_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `system_logs_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`admin_id`) ON DELETE SET NULL;

--
-- Constraints for table `ticket_responses`
--
ALTER TABLE `ticket_responses`
  ADD CONSTRAINT `ticket_responses_ibfk_1` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`ticket_id`) ON DELETE CASCADE;

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`wallet_id`),
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`recipient_wallet_id`) REFERENCES `wallets` (`wallet_id`) ON DELETE SET NULL;

--
-- Constraints for table `verification_documents`
--
ALTER TABLE `verification_documents`
  ADD CONSTRAINT `verification_documents_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `verification_documents_ibfk_2` FOREIGN KEY (`verified_by`) REFERENCES `admins` (`admin_id`) ON DELETE SET NULL;

--
-- Constraints for table `wallets`
--
ALTER TABLE `wallets`
  ADD CONSTRAINT `wallets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wallets_ibfk_2` FOREIGN KEY (`currency_code`) REFERENCES `currencies` (`currency_code`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
