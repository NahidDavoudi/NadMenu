# راهنمای نصب دیتابیس

## مراحل نصب

### 1. ایجاد دیتابیس
```sql
CREATE DATABASE pizzafel_base CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 2. اجرای اسکریپت SQL
فایل `database.sql` را در phpMyAdmin یا از طریق خط فرمان اجرا کنید:

**از طریق phpMyAdmin:**
- وارد phpMyAdmin شوید
- دیتابیس `pizzafel_base` را انتخاب کنید
- تب "Import" را باز کنید
- فایل `database.sql` را انتخاب و Import کنید

**از طریق خط فرمان:**
```bash
mysql -u pizzafel_feli -p pizzafel_base < database.sql
```

### 3. بررسی تنظیمات اتصال
فایل `api.php` را باز کنید و اطلاعات دیتابیس را بررسی/تغییر دهید:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'pizzafel_base');
define('DB_USER', 'pizzafel_feli');
define('DB_PASS', '09355286558-x');
```

### 4. تست API
بعد از نصب، می‌توانید API را تست کنید:
```
http://your-domain.com/api.php?action=menu&tenant_id=cafe_1
```

## ساختار جداول

- **tenants**: اطلاعات مستاجران (کافه‌ها)
- **tenant_themes**: تنظیمات رنگ و فونت هر مستاجر
- **tenant_time_rules**: قوانین زمانی (صبح، ظهر، عصر)
- **tenant_moods**: مودها (تمرکز، جشن، آرامش، انرژی)
- **categories**: دسته‌بندی‌های منو
- **menu_items**: آیتم‌های منو
- **item_moods**: ارتباط آیتم‌ها با مودها (Many-to-Many)
- **item_time_availability**: دسترسی زمانی هر آیتم

## افزودن مستاجر جدید

```sql
-- 1. افزودن مستاجر
INSERT INTO tenants (id, name, logo_url) VALUES ('cafe_2', 'نام کافه', './path/to/logo.png');

-- 2. افزودن تنظیمات تم
INSERT INTO tenant_themes (tenant_id, color_primary, ...) VALUES ('cafe_2', '#COLOR', ...);

-- 3. افزودن قوانین زمانی
INSERT INTO tenant_time_rules (tenant_id, time_key, start_time, end_time) VALUES 
('cafe_2', 'morning', '06:00:00', '11:59:59'),
('cafe_2', 'noon', '12:00:00', '16:59:59'),
('cafe_2', 'evening', '17:00:00', '23:59:59');

-- 4. افزودن مودها
INSERT INTO tenant_moods (tenant_id, mood_id, label, color) VALUES 
('cafe_2', 'focus', 'تمرکز', '#COLOR'),
...

-- 5. افزودن دسته‌بندی‌ها و آیتم‌ها
-- (مشابه نمونه‌های موجود)
```

## نکات مهم

- تمام جداول از `utf8mb4` استفاده می‌کنند برای پشتیبانی کامل از فارسی
- Foreign Keys برای یکپارچگی داده‌ها تنظیم شده‌اند
- ایندکس‌ها برای بهینه‌سازی کوئری‌ها اضافه شده‌اند
- داده‌های نمونه برای `cafe_1` در اسکریپت موجود است
