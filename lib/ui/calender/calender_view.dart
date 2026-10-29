import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// ─────────────────────────────────────────────────────────────
///  Occasions data
/// ─────────────────────────────────────────────────────────────

enum OccasionType { holiday, iranian, international }

class Occasion {
  final String title;
  final OccasionType type;
  const Occasion(this.title, this.type);
}

class OccasionData {
  OccasionData._();

  /// تاریخ قمری در ایران بر اساس رؤیت هلال تعیین می‌شود و ممکن است با
  /// محاسبه‌ی پکیج hijri یک روز اختلاف داشته باشد.
  /// اگر اختلاف داشت این عدد را 1 یا -1 کن.
  static const int hijriOffsetDays = 0;

  static HijriCalendar hijriOf(DateTime gregorian) {
    return HijriCalendar.fromDate(
      DateTime(
        gregorian.year,
        gregorian.month,
        gregorian.day + hijriOffsetDays,
      ),
    );
  }

  // کلیدها: ماه * 100 + روز
  // ── تعطیلات رسمی شمسی
  static const Map<int, String> _solarHolidays = {
    101: 'عید نوروز',
    102: 'عید نوروز',
    103: 'عید نوروز',
    104: 'عید نوروز',
    112: 'روز جمهوری اسلامی ایران',
    113: 'روز طبیعت (سیزده‌به‌در)',
    314: 'رحلت امام خمینی (ره)',
    315: 'قیام ۱۵ خرداد',
    1122: 'پیروزی انقلاب اسلامی',
    1229: 'روز ملی شدن صنعت نفت',
  };

  // ── تعطیلات رسمی قمری
  static const Map<int, String> _hijriHolidays = {
    109: 'تاسوعای حسینی',
    110: 'عاشورای حسینی',
    220: 'اربعین حسینی',
    228: 'رحلت پیامبر (ص) و شهادت امام حسن (ع)',
    317: 'میلاد پیامبر (ص) و امام صادق (ع)',
    603: 'شهادت حضرت فاطمه (س)',
    713: 'ولادت امام علی (ع) و روز پدر',
    727: 'مبعث پیامبر اکرم (ص)',
    815: 'ولادت حضرت قائم (عج)',
    921: 'شهادت امام علی (ع)',
    1001: 'عید سعید فطر',
    1002: 'تعطیل به مناسبت عید فطر',
    1025: 'شهادت امام صادق (ع)',
    1210: 'عید سعید قربان',
    1218: 'عید سعید غدیر خم',
  };

  // ── مناسبت‌ها و روزهای ملی ایران (شمسی)
  static const Map<int, String> _iranianDays = {
    201: 'بزرگداشت سعدی',
    212: 'روز معلم',
    225: 'بزرگداشت فردوسی',
    228: 'بزرگداشت خیام',
    303: 'آزادسازی خرمشهر',
    407: 'روز قوه قضاییه',
    514: 'سالروز مشروطیت',
    517: 'روز خبرنگار',
    601: 'بزرگداشت ابوعلی سینا (روز پزشک)',
    631: 'آغاز هفته دفاع مقدس',
    707: 'روز آتش‌نشانی و ایمنی',
    708: 'بزرگداشت مولوی',
    720: 'بزرگداشت حافظ',
    807: 'روز کوروش بزرگ',
    813: 'روز دانش‌آموز',
    824: 'روز کتاب و کتابخوانی',
    905: 'روز بسیج مستضعفان',
    907: 'روز نیروی دریایی',
    916: 'روز دانشجو',
    930: 'شب یلدا',
    1009: 'روز بصیرت',
    1205: 'روز مهندسی',
    1225: 'روز پژوهش',
  };

  // ── روزهای جهانی (میلادی)
  static const Map<int, List<String>> _internationalDays = {
    101: ['آغاز سال نو میلادی'],
    124: ['روز جهانی آموزش'],
    127: ['روز جهانی یادبود قربانیان هولوکاست'],
    204: ['روز جهانی سرطان'],
    211: ['روز جهانی زنان و دختران در علم'],
    221: ['روز جهانی زبان مادری'],
    308: ['روز جهانی زن'],
    320: ['روز جهانی شادی'],
    321: ['روز جهانی نوروز', 'روز جهانی شعر'],
    322: ['روز جهانی آب'],
    323: ['روز جهانی هواشناسی'],
    324: ['روز جهانی مبارزه با سل'],
    402: ['روز جهانی آگاهی از اوتیسم'],
    407: ['روز جهانی بهداشت'],
    422: ['روز جهانی زمین'],
    423: ['روز جهانی کتاب'],
    501: ['روز جهانی کارگر'],
    503: ['روز جهانی آزادی مطبوعات'],
    515: ['روز جهانی خانواده'],
    518: ['روز جهانی موزه'],
    531: ['روز جهانی بدون دخانیات'],
    605: ['روز جهانی محیط زیست'],
    608: ['روز جهانی اقیانوس‌ها'],
    614: ['روز جهانی اهدای خون'],
    620: ['روز جهانی پناهنده'],
    711: ['روز جهانی جمعیت'],
    812: ['روز جهانی جوانان'],
    819: ['روز جهانی کمک‌های بشردوستانه'],
    908: ['روز جهانی سوادآموزی'],
    921: ['روز جهانی صلح'],
    927: ['روز جهانی گردشگری'],
    929: ['روز جهانی قلب'],
    1001: ['روز جهانی سالمندان'],
    1005: ['روز جهانی معلم'],
    1010: ['روز جهانی بهداشت روان'],
    1016: ['روز جهانی غذا'],
    1024: ['روز سازمان ملل متحد'],
    1029: ['روز جهانی سکته مغزی', 'روز جهانی اینترنت'],
    1110: ['روز جهانی علم'],
    1114: ['روز جهانی دیابت'],
    1116: ['روز جهانی تحمل و مدارا'],
    1120: ['روز جهانی کودک'],
    1125: ['روز جهانی مبارزه با خشونت علیه زنان'],
    1201: ['روز جهانی مبارزه با ایدز'],
    1203: ['روز جهانی افراد دارای معلولیت'],
    1210: ['روز جهانی حقوق بشر'],
  };

  static List<Occasion> forDate(Jalali date) {
    final gregorian = date.toDateTime();
    final hijri = hijriOf(gregorian);
    final result = <Occasion>[];

    // ── تعطیلات
    if (date.weekDay == 7) {
      result.add(const Occasion('جمعه، تعطیل آخر هفته', OccasionType.holiday));
    }

    final solarHoliday = _solarHolidays[date.month * 100 + date.day];
    if (solarHoliday != null) {
      result.add(Occasion(solarHoliday, OccasionType.holiday));
    }

    final hijriHoliday = _hijriHolidays[hijri.hMonth * 100 + hijri.hDay];
    if (hijriHoliday != null) {
      result.add(Occasion(hijriHoliday, OccasionType.holiday));
    }

    // شهادت امام رضا (ع): آخرین روز ماه صفر (۲۹ یا ۳۰)
    if (hijri.hMonth == 2 &&
        hijri.hDay == hijri.getDaysInMonth(hijri.hYear, hijri.hMonth)) {
      result.add(const Occasion('شهادت امام رضا (ع)', OccasionType.holiday));
    }

    // ── مناسبت‌های ایران
    final iranian = _iranianDays[date.month * 100 + date.day];
    if (iranian != null) {
      result.add(Occasion(iranian, OccasionType.iranian));
    }

    // ── روزهای جهانی
    final international =
        _internationalDays[gregorian.month * 100 + gregorian.day];
    if (international != null) {
      for (final title in international) {
        result.add(Occasion(title, OccasionType.international));
      }
    }

    return result;
  }
}

/// ─────────────────────────────────────────────────────────────
///  Calendar page
/// ─────────────────────────────────────────────────────────────

class CalendarView extends StatefulWidget {
  static String routeName = '/Calendar';

  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  static const Color backgroundColor = Color(0xFF0C0C0C);
  static const Color cardColor = Color(0xFF19191A);
  static const Color selectedColor = Color(0xFF303031);
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFF8E8E93);
  static const Color holidayColor = Color(0xFFFF7777);
  static const Color todayHolidayColor = Color(0xFFE5484D);

  static const double gridSpacing = 6;

  /// فضای خالی انتهای صفحه برای اینکه محتوا زیر نوار ناوبری نره.
  /// اگه ارتفاع نوار پایین اپت فرق داره این عدد رو تغییر بده.
  static const double bottomNavSpace = 110;

  static const List<String> weekdays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  static const List<String> gregorianMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> jalaliMonthsEn = [
    'Farvardin',
    'Ordibehesht',
    'Khordad',
    'Tir',
    'Mordad',
    'Shahrivar',
    'Mehr',
    'Aban',
    'Azar',
    'Dey',
    'Bahman',
    'Esfand',
  ];

  late final Jalali today;
  late Jalali displayedMonth;
  late Jalali selectedDate;

  /// جهت اسلاید انیمیشن ماه: 1 = ماه بعد، -1 = ماه قبل
  int slideDirection = 1;

  @override
  void initState() {
    super.initState();
    today = Jalali.now();
    selectedDate = today;
    displayedMonth = Jalali(today.year, today.month, 1);
  }

  String dateKey(Jalali date) => '${date.year}/${date.month}/${date.day}';

  bool isSameDay(Jalali a, Jalali b) => dateKey(a) == dateKey(b);

  bool isSameMonth(Jalali a, Jalali b) =>
      a.year == b.year && a.month == b.month;

  void changeMonth(int amount) {
    final index =
        displayedMonth.year * 12 + (displayedMonth.month - 1) + amount;
    HapticFeedback.selectionClick();
    setState(() {
      slideDirection = amount >= 0 ? 1 : -1;
      displayedMonth = Jalali(index ~/ 12, index % 12 + 1, 1);
    });
  }

  void goToToday() {
    HapticFeedback.selectionClick();
    final target = Jalali(today.year, today.month, 1);
    final isBefore =
        displayedMonth.year * 12 + displayedMonth.month >
        target.year * 12 + target.month;
    setState(() {
      slideDirection = isBefore ? -1 : 1;
      displayedMonth = target;
      selectedDate = today;
    });
  }

  void selectDate(Jalali date) {
    HapticFeedback.selectionClick();
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedFormatter = selectedDate.formatter;

    final gregorianDate = selectedDate.toDateTime();
    final hijriDate = OccasionData.hijriOf(gregorianDate);
    final occasions = OccasionData.forDate(selectedDate);

    final isCurrentMonth = isSameMonth(displayedMonth, today);
    final isOnToday = isSameDay(selectedDate, today) && isCurrentMonth;
    final gridKey = ValueKey('${displayedMonth.year}/${displayedMonth.month}');

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _buildTitle(isCurrentMonth),
        actions: [
          if (!isOnToday)
            IconButton(
              tooltip: 'Today',
              onPressed: goToToday,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 26,
                color: primaryTextColor,
              ),
            ),
          IconButton(
            onPressed: () {
              // TODO: open the Add page for [selectedDate]
            },
            icon: const Icon(
              Icons.add_rounded,
              size: 32,
              color: primaryTextColor,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomNavSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Weekday header (aligned with the tiles)
              Row(
                children: [
                  for (var i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(width: gridSpacing),
                    Expanded(
                      child: Center(
                        child: Text(
                          weekdays[i],
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: i == 6 ? holidayColor : secondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),

              // ── Month grid (swipe left/right to change month)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity < -250) {
                    changeMonth(1);
                  } else if (velocity > 250) {
                    changeMonth(-1);
                  }
                },
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    layoutBuilder: (current, previous) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [...previous, if (current != null) current],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      final isIncoming = child.key == gridKey;
                      final dx = (isIncoming ? 0.08 : -0.08) * slideDirection;
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(dx, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildMonthGrid(displayedMonth),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Three date boxes: Jalali / Gregorian / Hijri
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DateCard(
                    day: '${selectedDate.day}',
                    month: selectedFormatter.mN,
                    year: '${selectedDate.year}',
                    fontFamily: 'Vazirmatn',
                  ),
                  const SizedBox(width: 14),
                  _DateCard(
                    day: '${gregorianDate.day}',
                    month: gregorianMonths[gregorianDate.month - 1],
                    year: '${gregorianDate.year}',
                    fontFamily: 'inter',
                  ),
                  const SizedBox(width: 14),
                  _DateCard(
                    day: '${hijriDate.hDay}',
                    month: hijriDate.getLongMonthName(),
                    year: '${hijriDate.hYear}',
                    fontFamily: 'Vazirmatn',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Occasions box
              _OccasionsCard(
                dateLabel:
                    '${selectedFormatter.wN} ${selectedDate.day} ${selectedFormatter.mN}',
                occasions: occasions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Calendar" در ماه جاری؛ در ماه‌های دیگه اسم ماه به انگلیسی.
  /// موقع سوایپ، عنوان قبلی به یه سمت می‌ره و عنوان جدید از سمت مقابل میاد.
  Widget _buildTitle(bool isCurrentMonth) {
    final titleKey = ValueKey(
      isCurrentMonth
          ? 'calendar'
          : '${displayedMonth.year}/${displayedMonth.month}',
    );

    final Widget title = isCurrentMonth
        ? Text(
            'Calendar',
            key: titleKey,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'inter',
              color: primaryTextColor,
            ),
          )
        : Text.rich(
            key: titleKey,
            TextSpan(
              children: [
                TextSpan(
                  text: jalaliMonthsEn[displayedMonth.month - 1],
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'inter',
                    color: primaryTextColor,
                  ),
                ),
                TextSpan(
                  text: '  ${displayedMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'inter',
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          );

    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (current, previous) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [...previous, if (current != null) current],
          );
        },
        transitionBuilder: (child, animation) {
          final isIncoming = child.key == titleKey;
          final dx = (isIncoming ? 0.6 : -0.6) * slideDirection;
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(dx, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: title,
      ),
    );
  }

  Widget _buildMonthGrid(Jalali month) {
    final daysInMonth = month.monthLength;
    final startingOffset = month.weekDay - 1;

    return GridView.builder(
      key: ValueKey('${month.year}/${month.month}'),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: gridSpacing,
        crossAxisSpacing: gridSpacing,
        childAspectRatio: 1.1,
      ),
      itemCount: startingOffset + daysInMonth,
      itemBuilder: (context, index) {
        final day = index - startingOffset + 1;
        if (day < 1) return const SizedBox.shrink();
        return _buildDayTile(Jalali(month.year, month.month, day));
      },
    );
  }

  Widget _buildDayTile(Jalali date) {
    final isSelected = isSameDay(date, selectedDate);
    final isToday = isSameDay(date, today);

    final occasions = OccasionData.forDate(date);
    final isDayHoliday = occasions.any((o) => o.type == OccasionType.holiday);
    final hasOccasion = occasions.any((o) => o.type != OccasionType.holiday);

    final Color tileColor = isToday
        ? Colors.white
        : (isSelected ? selectedColor : cardColor);

    final Color textColor = isToday
        ? (isDayHoliday ? todayHolidayColor : Colors.black)
        : (isDayHoliday ? holidayColor : primaryTextColor);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => selectDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(14),
          border: isSelected && !isToday
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.55),
                  width: 1.4,
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontFamily: 'inter',
                fontSize: 17,
                fontWeight: isToday || isSelected
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: textColor,
              ),
            ),
            if (hasOccasion)
              Positioned(
                bottom: 6,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday ? Colors.black45 : secondaryTextColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
///  Widgets
/// ─────────────────────────────────────────────────────────────

class _DateCard extends StatelessWidget {
  final String day;
  final String month;
  final String year;
  final String fontFamily;

  const _DateCard({
    required this.day,
    required this.month,
    required this.year,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 108,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF19191A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              month,
              maxLines: 1,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            year,
            style: const TextStyle(
              fontFamily: 'inter',
              fontSize: 11,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

class _OccasionsCard extends StatelessWidget {
  final String dateLabel;
  final List<Occasion> occasions;

  const _OccasionsCard({required this.dateLabel, required this.occasions});

  static const Color holidayColor = Color(0xFFFF7777);
  static const Color iranianColor = Color(0xFF64D9A0);
  static const Color internationalColor = Color(0xFFFBBF24);
  static const Color secondaryTextColor = Color(0xFF8E8E93);

  static Color colorOf(OccasionType type) {
    switch (type) {
      case OccasionType.holiday:
        return holidayColor;
      case OccasionType.iranian:
        return iranianColor;
      case OccasionType.international:
        return internationalColor;
    }
  }

  static String labelOf(OccasionType type) {
    switch (type) {
      case OccasionType.holiday:
        return 'تعطیل';
      case OccasionType.iranian:
        return 'ایران';
      case OccasionType.international:
        return 'جهانی';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF19191A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'مناسبت‌ها',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (occasions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'مناسبتی برای این روز ثبت نشده است',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                )
              else
                for (final occasion in occasions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorOf(occasion.type),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            occasion.title,
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorOf(occasion.type)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            labelOf(occasion.type),
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorOf(occasion.type),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
