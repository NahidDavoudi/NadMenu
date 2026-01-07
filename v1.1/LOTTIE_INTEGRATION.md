# راهنمای یکپارچه‌سازی انیمیشن‌های Lottie

## وضعیت فعلی

✅ **تکمیل شده:**
1. افزودن Lottie Player به `index.html`
2. به‌روزرسانی ساختار دیتابیس با فیلد `lottie_url`
3. به‌روزرسانی API برای برگرداندن URL انیمیشن
4. تغییر `render.js` برای نمایش Lottie در کارت‌ها و هدر
5. تغییر `anim.js` برای انیمیشن‌های تعاملی

⚠️ **نیاز به تکمیل:**
- دانلود فایل‌های واقعی Lottie (از LottieFiles.com)

## استفاده از انیمیشن‌های آنلاین (پیشنهاد موقت)

برای تست سریع، می‌توانید `mock_data.json` را با URL های واقعی LottieFiles به‌روز کنید:

### نمونه URL های واقعی از LottieFiles:

```json
"categories": [
  {
    "id": "coffee",
    "title": "قهوه",
    "lottie_url": "https://assets5.lottiefiles.com/packages/lf20_touohxv0.json",
    "description": "قهوه‌های دمی و اسپرسو"
  },
  {
    "id": "tea",
    "title": "چای",
    "lottie_url": "https://assets9.lottiefiles.com/packages/lf20_mjlh3hcy.json",
    "description": "چای‌های خوش‌عطر"
  }
]
```

## راه‌های دریافت انیمیشن

### روش 1: استفاده از LottieFiles API (پیشنهادی)
```javascript
// در assets/js/api.js می‌توانید URL های LottieFiles را ذخیره کنید
const LOTTIE_ANIMATIONS = {
  coffee: 'https://assets5.lottiefiles.com/packages/lf20_...',
  tea: 'https://assets9.lottiefiles.com/packages/lf20_...',
  // ...
};
```

### روش 2: دانلود محلی
1. به https://lottiefiles.com بروید
2. انیمیشن را جستجو و دانلود کنید
3. در `assets/lottie/` قرار دهید
4. `mock_data.json` را با مسیر محلی به‌روز کنید:
   ```json
   "lottie_url": "./assets/lottie/coffee-cup.json"
   ```

### روش 3: Embed از LottieFiles
1. انیمیشن را در LottieFiles باز کنید
2. روی "Embed" کلیک کنید
3. لینک JSON را کپی کنید
4. در دیتابیس یا `mock_data.json` قرار دهید

## تنظیمات پیشرفته

### تنظیم سرعت انیمیشن
در `assets/js/anim.js`:
```javascript
lottiePlayer.setSpeed(1.5); // سریع‌تر
lottiePlayer.setSpeed(0.5); // آهسته‌تر
```

### حلقه یا یکبار پخش
در `assets/js/render.js`:
```html
<lottie-player
  loop          <!-- حلقه دائمی -->
  <!-- یا -->
  count="1"     <!-- فقط یکبار -->
></lottie-player>
```

### رویدادها
```javascript
const lottie = document.querySelector('lottie-player');
lottie.addEventListener('load', () => console.log('Loaded!'));
lottie.addEventListener('complete', () => console.log('Done!'));
```

## پیشنهادات انیمیشن از LottieFiles

### قهوه ☕
- https://lottiefiles.com/animations/coffee-cup-J8uWGHLqZY
- https://lottiefiles.com/animations/coffee-shop-jBr6VSGe3i

### چای 🍵
- https://lottiefiles.com/animations/tea-cup-animation-5fWP6m9h0a
- https://lottiefiles.com/animations/tea-time-loading-HZwGWfErgC

### نوشیدنی سرد 🥤
- https://lottiefiles.com/animations/cold-drink-glass-kZE8v7L9xp
- https://lottiefiles.com/animations/juice-cup-with-straw-YwN6k2q4Ro

### شیک 🥛
- https://lottiefiles.com/animations/milkshake-animation-l8X4dE6wKu
- https://lottiefiles.com/animations/smoothie-drink-cZ9vN5r3Jq

### پیتزا 🍕
- https://lottiefiles.com/animations/pizza-slice-mN7bH3k9Lp
- https://lottiefiles.com/animations/pizza-delivery-aW6yC8v2Ux

### برگر 🍔
- https://lottiefiles.com/animations/burger-build-tR5xK9n4Mp
- https://lottiefiles.com/animations/hamburger-layers-pQ2wV7m8Bn

## بهینه‌سازی عملکرد

1. **حجم فایل**: حداکثر 100KB
2. **کیفیت**: Medium تا High کافی است
3. **Frame Rate**: 30 FPS بهینه است
4. **Lazy Loading**: انیمیشن‌ها فقط هنگام نیاز بارگذاری می‌شوند

## عیب‌یابی

### انیمیشن نمایش داده نمی‌شود:
- ✅ بررسی کنید Lottie Player بارگذاری شده است
- ✅ URL انیمیشن معتبر است
- ✅ کنسول برای خطاها بررسی شود

### انیمیشن خیلی سریع/آهسته:
- تنظیم `speed` در `<lottie-player>`
- یا در JavaScript: `player.setSpeed()`

### انیمیشن قطع می‌شود:
- بررسی `loop="true"` در تگ
- یا `player.loop = true` در JS

## مثال کامل

```html
<lottie-player
  src="./assets/lottie/coffee-cup.json"
  background="transparent"
  speed="1"
  style="width: 200px; height: 200px;"
  loop
  autoplay
  class="my-animation"
></lottie-player>
```

## منابع

- **Documentation**: https://lottiefiles.com/web-player
- **Animations**: https://lottiefiles.com/featured
- **Editor**: https://lottiefiles.com/editor
- **GitHub**: https://github.com/LottieFiles/lottie-player

