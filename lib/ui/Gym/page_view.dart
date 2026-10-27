import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class _C {
  static const glassTop = Color(0x99262628);
  static const glassBottom = Color(0x8019191A);
  static const glassBorder = Color(0x1FFFFFFF);
  static const searchFill = Color(0x2EFFFFFF);
  static const itemBg = Color(0xFF2D2D2F);
  static const imageBg = Color(0xFF353537);
  static const chipBg = Color(0xFF39393B);
  static const text = Color(0xFFF4F4F5);
  static const textSec = Color(0xFFA1A1AA);
  static const textDim = Color(0xFF6B6B74);
  static const accentSoft = Color(0xFFA99DFF);
  static const fontFamily = 'inter';
}

/// مدل سبک برای هر حرکت؛ همه‌چیز یک بار هنگام لود محاسبه می‌شود
class _Exercise {
  final Map<String, dynamic> raw;
  final String name;
  final String subtitle;
  final String imageUrl;
  final String nameKey;
  final String searchKey;

  const _Exercise({
    required this.raw,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.nameKey,
    required this.searchKey,
  });
}

class GymPageView extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onExerciseSelected;

  const GymPageView({super.key, required this.onExerciseSelected});

  @override
  State<GymPageView> createState() => _GymPageViewState();
}

class _GymPageViewState extends State<GymPageView> {
  static const double _sheetRadius =
      32; // گردی بالای صفحه = گردی گوشه‌های بیرونی لیست
  static const double _innerRadius = 10; // گردی گزینه‌های وسط

  static const List<double> _saturate = [
    1.47244, -0.42912, -0.04332, 0, 0, //
    -0.12756, 1.17088, -0.04332, 0, 0,
    -0.12756, -0.42912, 1.55668, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static final ImageFilter _filter = ImageFilter.compose(
    outer: const ColorFilter.matrix(_saturate),
    inner: ImageFilter.blur(sigmaX: 28, sigmaY: 28, tileMode: TileMode.mirror),
  );

  static const String _imageBaseUrl =
      'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/';

  final TextEditingController _searchCtrl = TextEditingController();

  List<_Exercise> _all = [];
  List<_Exercise> _results = [];

  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── Data ─────────────────────────

  Future<void> _loadExercises() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final raw = await rootBundle.loadString('assets/data/exercises.json');
      final decoded = jsonDecode(raw);

      final List<dynamic> records = decoded is List
          ? decoded
          : decoded is Map && decoded['exercises'] is List
          ? decoded['exercises'] as List
          : throw const FormatException('Unexpected exercises.json format');

      final exercises =
          records
              .whereType<Map>()
              .map((item) => _build(Map<String, dynamic>.from(item)))
              .toList()
            ..sort((a, b) => a.nameKey.compareTo(b.nameKey));

      if (!mounted) return;

      setState(() {
        _all = exercises;
        _loading = false;
        _error = null;
      });
      _applyFilter();
    } catch (e, stackTrace) {
      debugPrint('Exercise loading error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not load exercises.json';
      });
    }
  }

  _Exercise _build(Map<String, dynamic> e) {
    final name = _titleCase(_value(e, 'name'));
    final bodyPart = _value(e, 'body_part');
    final target = _value(e, 'target');
    final equipment = _value(e, 'equipment');
    final category = _value(e, 'category');

    final subtitle = [
      if (bodyPart.isNotEmpty)
        _titleCase(bodyPart)
      else if (target.isNotEmpty)
        _titleCase(target)
      else if (category.isNotEmpty)
        _titleCase(category),
      if (equipment.isNotEmpty) _titleCase(equipment),
    ].join(' · ');

    final search = _normalize(
      [
        name,
        category,
        bodyPart,
        equipment,
        _value(e, 'muscle_group'),
        target,
      ].join(' '),
    );

    return _Exercise(
      raw: e,
      name: name.isEmpty ? 'Unnamed exercise' : name,
      subtitle: subtitle,
      imageUrl: _imageUrl(_value(e, 'image')),
      nameKey: _normalize(name),
      searchKey: search,
    );
  }

  String _value(Map<String, dynamic> exercise, String key) {
    final value = exercise[key];
    if (value == null) return '';
    if (value is String || value is num) return value.toString().trim();
    if (value is List) return value.map((item) => item.toString()).join(', ');
    return '';
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]+'), ' ')
      .trim();

  String _imageUrl(String image) {
    if (image.isEmpty) return '';
    final path = image
        .replaceAll('\\', '/')
        .split('/')
        .map(Uri.encodeComponent)
        .join('/');
    return '$_imageBaseUrl$path';
  }

  // ───────────────────────── Search ─────────────────────────

  void _applyFilter() {
    final q = _normalize(_query);

    if (q.isEmpty) {
      setState(() => _results = _all);
      return;
    }

    final tokens = q.split(' ');
    final scored = <(int, _Exercise)>[];

    for (final ex in _all) {
      // همه‌ی کلمه‌های جستجو باید در جایی از اطلاعات حرکت باشند
      if (!tokens.every(ex.searchKey.contains)) continue;

      // اولویت: شروع نام > شروع یکی از کلمه‌های نام > بقیه
      int rank = 2;
      if (ex.nameKey.startsWith(q)) {
        rank = 0;
      } else if (ex.nameKey.split(' ').any((w) => w.startsWith(tokens.first))) {
        rank = 1;
      }
      scored.add((rank, ex));
    }

    scored.sort((a, b) {
      final c = a.$1.compareTo(b.$1);
      return c != 0 ? c : a.$2.nameKey.compareTo(b.$2.nameKey);
    });

    setState(() => _results = scored.map((s) => s.$2).toList());
  }

  void _onQueryChanged(String value) {
    _query = value;
    _applyFilter();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _onQueryChanged('');
  }

  void _selectExercise(_Exercise exercise) {
    HapticFeedback.selectionClick();
    widget.onExerciseSelected(exercise.raw);
    Navigator.of(context).maybePop();
  }

  // ───────────────────────── Header ─────────────────────────

  Widget _searchBar() {
    return TextField(
      controller: _searchCtrl,
      onChanged: _onQueryChanged,
      cursorColor: _C.accentSoft,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(
        color: _C.text,
        fontSize: 16,
        fontFamily: _C.fontFamily,
      ),
      decoration: InputDecoration(
        hintText: 'Search exercises',
        hintStyle: const TextStyle(
          color: _C.textSec,
          fontSize: 16,
          fontFamily: _C.fontFamily,
        ),
        filled: true,
        fillColor: _C.searchFill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 4),
          child: Icon(Icons.search_rounded, color: _C.text, size: 24),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: _query.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 6),
                child: IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: _C.textSec,
                ),
              ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Exercises',
            style: TextStyle(
              color: _C.text,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontFamily: _C.fontFamily,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: _searchBar(),
        ),
      ],
    );
  }

  // ───────────────────────── List ─────────────────────────

  Widget _message({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: _C.textDim),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _C.textSec,
                fontSize: 15,
                fontFamily: _C.fontFamily,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _C.textDim,
                  fontSize: 13,
                  fontFamily: _C.fontFamily,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action],
          ],
        ),
      ),
    );
  }

  Widget _exerciseImage(_Exercise ex) {
    const fallback = Icon(
      Icons.fitness_center_rounded,
      color: _C.textSec,
      size: 24,
    );

    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: _C.imageBg,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: ex.imageUrl.isEmpty
          ? fallback
          : Image.network(
              ex.imageUrl,
              fit: BoxFit.cover,
              cacheWidth: 168,
              filterQuality: FilterQuality.low,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: _C.textSec,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => fallback,
            ),
    );
  }

  Widget _exerciseTile(_Exercise ex, int index, int total) {
    final isFirst = index == 0;
    final isLast = index == total - 1;

    final radius = BorderRadius.only(
      topLeft: Radius.circular(isFirst ? _sheetRadius : _innerRadius),
      topRight: Radius.circular(isFirst ? _sheetRadius : _innerRadius),
      bottomLeft: Radius.circular(isLast ? _sheetRadius : _innerRadius),
      bottomRight: Radius.circular(isLast ? _sheetRadius : _innerRadius),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
      child: Material(
        color: _C.itemBg,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _selectExercise(ex),
          borderRadius: radius,
          child: Container(
            constraints: const BoxConstraints(minHeight: 84),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _exerciseImage(ex),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ex.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _C.text,
                          fontSize: 15,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          fontFamily: _C.fontFamily,
                        ),
                      ),
                      if (ex.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          ex.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _C.textSec,
                            fontSize: 13,
                            height: 1.3,
                            fontFamily: _C.fontFamily,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: _C.chipBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: _C.text,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _exerciseList(List<_Exercise> items) {
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          _exerciseTile(items[index], index, items.length),
    );
  }

  // ───────────────────────── Build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(_sheetRadius),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // پس‌زمینه‌ی شیشه‌ای (فقط همین بخش بلر دارد)
            Positioned.fill(
              child: BackdropFilter(
                filter: _filter,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_C.glassTop, _C.glassBottom],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _header(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: _loading
                          ? _message(
                              icon: Icons.fitness_center_rounded,
                              title: 'Loading exercises',
                              action: const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _C.accentSoft,
                                ),
                              ),
                            )
                          : _error != null
                          ? _message(
                              icon: Icons.error_outline_rounded,
                              title: _error!,
                              subtitle: 'Check the asset path and JSON file.',
                              action: TextButton(
                                onPressed: _loadExercises,
                                child: const Text('Try again'),
                              ),
                            )
                          : _results.isEmpty
                          ? _message(
                              icon: _query.trim().isEmpty
                                  ? Icons.fitness_center_rounded
                                  : Icons.search_off_rounded,
                              title: _query.trim().isEmpty
                                  ? 'No exercises available'
                                  : 'No exercises found',
                              subtitle: _query.trim().isEmpty ? null : 'Try a different name, muscle or equipment.',
                            )
                          : _exerciseList(_results),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
