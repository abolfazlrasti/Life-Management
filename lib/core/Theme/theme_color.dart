import 'package:flutter/material.dart';

class AppColors {
  // ---- پس‌زمینه‌ها و سطوح (خاکستری خنثی، پلکانی روی #121212) ----
  static const background = Color(0xFF121212); // پس‌زمینه اصلی
  static const backgroundSecondary = Color(0xFF181818); // پس‌زمینه ثانویه
  static const surface = Color(0xFF1E1E20); // کارت‌ها و سطوح
  static const surfaceElevated = Color(0xFF28282B); // سطح برجسته (منو، دیالوگ)
  static const selected = Color(0xFF333337); // آیتم انتخاب‌شده
  static const divider = Color(0xFF2C2C30); // خطوط جداکننده

  // ---- متن ----
  static const textPrimary = Color(0xFFF4F4F5);
  static const textSecondary = Color(0xFFA1A1AA);
  static const textDisabled = Color(0xFF6B6B74);

  // ---- رنگ کلیدی (دکمه‌ها، سوییچ، پیشرفت) ----
  // بنفش الکتریکی: روی خاکستری تیره زنده و مدرن دیده می‌شود و سفید روی آن
  // خوانا است (کنتراست حدود 4.6).
  static const accent = Color(0xFF6E5BFF);
  // نسخه‌ی روشن‌تر برای متن/لینک/فوکوس روی پس‌زمینه‌ی تیره
  static const accentSoft = Color(0xFFA99DFF);

  // ---- رنگ‌های معنایی ----
  static const success = Color(0xFF3DDC97); // سبز نعنایی
  static const warning = Color(0xFFFFB84D);
  static const error = Color(0xFFFF6B6B); // خطا و هزینه

  // نام‌های قدیمی برای اینکه فایل‌های دیگه‌ات نشکنن
  static const border = divider;
  static const primary = textPrimary; // متن اصلی
  static const secondary = textSecondary; // متن ثانویه
  static const tertiary = textDisabled; // غیرفعال / کم‌اهمیت

  // متن روی رنگ تأکیدی (بنفش تیره است، پس متن سفید)
  static const onAccent = Colors.white;
}
