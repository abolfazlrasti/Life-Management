import 'package:flutter/material.dart';

enum _DayParity { none, even, odd }

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _categoryKey = GlobalKey();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final List<String> _category = [
    'Daily Routine',
    'Personal Goal',
    'Habit',
    'Learning',
    'Health and Peace',
    'Sports',
    'Personal tasks',
    'Free Time',
  ];

  String _itemselet = 'Daily Routine';

  // ---- زمان‌بندی ----
  // هفته از شنبه شروع می‌شود: 0=شنبه ... 6=جمعه
  static const _dayNames = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  // DateTime.weekday: دوشنبه=1 ... یکشنبه=7  →  شنبه=0 ... جمعه=6
  static int _weekdayIndex(DateTime d) => (d.weekday + 1) % 7;

  bool _onlyToday = false;
  DateTime? _todayDate; // تاریخ ثبت‌شده برای «فقط امروز»
  Set<int> _days = {};
  _DayParity _parity = _DayParity.none; // زوج/فرد بر اساس عدد روز ماه
  DateTime? _from;
  DateTime? _to;

  // ---- پالت رنگ ----
  static const _bg = Color(0xFF0B0B0C); // پس‌زمینه اصلی (متن روی رنگ تأکیدی)
  static const _sheet = Color(0xFF19191A); // بدنه‌ی شیت / کارت‌ها
  static const _surface = Color(0xFF242426); // فیلدها و سطح برجسته
  static const _selected = Color(0xFF303031); // آیتم انتخاب‌شده / دستگیره
  static const _line = Color(0xFF29292B); // خطوط جداکننده
  static const _text = Color(0xFFF5F5F5); // متن اصلی
  static const _textSec = Color(0xFFA1A1AA); // متن ثانویه
  static const _textDim = Color(0xFF66666E); // متن غیرفعال
  static const _accent = Color(0xFF64D9A0); // سبز نعنایی
  static const _error = Color(0xFFFF7777); // خطا

  static const _edge = 12.0; // فاصله دکمه‌ها از لبه

  double _dragY = 0;
  bool _dragging = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _dragging = true;
      _dragY = (_dragY + d.delta.dy).clamp(0.0, double.infinity);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    if (_dragY > 120 || velocity > 700) {
      Navigator.pop(context);
    } else {
      setState(() {
        _dragging = false;
        _dragY = 0; // برگشت نرم به جای اولیه
      });
    }
  }

  // ---------- ابزارهای کمکی ----------

  InputDecoration _dec(String label, {String? helper, bool alignHint = false}) {
    OutlineInputBorder b(Color? c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: c == null ? BorderSide.none : BorderSide(color: c),
    );
    return InputDecoration(
      labelText: label,
      helperText: helper,
      alignLabelWithHint: alignHint,
      labelStyle: const TextStyle(color: _textSec),
      helperStyle: const TextStyle(color: _textDim),
      floatingLabelStyle: const TextStyle(color: _accent),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: b(null),
      enabledBorder: b(null),
      focusedBorder: b(_accent),
      errorBorder: b(_error),
      focusedErrorBorder: b(_error),
      errorStyle: const TextStyle(color: _error),
    );
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static String _fmtDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  // آیا فعالیت در تاریخ داده‌شده باید انجام شود؟ (برای استفاده در لیست‌ها)
  bool occursOn(DateTime date) {
    if (_onlyToday) {
      final t = _todayDate;
      return t != null &&
          t.year == date.year &&
          t.month == date.month &&
          t.day == date.day;
    }
    if (_parity == _DayParity.even && date.day.isOdd) return false;
    if (_parity == _DayParity.odd && date.day.isEven) return false;
    if (_days.isNotEmpty && !_days.contains(_weekdayIndex(date))) return false;
    return true;
  }

  String get _scheduleSummary {
    String days;
    if (_onlyToday) {
      days = 'Today';
    } else {
      final parts = <String>[];
      if (_parity == _DayParity.even) parts.add('Even days');
      if (_parity == _DayParity.odd) parts.add('Odd days');
      if (_days.isNotEmpty && _days.length < 7) {
        final sorted = _days.toList()..sort();
        parts.add(
          sorted.length <= 3
              ? sorted.map((i) => _dayNames[i]).join(', ')
              : '${sorted.length} days',
        );
      }
      days = parts.isEmpty ? 'Every day' : parts.join(' · ');
    }

    String? time;
    if (_from != null && _to != null) {
      time = '${_fmt(_from!)}–${_fmt(_to!)}';
    } else if (_from != null) {
      time = 'from ${_fmt(_from!)}';
    } else if (_to != null) {
      time = 'until ${_fmt(_to!)}';
    }
    return time == null ? days : '$days · $time';
  }

  // showTimePicker مقدار TimeOfDay می‌دهد؛ اینجا به DateTime تبدیل می‌شود
  Future<DateTime?> _pickTime(BuildContext ctx, DateTime? initial) async {
    final base = initial ?? DateTime.now(); // ساعت پیش‌فرض: همین لحظه

    final t = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay(hour: base.hour, minute: base.minute),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _accent,
            onPrimary: _bg,
            surface: _surface,
            onSurface: _text,
          ),
        ),
        child: child!,
      ),
    );
    if (t == null) return null;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, t.hour, t.minute);
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _accent : _sheet,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : _line),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _bg : _textSec,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _timeBox(String label, DateTime? value, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: _sheet,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: _textSec, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value == null ? '--:--' : _fmt(value),
                  style: TextStyle(
                    color: value == null ? _textDim : _text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t, style: const TextStyle(color: _textSec, fontSize: 12)),
  );

  // ---------- منوی دسته‌بندی ----------

  Future<void> _pickCategory() async {
    FocusScope.of(context).unfocus();

    final box = _categoryKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final menuWidth = box.size.width; // هم‌عرض فیلد دسته‌بندی

    final position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy + box.size.height + 6,
      overlay.size.width - topLeft.dx - menuWidth,
      0,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      color: _surface,
      elevation: 12,
      shadowColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      constraints: BoxConstraints.tightFor(width: menuWidth),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _line),
      ),
      items: _category.map((item) {
        final selected = item == _itemselet;
        return PopupMenuItem<String>(
          value: item,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? _text : _textSec,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_rounded, color: _accent, size: 16),
            ],
          ),
        );
      }).toList(),
    );

    if (result != null) setState(() => _itemselet = result);
  }

  // ---------- پنجره‌ی زمان‌بندی ----------

  Future<void> _pickSchedule() async {
    FocusScope.of(context).unfocus();

    var onlyToday = _onlyToday;
    var days = Set<int>.from(_days);
    var parity = _parity;
    DateTime? from = _from;
    DateTime? to = _to;
    String? timeError;

    final saved = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Dialog(
            backgroundColor: _surface,
            surfaceTintColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: _line),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule',
                    style: TextStyle(
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // فقط امروز
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setS(() => onlyToday = !onlyToday),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: onlyToday,
                              onChanged: (v) =>
                                  setS(() => onlyToday = v ?? false),
                              activeColor: _accent,
                              checkColor: _bg,
                              side: const BorderSide(color: _textSec),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Only today (${_fmtDate(DateTime.now())})',
                            style: const TextStyle(color: _text, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // روزها (وقتی «فقط امروز» روشن است غیرفعال می‌شود)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: onlyToday ? 0.3 : 1,
                    child: IgnorePointer(
                      ignoring: onlyToday,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('Repeat'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _pill('Even days', parity == _DayParity.even, () {
                                setS(
                                  () => parity = parity == _DayParity.even
                                      ? _DayParity.none
                                      : _DayParity.even,
                                );
                              }),
                              _pill('Odd days', parity == _DayParity.odd, () {
                                setS(
                                  () => parity = parity == _DayParity.odd
                                      ? _DayParity.none
                                      : _DayParity.odd,
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _sectionLabel('Days'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(7, (i) {
                              return _pill(_dayNames[i], days.contains(i), () {
                                setS(() {
                                  days.contains(i)
                                      ? days.remove(i)
                                      : days.add(i);
                                });
                              });
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ساعت
                  _sectionLabel('Time'),
                  Row(
                    children: [
                      _timeBox('From', from, () async {
                        final t = await _pickTime(ctx, from);
                        if (t != null) {
                          setS(() {
                            from = t;
                            timeError = null;
                          });
                        }
                      }),
                      const SizedBox(width: 10),
                      _timeBox('To', to, () async {
                        final t = await _pickTime(ctx, to);
                        if (t != null) {
                          setS(() {
                            to = t;
                            timeError = null;
                          });
                        }
                      }),
                    ],
                  ),
                  if (timeError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      timeError!,
                      style: const TextStyle(color: _error, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: TextButton(
                      onPressed: () {
                        if (from != null && to != null && !to!.isAfter(from!)) {
                          setS(
                            () =>
                                timeError = 'End time must be after start time',
                          );
                          return;
                        }
                        Navigator.pop(ctx, true);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: _bg,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (saved == true) {
      setState(() {
        _onlyToday = onlyToday;
        _todayDate = onlyToday ? DateTime.now() : null;
        _days = days;
        _parity = parity;
        _from = from;
        _to = to;
      });
    }
  }

  // ---------- UI ----------

  Widget _pickerField({
    Key? key,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      key: key,
      color: _surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(color: _textSec, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _text, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: _textSec),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: _dragging ? Duration.zero : const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _dragY, 0),
        margin: EdgeInsets.only(top: topInset + 8),
        decoration: const BoxDecoration(
          color: _sheet,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // دستگیره: با کشیدن به پایین، صفحه بسته می‌شود
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: _onDragUpdate,
              onVerticalDragEnd: _onDragEnd,
              child: SizedBox(
                width: double.infinity,
                height: 24,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _selected,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

            // هدر: Cancel | New Page | ✓
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _edge),
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'New Page',
                      style: TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: _surface,
                          foregroundColor: _text,
                          fixedSize: const Size(72, 36),
                          padding: EdgeInsets.zero,
                          shape: const StadiumBorder(
                            side: BorderSide(color: _line),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // TODO: save
                            // نام: _nameCtrl.text | دسته: _itemselet
                            // امروز: _onlyToday (_todayDate)
                            // روزها: _days (0=شنبه..6=جمعه) | زوج/فرد: _parity
                            // ساعت: _from تا _to (DateTime)
                            // توضیحات: _descCtrl.text
                          }
                        },
                        icon: const Icon(Icons.check, color: _bg, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: _text,
                          fixedSize: const Size(36, 36),
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // بدنه
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        cursorColor: _accent,
                        cursorErrorColor: _error,
                        style: const TextStyle(color: _text),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a name'
                            : null,
                        decoration: _dec(
                          'Activity Name',
                          helper: 'Enter the name of your activity',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // دسته‌بندی + زمان‌بندی کنار هم
                      // IntrinsicHeight: جلوگیری از ارتفاع نامحدود داخل اسکرول
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _pickerField(
                                key: _categoryKey,
                                label: 'Category',
                                value: _itemselet,
                                onTap: _pickCategory,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _pickerField(
                                label: 'Schedule',
                                value: _scheduleSummary,
                                onTap: _pickSchedule,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // توضیحات
                      TextFormField(
                        controller: _descCtrl,
                        minLines: 4,
                        maxLines: 6,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: _accent,
                        style: const TextStyle(color: _text),
                        decoration: _dec('Description', alignHint: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
