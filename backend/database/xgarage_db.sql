-- ============================================================
-- XGarage - Smart Garage & Valet Management System
-- Full Database Export for phpMyAdmin / MySQL 8.0+ / MariaDB
-- Recommended Database Name: xgarage_db
-- ============================================================

CREATE DATABASE IF NOT EXISTS `xgarage_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `xgarage_db`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- Table structure for `users`
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'owner',
  `fcm_token` varchar(255) DEFAULT NULL,
  `locale` varchar(5) NOT NULL DEFAULT 'ar',
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_phone_unique` (`phone`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_role_index` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Dumping data for table `users`
-- ------------------------------------------------------------
LOCK TABLES `users` WRITE;
INSERT INTO `users` (`id`, `name`, `phone`, `email`, `email_verified_at`, `password`, `role`, `fcm_token`, `locale`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Ahmed Valet Lead', '01000000001', 'employee@xgarage.com', NULL, '$2y$12$N4bC0Yc8yA5VjC20.l3yqObYhZz6K6b1Y5hJ0LzUaC3.5F5t1V0c2', 'employee', NULL, 'ar', NULL, '2026-11-26 19:18:18', '2026-11-26 19:18:18'),
(2, 'طارق منصور (Tarek Mansour)', '01011111111', 'tarek@example.com', NULL, '$2y$12$N4bC0Yc8yA5VjC20.l3yqObYhZz6K6b1Y5hJ0LzUaC3.5F5t1V0c2', 'owner', NULL, 'ar', NULL, '2026-11-26 19:18:19', '2026-11-26 19:18:19'),
(3, 'سارة خليل (Sarah Khalil)', '01022222222', 'sarah@example.com', NULL, '$2y$12$N4bC0Yc8yA5VjC20.l3yqObYhZz6K6b1Y5hJ0LzUaC3.5F5t1V0c2', 'owner', NULL, 'en', NULL, '2026-11-26 19:18:19', '2026-11-26 19:18:19'),
(4, 'عمر فاروق (Omar Farouk)', '01033333333', 'omar@example.com', NULL, '$2y$12$N4bC0Yc8yA5VjC20.l3yqObYhZz6K6b1Y5hJ0LzUaC3.5F5t1V0c2', 'owner', NULL, 'ar', NULL, '2026-11-26 19:18:19', '2026-11-26 19:18:19');
UNLOCK TABLES;

-- ------------------------------------------------------------
-- Table structure for `password_reset_tokens`
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `password_reset_tokens`;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Table structure for `sessions`
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Table structure for `personal_access_tokens`
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `personal_access_tokens`;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Table structure for `vehicles`
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE `vehicles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `make` varchar(50) NOT NULL,
  `model` varchar(50) NOT NULL,
  `year` smallint(5) unsigned DEFAULT NULL,
  `color_name` varchar(30) NOT NULL DEFAULT 'Black',
  `color_hex` varchar(7) NOT NULL DEFAULT '#0F0E13',
  `plate_letters` varchar(20) NOT NULL,
  `plate_numbers` varchar(10) NOT NULL,
  `plate_full_normalized` varchar(50) NOT NULL,
  `plate_image_path` varchar(255) DEFAULT NULL,
  `parking_spot` varchar(20) DEFAULT NULL,
  `key_hook_number` varchar(20) DEFAULT NULL,
  `special_notes` text DEFAULT NULL,
  `current_status` varchar(30) NOT NULL DEFAULT 'parked',
  `is_inside_garage` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `vehicles_user_id_foreign` (`user_id`),
  KEY `vehicles_plate_full_normalized_index` (`plate_full_normalized`),
  KEY `vehicles_current_status_index` (`current_status`),
  KEY `vehicles_is_inside_garage_index` (`is_inside_garage`),
  CONSTRAINT `vehicles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Dumping data for table `vehicles`
-- ------------------------------------------------------------
LOCK TABLES `vehicles` WRITE;
INSERT INTO `vehicles` (`id`, `user_id`, `make`, `model`, `year`, `color_name`, `color_hex`, `plate_letters`, `plate_numbers`, `plate_full_normalized`, `plate_image_path`, `parking_spot`, `key_hook_number`, `special_notes`, `current_status`, `is_inside_garage`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 2, 'Mercedes-Benz', 'C200 AMG', 2023, 'Obsidian Black', '#0F0E13', 'أ ب ج', '١٢٣٤', 'أ ب ج 1234', NULL, 'B1-04', 'Hook #04', 'Low front spoiler, please take speed bumps slowly.', 'parked', 1, '2026-11-26 19:18:19', '2026-11-26 19:18:19', NULL),
(2, 3, 'BMW', '320i M Sport', 2022, 'Alpine White', '#F8FAFC', 'س ر ح', '٥٦٧٨', 'س ر ح 5678', NULL, 'A2-11', 'Hook #11', 'Please fold electric side mirrors.', 'washing', 1, '2026-11-26 19:18:19', '2026-11-26 19:18:19', NULL),
(3, 4, 'Porsche', 'Macan GTS', 2024, 'Crimson Ruby', '#991B1B', 'ق ر ش', '٩٩٩٩', 'ق ر ش 9999', NULL, 'VIP-01', 'Hook #01', 'Keep keys in VIP lockbox.', 'ready_at_gate', 1, '2026-11-26 19:18:19', '2026-11-26 19:18:19', NULL);
UNLOCK TABLES;

-- ------------------------------------------------------------
-- Table structure for `daily_schedules`
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `daily_schedules`;
CREATE TABLE `daily_schedules` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `vehicle_id` bigint(20) unsigned NOT NULL,
  `pickup_time` time NOT NULL,
  `excluded_days` json NOT NULL,
  `include_wash` tinyint(1) NOT NULL DEFAULT 0,
  `wash_type` varchar(20) NOT NULL DEFAULT 'none',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `skip_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `daily_schedules_vehicle_id_unique` (`vehicle_id`),
  KEY `daily_schedules_is_active_index` (`is_active`),
  CONSTRAINT `daily_schedules_vehicle_id_foreign` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Dumping data for table `daily_schedules`
-- ------------------------------------------------------------
LOCK TABLES `daily_schedules` WRITE;
INSERT INTO `daily_schedules` (`id`, `vehicle_id`, `pickup_time`, `excluded_days`, `include_wash`, `wash_type`, `is_active`, `skip_date`, `created_at`, `updated_at`) VALUES
(1, 1, '09:00:00', '[5]', 1, 'exterior', 1, NULL, '2026-11-26 19:18:19', '2026-11-26 19:18:19'),
(2, 2, '08:30:00', '[5]', 1, 'full', 1, NULL, '2026-11-26 19:18:19', '2026-11-26 19:18:19'),
(3, 3, '10:00:00', '[5, 6]', 1, 'full', 1, NULL, '2026-11-26 19:18:19', '2026-11-26 19:18:19');
UNLOCK TABLES;

-- ------------------------------------------------------------
-- Table structure for `pickup_requests`
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `pickup_requests`;
CREATE TABLE `pickup_requests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `vehicle_id` bigint(20) unsigned NOT NULL,
  `requested_by` bigint(20) unsigned NOT NULL,
  `handled_by` bigint(20) unsigned DEFAULT NULL,
  `source` varchar(30) NOT NULL DEFAULT 'manual',
  `scheduled_for` datetime NOT NULL,
  `wants_wash` tinyint(1) NOT NULL DEFAULT 0,
  `wash_type` varchar(20) NOT NULL DEFAULT 'none',
  `wash_status` varchar(30) NOT NULL DEFAULT 'not_needed',
  `status` varchar(30) NOT NULL DEFAULT 'scheduled',
  `owner_notes` text DEFAULT NULL,
  `ready_at` datetime DEFAULT NULL,
  `picked_up_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pickup_requests_vehicle_id_foreign` (`vehicle_id`),
  KEY `pickup_requests_requested_by_foreign` (`requested_by`),
  KEY `pickup_requests_handled_by_foreign` (`handled_by`),
  KEY `pickup_requests_scheduled_for_index` (`scheduled_for`),
  KEY `pickup_requests_status_index` (`status`),
  CONSTRAINT `pickup_requests_vehicle_id_foreign` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pickup_requests_requested_by_foreign` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pickup_requests_handled_by_foreign` FOREIGN KEY (`handled_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Dumping data for table `pickup_requests`
-- ------------------------------------------------------------
LOCK TABLES `pickup_requests` WRITE;
INSERT INTO `pickup_requests` (`id`, `vehicle_id`, `requested_by`, `handled_by`, `source`, `scheduled_for`, `wants_wash`, `wash_type`, `wash_status`, `status`, `owner_notes`, `ready_at`, `picked_up_at`, `created_at`, `updated_at`) VALUES
(1, 1, 2, NULL, 'daily_schedule', NOW() + INTERVAL 2 HOUR, 1, 'exterior', 'pending', 'scheduled', 'Leaving for office at 9 AM', NULL, NULL, '2026-11-26 19:18:19', '2026-11-26 19:18:19'),
(2, 2, 3, 1, 'daily_schedule', NOW() + INTERVAL 1 HOUR, 1, 'full', 'in_progress', 'washing', 'Full clean inside and outside please', NULL, NULL, '2026-11-26 19:18:19', '2026-11-26 19:18:19'),
(3, 3, 4, 1, 'manual', NOW(), 1, 'full', 'completed', 'ready_at_gate', 'Need car ready early at gate', NOW() - INTERVAL 10 MINUTE, NULL, '2026-11-26 19:18:19', '2026-11-26 19:18:19');
UNLOCK TABLES;

-- ------------------------------------------------------------
-- Table structure for `vehicle_status_logs`
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `vehicle_status_logs`;
CREATE TABLE `vehicle_status_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `vehicle_id` bigint(20) unsigned NOT NULL,
  `changed_by` bigint(20) unsigned NOT NULL,
  `from_status` varchar(30) NOT NULL,
  `to_status` varchar(30) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `vehicle_status_logs_vehicle_id_foreign` (`vehicle_id`),
  KEY `vehicle_status_logs_changed_by_foreign` (`changed_by`),
  CONSTRAINT `vehicle_status_logs_vehicle_id_foreign` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `vehicle_status_logs_changed_by_foreign` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Dumping data for table `vehicle_status_logs`
-- ------------------------------------------------------------
LOCK TABLES `vehicle_status_logs` WRITE;
INSERT INTO `vehicle_status_logs` (`id`, `vehicle_id`, `changed_by`, `from_status`, `to_status`, `notes`, `created_at`) VALUES
(1, 3, 1, 'washing', 'ready_at_gate', 'Vehicle washed, dried, and parked at exit bay 1.', NOW() - INTERVAL 10 MINUTE);
UNLOCK TABLES;

-- ------------------------------------------------------------
-- Table structure for `cache` & `cache_locks`
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `cache`;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `cache_locks`;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Table structure for `jobs`
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `jobs`;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Table structure for `migrations`
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `migrations`;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

LOCK TABLES `migrations` WRITE;
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_11_26_191619_create_personal_access_tokens_table', 1),
(5, '2026_11_26_200000_create_vehicles_table', 1),
(6, '2026_11_26_200001_create_daily_schedules_table', 1),
(7, '2026_11_26_200002_create_pickup_requests_table', 1),
(8, '2026_11_26_200003_create_vehicle_status_logs_table', 1);
UNLOCK TABLES;

SET FOREIGN_KEY_CHECKS = 1;
