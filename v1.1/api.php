<?php
/**
 * API یکپارچه برای سیستم منوی چند مستاجری
 * Multi-Tenant Menu System API
 */

// =====================================================
// تنظیمات دیتابیس
// =====================================================
define('DB_HOST', '127.0.0.1');
define('DB_NAME', 'nadmenu');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

// =====================================================
// توابع کمکی
// =====================================================

function getDBConnection() {
    try {
        $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];
        return new PDO($dsn, DB_USER, DB_PASS, $options);
    } catch (PDOException $e) {
        error_log("Database Connection Error: " . $e->getMessage());
        return null;
    }
}

function sendJsonResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

function sendError($message, $statusCode = 400) {
    sendJsonResponse(['success' => false, 'error' => $message], $statusCode);
}

// =====================================================
// هدرها و CORS
// =====================================================
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Method not allowed', 405);
}

// =====================================================
// دریافت پارامترها
// =====================================================
$action = isset($_GET['action']) ? trim($_GET['action']) : 'menu';
$tenantId = isset($_GET['tenant_id']) ? trim($_GET['tenant_id']) : 'cafe_1'; // Default tenant

// =====================================================
// اتصال به دیتابیس
// =====================================================
$pdo = getDBConnection();
if ($pdo === null) {
    sendError('Database connection failed', 500);
}

// =====================================================
// Route Handler
// =====================================================
try {
    switch ($action) {
        case 'menu':
            handleMenuRequest($pdo, $tenantId);
            break;
        default:
            sendError('Invalid action. Use: menu', 400);
    }
} catch (PDOException $e) {
    error_log("Database Error: " . $e->getMessage());
    sendError('Database error occurred', 500);
}

// =====================================================
// تابع اصلی برای دریافت منوی کامل
// =====================================================
function handleMenuRequest($pdo, $tenantId) {
    // 1. دریافت اطلاعات مستاجر
    $tenant = getTenant($pdo, $tenantId);
    if (!$tenant) {
        sendError('Tenant not found', 404);
    }

    // 2. دریافت تنظیمات تم
    $theme = getTheme($pdo, $tenantId);

    // 3. دریافت قوانین زمانی
    $timeRules = getTimeRules($pdo, $tenantId);

    // 4. دریافت مودها
    $moods = getMoods($pdo, $tenantId);

    // 5. دریافت دسته‌بندی‌ها
    $categories = getCategories($pdo, $tenantId);

    // 6. دریافت آیتم‌های منو
    $items = getMenuItems($pdo, $tenantId);

    // 7. ساخت پاسخ JSON مطابق با ساختار mock_data.json
    $response = [
        'success' => true,
        'data' => [
            'id' => $tenant['id'],
            'branding' => [
                'name' => $tenant['name'],
                'logo' => $tenant['logo_url'],
                'theme' => [
                    'colors' => [
                        'primary' => $theme['color_primary'],
                        'secondary' => $theme['color_secondary'],
                        'accent' => $theme['color_accent'],
                        'background' => $theme['color_background'],
                        'text' => $theme['color_text'],
                        'card_bg' => $theme['color_card_bg']
                    ],
                    'fonts' => [
                        'main' => $theme['font_main']
                    ]
                ]
            ],
            'time_rules' => $timeRules,
            'moods' => $moods,
            'categories' => $categories,
            'items' => $items
        ]
    ];

    sendJsonResponse($response);
}

// =====================================================
// توابع کمکی برای دریافت داده‌ها
// =====================================================

function getTenant($pdo, $tenantId) {
    $stmt = $pdo->prepare("SELECT * FROM tenants WHERE id = :id AND active = 1");
    $stmt->execute([':id' => $tenantId]);
    return $stmt->fetch();
}

function getTheme($pdo, $tenantId) {
    $stmt = $pdo->prepare("SELECT * FROM tenant_themes WHERE tenant_id = :id");
    $stmt->execute([':id' => $tenantId]);
    $theme = $stmt->fetch();
    
    // Fallback به مقادیر پیش‌فرض
    if (!$theme) {
        return [
            'color_primary' => '#6B4423',
            'color_secondary' => '#D4A574',
            'color_accent' => '#B8860B',
            'color_background' => '#faf8f3',
            'color_text' => '#3E2723',
            'color_card_bg' => '#e6ccb2',
            'font_main' => 'Abol, sans-serif'
        ];
    }
    return $theme;
}

function getTimeRules($pdo, $tenantId) {
    $stmt = $pdo->prepare("SELECT time_key, start_time, end_time FROM tenant_time_rules WHERE tenant_id = :id ORDER BY time_key");
    $stmt->execute([':id' => $tenantId]);
    $rules = [];
    while ($row = $stmt->fetch()) {
        $rules[$row['time_key']] = [
            'start' => substr($row['start_time'], 0, 5), // HH:MM format
            'end' => substr($row['end_time'], 0, 5)
        ];
    }
    return $rules;
}

function getMoods($pdo, $tenantId) {
    $stmt = $pdo->prepare("SELECT mood_id as id, label, color FROM tenant_moods WHERE tenant_id = :id AND active = 1 ORDER BY display_order");
    $stmt->execute([':id' => $tenantId]);
    return $stmt->fetchAll();
}

function getCategories($pdo, $tenantId) {
    $stmt = $pdo->prepare("SELECT id, title, description, image_url as image, lottie_url FROM categories WHERE tenant_id = :id AND active = 1 ORDER BY display_order");
    $stmt->execute([':id' => $tenantId]);
    return $stmt->fetchAll();
}

function getMenuItems($pdo, $tenantId) {
    // دریافت آیتم‌ها
    $stmt = $pdo->prepare("
        SELECT id, category_id, name, description, price, image_url as image, available 
        FROM menu_items 
        WHERE tenant_id = :id AND available = 1 
        ORDER BY category_id, display_order
    ");
    $stmt->execute([':id' => $tenantId]);
    $items = $stmt->fetchAll();

    // برای هر آیتم، مودها و زمان‌های دسترسی را اضافه می‌کنیم
    foreach ($items as &$item) {
        // دریافت مودها
        $moodStmt = $pdo->prepare("
            SELECT tm.mood_id 
            FROM item_moods im 
            JOIN tenant_moods tm ON im.mood_id = tm.id 
            WHERE im.item_id = :item_id
        ");
        $moodStmt->execute([':item_id' => $item['id']]);
        $item['moods'] = $moodStmt->fetchAll(PDO::FETCH_COLUMN);

        // دریافت زمان‌های دسترسی
        $timeStmt = $pdo->prepare("SELECT time_key FROM item_time_availability WHERE item_id = :item_id");
        $timeStmt->execute([':item_id' => $item['id']]);
        $item['time_availability'] = $timeStmt->fetchAll(PDO::FETCH_COLUMN);
    }

    return $items;
}