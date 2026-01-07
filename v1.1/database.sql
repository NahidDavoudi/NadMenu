-- =====================================================
-- اسکریپت ایجاد دیتابیس برای سیستم منوی چند مستاجری
-- Database: pizzafel_base (یا نام دلخواه)
-- =====================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- =====================================================
-- جدول مستاجران (Tenants / Cafes)
-- =====================================================
CREATE TABLE IF NOT EXISTS `tenants` (
  `id` varchar(50) NOT NULL PRIMARY KEY,
  `name` varchar(255) NOT NULL,
  `logo_url` varchar(500) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- جدول تنظیمات تم (Theme Settings) برای هر مستاجر
-- =====================================================
CREATE TABLE IF NOT EXISTS `tenant_themes` (
  `tenant_id` varchar(50) NOT NULL PRIMARY KEY,
  `color_primary` varchar(7) DEFAULT '#6B4423',
  `color_secondary` varchar(7) DEFAULT '#D4A574',
  `color_accent` varchar(7) DEFAULT '#B8860B',
  `color_background` varchar(7) DEFAULT '#faf8f3',
  `color_text` varchar(7) DEFAULT '#3E2723',
  `color_card_bg` varchar(7) DEFAULT '#e6ccb2',
  `font_main` varchar(100) DEFAULT 'Abol, sans-serif',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`tenant_id`) REFERENCES `tenants`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- جدول قوانین زمانی (Time Rules) برای هر مستاجر
-- =====================================================
CREATE TABLE IF NOT EXISTS `tenant_time_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `tenant_id` varchar(50) NOT NULL,
  `time_key` varchar(20) NOT NULL COMMENT 'morning, noon, evening, night',
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_tenant_time` (`tenant_id`, `time_key`),
  FOREIGN KEY (`tenant_id`) REFERENCES `tenants`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- جدول مودها (Moods) برای هر مستاجر
-- =====================================================
CREATE TABLE IF NOT EXISTS `tenant_moods` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `tenant_id` varchar(50) NOT NULL,
  `mood_id` varchar(50) NOT NULL COMMENT 'focus, party, relax, energy, etc.',
  `label` varchar(100) NOT NULL COMMENT 'برچسب فارسی',
  `color` varchar(7) DEFAULT NULL,
  `display_order` int(11) DEFAULT 0,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_tenant_mood` (`tenant_id`, `mood_id`),
  FOREIGN KEY (`tenant_id`) REFERENCES `tenants`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- جدول دسته‌بندی‌ها (Categories)
-- =====================================================
CREATE TABLE IF NOT EXISTS `categories` (
  `id` varchar(50) NOT NULL PRIMARY KEY,
  `tenant_id` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `lottie_url` varchar(500) DEFAULT NULL COMMENT 'URL to Lottie animation JSON file',
  `display_order` int(11) DEFAULT 0,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`tenant_id`) REFERENCES `tenants`(`id`) ON DELETE CASCADE,
  INDEX `idx_tenant_active` (`tenant_id`, `active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- جدول آیتم‌های منو (Menu Items)
-- =====================================================
CREATE TABLE IF NOT EXISTS `menu_items` (
  `id` varchar(50) NOT NULL PRIMARY KEY,
  `tenant_id` varchar(50) NOT NULL,
  `category_id` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `image_url` varchar(500) DEFAULT NULL,
  `available` tinyint(1) DEFAULT 1,
  `display_order` int(11) DEFAULT 0,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`tenant_id`) REFERENCES `tenants`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE CASCADE,
  INDEX `idx_tenant_category` (`tenant_id`, `category_id`),
  INDEX `idx_available` (`available`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- جدول ارتباط آیتم‌ها با مودها (Many-to-Many)
-- =====================================================
CREATE TABLE IF NOT EXISTS `item_moods` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `item_id` varchar(50) NOT NULL,
  `mood_id` int(11) NOT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_item_mood` (`item_id`, `mood_id`),
  FOREIGN KEY (`item_id`) REFERENCES `menu_items`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`mood_id`) REFERENCES `tenant_moods`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- جدول دسترسی زمانی آیتم‌ها (Time Availability)
-- =====================================================
CREATE TABLE IF NOT EXISTS `item_time_availability` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `item_id` varchar(50) NOT NULL,
  `time_key` varchar(20) NOT NULL COMMENT 'morning, noon, evening, night',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_item_time` (`item_id`, `time_key`),
  FOREIGN KEY (`item_id`) REFERENCES `menu_items`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- داده‌های نمونه (Sample Data) برای تست
-- =====================================================

-- مستاجر نمونه
INSERT INTO `tenants` (`id`, `name`, `logo_url`, `active`) VALUES
('cafe_1', 'Pizza Felfeli', './assets/imgs/logo.png', 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- تنظیمات تم
INSERT INTO `tenant_themes` (`tenant_id`, `color_primary`, `color_secondary`, `color_accent`, `color_background`, `color_text`, `color_card_bg`, `font_main`) VALUES
('cafe_1', '#6B4423', '#D4A574', '#B8860B', '#faf8f3', '#3E2723', '#e6ccb2', 'Abol, sans-serif')
ON DUPLICATE KEY UPDATE 
  `color_primary` = VALUES(`color_primary`),
  `color_secondary` = VALUES(`color_secondary`),
  `color_accent` = VALUES(`color_accent`);

-- قوانین زمانی
INSERT INTO `tenant_time_rules` (`tenant_id`, `time_key`, `start_time`, `end_time`) VALUES
('cafe_1', 'morning', '06:00:00', '11:59:59'),
('cafe_1', 'noon', '12:00:00', '16:59:59'),
('cafe_1', 'evening', '17:00:00', '23:59:59')
ON DUPLICATE KEY UPDATE 
  `start_time` = VALUES(`start_time`),
  `end_time` = VALUES(`end_time`);

-- مودها
INSERT INTO `tenant_moods` (`tenant_id`, `mood_id`, `label`, `color`, `display_order`) VALUES
('cafe_1', 'focus', 'تمرکز', '#8D6E63', 1),
('cafe_1', 'party', 'جشن', '#FFCA28', 2),
('cafe_1', 'relax', 'آرامش', '#81C784', 3),
('cafe_1', 'energy', 'انرژی', '#FF7043', 4)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`);

-- دسته‌بندی‌ها
INSERT INTO `categories` (`id`, `tenant_id`, `title`, `description`, `image_url`, `lottie_url`, `display_order`) VALUES
('coffee', 'cafe_1', 'قهوه', 'قهوه‌های دمی و اسپرسو', './assets/imgs/categories/coffee-bg.jpg', './assets/lottie/coffee-cup.json', 1),
('tea', 'cafe_1', 'چای و دمنوش', 'چای‌های خوش‌عطر و دمنوش‌ها', './assets/imgs/categories/tea-bg.jpg', './assets/lottie/tea-pot.json', 2),
('cold_drinks', 'cafe_1', 'نوشیدنی سرد', 'نوشیدنی‌های خنک و تازه', './assets/imgs/categories/cold-drinks-bg.jpg', './assets/lottie/cold-drink.json', 3),
('shakes', 'cafe_1', 'شیک‌ها', 'شیک‌های غلیظ و خوشمزه', './assets/imgs/categories/shake-bg.jpg', './assets/lottie/milkshake.json', 4),
('pizza', 'cafe_1', 'پیتزا', 'پیتزاهای ایتالیایی و آمریکایی', './assets/imgs/categories/pizza-bg.jpg', './assets/lottie/pizza-slice.json', 5),
('burger', 'cafe_1', 'برگر', 'برگرهای خانگی و گریل', './assets/imgs/categories/burger-bg.jpg', './assets/lottie/burger-layers.json', 6)
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `lottie_url` = VALUES(`lottie_url`);

-- آیتم‌های منو
INSERT INTO `menu_items` (`id`, `tenant_id`, `category_id`, `name`, `description`, `price`, `image_url`, `available`, `display_order`) VALUES
('espresso', 'cafe_1', 'coffee', 'اسپرسو', 'قهوه غلیظ با روست مدیوم', 65000, './assets/imgs/products/product_693aaacf607e2_1765452495.png', 1, 1),
('pepperoni', 'cafe_1', 'pizza', 'پیتزا پپرونی', 'پپرونی، پنیر موزارلا، سس مخصوص', 210000, './assets/imgs/main/fast-food.jpg', 1, 1),
('choc_shake', 'cafe_1', 'shakes', 'شیک شکلات', 'بستنی شکلاتی، شیر، سس شکلات', 120000, './assets/imgs/products/product_693aab0db5c42_1765452557.png', 1, 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- ارتباط آیتم‌ها با مودها
INSERT INTO `item_moods` (`item_id`, `mood_id`) 
SELECT 'espresso', `id` FROM `tenant_moods` WHERE `tenant_id` = 'cafe_1' AND `mood_id` IN ('focus', 'energy')
ON DUPLICATE KEY UPDATE `item_id` = VALUES(`item_id`);

INSERT INTO `item_moods` (`item_id`, `mood_id`) 
SELECT 'pepperoni', `id` FROM `tenant_moods` WHERE `tenant_id` = 'cafe_1' AND `mood_id` IN ('party', 'energy')
ON DUPLICATE KEY UPDATE `item_id` = VALUES(`item_id`);

INSERT INTO `item_moods` (`item_id`, `mood_id`) 
SELECT 'choc_shake', `id` FROM `tenant_moods` WHERE `tenant_id` = 'cafe_1' AND `mood_id` IN ('relax', 'party')
ON DUPLICATE KEY UPDATE `item_id` = VALUES(`item_id`);

-- دسترسی زمانی آیتم‌ها
INSERT INTO `item_time_availability` (`item_id`, `time_key`) VALUES
('espresso', 'morning'),
('espresso', 'noon'),
('espresso', 'evening'),
('pepperoni', 'noon'),
('pepperoni', 'evening'),
('choc_shake', 'noon'),
('choc_shake', 'evening')
ON DUPLICATE KEY UPDATE `item_id` = VALUES(`item_id`);

-- =====================================================
-- ایندکس‌های اضافی برای بهینه‌سازی
-- =====================================================
CREATE INDEX IF NOT EXISTS `idx_tenant_moods_active` ON `tenant_moods` (`tenant_id`, `active`);
CREATE INDEX IF NOT EXISTS `idx_menu_items_tenant_available` ON `menu_items` (`tenant_id`, `available`, `display_order`);

-- =====================================================
-- پایان اسکریپت
-- =====================================================
