-- MySQL Database Export
-- Generated on: 2025-08-01T04:42:42.439Z
-- Database: cyber_security_leave_portal
-- Host: localhost

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `cyber_security_leave_portal` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `cyber_security_leave_portal`;

-- Table structure for table `leave_requests`
DROP TABLE IF EXISTS `leave_requests`;
CREATE TABLE `leave_requests` (
  `id` varchar(36) NOT NULL,
  `student_id` varchar(36) NOT NULL,
  `student_name` varchar(255) NOT NULL,
  `student_register_number` varchar(100) NOT NULL,
  `tutor_id` varchar(36) NOT NULL,
  `tutor_name` varchar(255) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `total_days` int NOT NULL,
  `subject` varchar(500) NOT NULL,
  `description` text,
  `status` enum('Pending','Approved','Rejected','Forwarded','Cancelled','Cancellation Pending','Retried') DEFAULT 'Pending',
  `cancel_reason` text,
  `partial_cancel_start` date DEFAULT NULL,
  `partial_cancel_end` date DEFAULT NULL,
  `partial_cancel_days` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  KEY `tutor_id` (`tutor_id`),
  KEY `idx_leave_partial_cancellation` (`status`,`partial_cancel_start`,`partial_cancel_end`),
  CONSTRAINT `leave_requests_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `leave_requests_ibfk_2` FOREIGN KEY (`tutor_id`) REFERENCES `staff` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table structure for table `od_requests`
DROP TABLE IF EXISTS `od_requests`;
CREATE TABLE `od_requests` (
  `id` varchar(36) NOT NULL,
  `student_id` varchar(36) NOT NULL,
  `student_name` varchar(255) NOT NULL,
  `student_register_number` varchar(100) NOT NULL,
  `tutor_id` varchar(36) NOT NULL,
  `tutor_name` varchar(255) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `total_days` int NOT NULL,
  `purpose` varchar(500) NOT NULL,
  `destination` varchar(255) NOT NULL,
  `description` text,
  `status` enum('Pending','Approved','Rejected','Forwarded','Cancelled','Cancellation Pending','Retried') DEFAULT 'Pending',
  `cancel_reason` text,
  `certificate_url` varchar(500) DEFAULT NULL,
  `certificate_status` enum('Pending Upload','Pending Verification','Approved','Rejected','Overdue') DEFAULT NULL,
  `upload_deadline` timestamp NULL DEFAULT NULL,
  `last_notification_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  KEY `tutor_id` (`tutor_id`),
  KEY `idx_od_certificate_reminders` (`status`,`certificate_status`,`end_date`,`last_notification_date`),
  CONSTRAINT `od_requests_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `od_requests_ibfk_2` FOREIGN KEY (`tutor_id`) REFERENCES `staff` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table structure for table `profile_change_requests`
DROP TABLE IF EXISTS `profile_change_requests`;
CREATE TABLE `profile_change_requests` (
  `id` varchar(36) NOT NULL,
  `student_id` varchar(36) NOT NULL,
  `student_name` varchar(255) NOT NULL,
  `student_register_number` varchar(50) NOT NULL,
  `tutor_id` varchar(36) NOT NULL,
  `tutor_name` varchar(255) NOT NULL,
  `change_type` enum('email','mobile','password') NOT NULL,
  `current_value` text,
  `requested_value` text NOT NULL,
  `reason` text,
  `status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `admin_comments` text,
  `requested_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reviewed_by` varchar(36) DEFAULT NULL,
  `reviewer_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_tutor_id` (`tutor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_change_type` (`change_type`),
  KEY `idx_requested_at` (`requested_at`),
  KEY `idx_student_status` (`student_id`,`status`),
  KEY `idx_tutor_status` (`tutor_id`,`status`),
  CONSTRAINT `profile_change_requests_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `profile_change_requests_ibfk_2` FOREIGN KEY (`tutor_id`) REFERENCES `staff` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table structure for table `staff`
DROP TABLE IF EXISTS `staff`;
CREATE TABLE `staff` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(100) NOT NULL,
  `profile_photo` varchar(500) DEFAULT NULL,
  `is_admin` tinyint(1) DEFAULT '0',
  `is_tutor` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `staff`
INSERT INTO `staff` (`id`, `name`, `email`, `username`, `profile_photo`, `is_admin`, `is_tutor`, `created_at`, `updated_at`) VALUES
('922af2c0-458b-465b-92c7-d0d7985d77c3', 'tester', 'tester@gmail.com', 'tester', NULL, 0, 1, '2025-08-01 09:34:03', '2025-08-01 09:34:03'),
('admin-clean-001', 'Admin User', 'admin@test.com', 'admin', NULL, 1, 0, '2025-08-01 09:29:25', '2025-08-01 09:29:25');

-- Table structure for table `students`
DROP TABLE IF EXISTS `students`;
CREATE TABLE `students` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `register_number` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `tutor_id` varchar(36) DEFAULT NULL,
  `batch` varchar(4) NOT NULL DEFAULT '2024',
  `semester` tinyint(1) NOT NULL DEFAULT '1',
  `username` varchar(50) NOT NULL DEFAULT '',
  `profile_photo` text,
  `leave_taken` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `register_number` (`register_number`),
  UNIQUE KEY `unique_student_email` (`email`),
  UNIQUE KEY `unique_username` (`username`),
  KEY `tutor_id` (`tutor_id`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`tutor_id`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `students`
INSERT INTO `students` (`id`, `name`, `register_number`, `email`, `mobile`, `tutor_id`, `batch`, `semester`, `username`, `profile_photo`, `leave_taken`, `created_at`, `updated_at`) VALUES
('52ca326b-e6e2-4f8e-9412-04ce6a2bac99', 'test', '000012', 'test@gmail.com', '9842924709', '922af2c0-458b-465b-92c7-d0d7985d77c3', '2024', 3, 'test', NULL, 0, '2025-08-01 09:35:01', '2025-08-01 09:35:01');

-- Table structure for table `user_sessions`
DROP TABLE IF EXISTS `user_sessions`;
CREATE TABLE `user_sessions` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `token_hash` varchar(255) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `user_sessions`
INSERT INTO `user_sessions` (`id`, `user_id`, `token_hash`, `expires_at`, `is_active`, `created_at`) VALUES
('046844d3-3ca9-4e2c-bc52-20b0dee89c2f', '922af2c0-458b-465b-92c7-d0d7985d77c3', '06efdfd100fe37a97ac0605706ce00898bdba531c54738a87b537462f43f95fa', '2025-08-02 04:07:21', 1, '2025-08-01 09:37:21'),
('0f9d1fc9-c52f-44f6-a9f3-e0f995c5f45c', 'admin-clean-001', '32a4564767c76793b4401faac2fa2bf68cf84547d27784052a6439d400f5e6ba', '2025-08-02 03:59:42', 0, '2025-08-01 09:29:42'),
('0fda384a-784b-46cb-9fe1-544eee7c53ef', 'admin-clean-001', '083c9b4e32609852a0305be6eb5c13c100865eaeb4df76a8ea6f26fc94be00be', '2025-08-02 03:59:53', 0, '2025-08-01 09:29:53'),
('6fd9e3f5-9dff-4d00-afd6-39a110cef626', 'admin-clean-001', '6d9d7aeffd2f149c7aac87ea9388d5bebdda7b1e0b70ca707d7055e1f4a7176d', '2025-08-02 03:59:35', 0, '2025-08-01 09:29:35'),
('7befd4e2-3212-47de-9ac7-2e805d79f417', 'admin-clean-001', 'bae497227439d976fa65886c30a64b7ba96b730ad4b2b9d60df3d5d4e60c314b', '2025-08-02 04:01:23', 1, '2025-08-01 09:31:23'),
('df6601d4-fec3-490f-bc4e-7549e4c7d084', '52ca326b-e6e2-4f8e-9412-04ce6a2bac99', '2b19390138daec60371e7ef782d443dc5e857d83e3dc99ddf59308a44e035a1b', '2025-08-02 04:08:17', 1, '2025-08-01 09:38:16');

-- Table structure for table `users`
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` varchar(36) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `profile_photo` varchar(500) DEFAULT NULL,
  `is_admin` tinyint(1) DEFAULT '0',
  `is_tutor` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `users`
INSERT INTO `users` (`id`, `email`, `password_hash`, `first_name`, `last_name`, `profile_photo`, `is_admin`, `is_tutor`, `created_at`, `updated_at`) VALUES
('52ca326b-e6e2-4f8e-9412-04ce6a2bac99', 'test@gmail.com', '$2a$10$dBwrNrm.1N05yxfUyGtJtOTNcfxew4S2rpxkBBRa7VpyIRMuR/Kku', 'test', '', NULL, 0, 0, '2025-08-01 09:35:01', '2025-08-01 09:35:01'),
('922af2c0-458b-465b-92c7-d0d7985d77c3', 'tester@gmail.com', '$2a$10$ApolAhtIHUpCIxduUwzxiOacIkoffARwz98uMZqaA9R2k2KuCQS5O', 'tester', '', NULL, 0, 1, '2025-08-01 09:34:03', '2025-08-01 09:34:03'),
('admin-clean-001', 'admin@test.com', '$2a$10$1NGHttL3ALa23.iTBm/0/e62Njc0W6bsjrAgStuI3QfplD8g.hT7C', 'Admin', 'User', NULL, 1, 0, '2025-08-01 09:29:25', '2025-08-01 09:29:25');

COMMIT;
