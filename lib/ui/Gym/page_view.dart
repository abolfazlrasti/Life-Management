import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class _C {
  static const glassTop = Color(0x99262628);
  static const glassBottom = Color(0x8019191A);
  static const searchFill = Color(0x1FFFFFFF);
  static const itemBg = Color(0xFF2D2D2F);
  static const imageBg = Color(0xFF353537);
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
  static const double _innerRadius = 8; // گردی گزینه‌های وسط

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
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(999)),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: _searchCtrl,
      onChanged: _onQueryChanged,
      cursorColor: _C.accentSoft,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(
        color: _C.text,
        fontSize: 15,
        fontFamily: _C.fontFamily,
      ),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(
          color: _C.textSec,
          fontSize: 15,
          fontFamily: _C.fontFamily,
        ),
        filled: true,
        fillColor: _C.searchFill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _C.textSec,
          size: 20,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 46,
          minHeight: 48,
        ),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                onPressed: _clearSearch,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: _C.textSec,
                visualDensity: VisualDensity.compact,
              ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 46,
          minHeight: 48,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }

  /// فقط دستگیره ثابت می‌ماند
  Widget _handle() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// عنوان + سرچ‌بار؛ همراه لیست اسکرول می‌شوند و بالا می‌روند
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Exercises',
              style: TextStyle(
                color: _C.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: _C.fontFamily,
              ),
            ),
          ),
          _searchBar(),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: _C.textDim),
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
              const SizedBox(height: 6),
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
      size: 20,
    );

    return Container(
      width: 44,
      height: 44,
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
              cacheWidth: 132,
              filterQuality: FilterQuality.low,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 2),
      child: Material(
        color: _C.itemBg,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _selectExercise(ex),
          borderRadius: radius,
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _exerciseImage(ex),
                const SizedBox(width: 14),
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
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                          fontFamily: _C.fontFamily,
                        ),
                      ),
                      if (ex.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          ex.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _C.textSec,
                            fontSize: 12.5,
                            height: 1.25,
                            fontFamily: _C.fontFamily,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.add_rounded, color: _C.textDim, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بدنه‌ی اسکرول: هدر + (لودینگ | خطا | خالی | لیست)
  Widget _scrollBody() {
    final Widget bodySliver;

    if (_loading) {
      bodySliver = SliverFillRemaining(
        hasScrollBody: false,
        child: _message(
          icon: Icons.fitness_center_rounded,
          title: 'Loading exercises',
          action: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _C.accentSoft,
            ),
          ),
        ),
      );
    } else if (_error != null) {
      bodySliver = SliverFillRemaining(
        hasScrollBody: false,
        child: _message(
          icon: Icons.error_outline_rounded,
          title: _error!,
          subtitle: 'Check the asset path and JSON file.',
          action: TextButton(
            onPressed: _loadExercises,
            child: const Text('Try again'),
          ),
        ),
      );
    } else if (_results.isEmpty) {
      final hasQuery = _query.trim().isNotEmpty;
      bodySliver = SliverFillRemaining(
        hasScrollBody: false,
        child: _message(
          icon: hasQuery
              ? Icons.search_off_rounded
              : Icons.fitness_center_rounded,
          title: hasQuery ? 'No exercises found' : 'No exercises available',
          subtitle: hasQuery
              ? 'Try a different name, muscle or equipment.'
              : null,
        ),
      );
    } else {
      final items = _results;
      bodySliver = SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        sliver: SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _exerciseTile(items[index], index, items.length),
        ),
      );
    }

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: _header()),
        bodySliver,
      ],
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
                  _handle(),
                  Expanded(child: _scrollBody()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
