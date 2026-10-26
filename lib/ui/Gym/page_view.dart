import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class _C {
  static const glassTop = Color(0x99262628);
  static const glassBottom = Color(0x8019191A);
  static const glassBorder = Color(0x1FFFFFFF);
  static const field = Color(0x14FFFFFF);
  static const text = Color(0xFFF4F4F5);
  static const textSec = Color(0xFFA1A1AA);
  static const textDim = Color(0xFF6B6B74);
  static const accentSoft = Color(0xFFA99DFF);
  static const fontFamily = 'inter';
}

class GymPageView extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onExerciseSelected;

  const GymPageView({super.key, required this.onExerciseSelected});

  @override
  State<GymPageView> createState() => _GymPageViewState();
}

class _GymPageViewState extends State<GymPageView> {
  static const List<double> _saturate = [
    1.47244,
    -0.42912,
    -0.04332,
    0,
    0,
    -0.12756,
    1.17088,
    -0.04332,
    0,
    0,
    -0.12756,
    -0.42912,
    1.55668,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static final ImageFilter _filter = ImageFilter.compose(
    outer: const ColorFilter.matrix(_saturate),
    inner: ImageFilter.blur(sigmaX: 28, sigmaY: 28, tileMode: TileMode.mirror),
  );

  static const String _imageBaseUrl =
      'https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/';

  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _exercises = [];

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

  Future<void> _loadExercises() async {
    try {
      final raw = await rootBundle.loadString('assets/data/exercises.json');

      final decoded = jsonDecode(raw);

      final List<dynamic> records = decoded is List
          ? decoded
          : decoded is Map && decoded['exercises'] is List
          ? decoded['exercises'] as List
          : throw const FormatException('Unexpected exercises.json format');

      final exercises = records
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        _exercises = exercises;
        _loading = false;
        _error = null;
      });
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

  String _value(Map<String, dynamic> exercise, String key) {
    final value = exercise[key];

    if (value == null) return '';

    if (value is String || value is num) {
      return value.toString().trim();
    }

    if (value is List) {
      return value.map((item) => item.toString()).join(', ');
    }

    return '';
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;

    return value
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return word;

          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }

  List<Map<String, dynamic>> get _filtered {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) return _exercises;

    return _exercises.where((exercise) {
      final searchable = [
        _value(exercise, 'name'),
        _value(exercise, 'category'),
        _value(exercise, 'body_part'),
        _value(exercise, 'equipment'),
        _value(exercise, 'muscle_group'),
        _value(exercise, 'target'),
      ].join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();
  }

  String _imageUrl(Map<String, dynamic> exercise) {
    final image = _value(exercise, 'image');

    if (image.isEmpty) return '';

    final normalizedPath = image.replaceAll('\\', '/');

    final encodedPath = normalizedPath
        .split('/')
        .map(Uri.encodeComponent)
        .join('/');

    return '$_imageBaseUrl$encodedPath';
  }

  void _selectExercise(Map<String, dynamic> exercise) {
    HapticFeedback.selectionClick();
    widget.onExerciseSelected(exercise);
    Navigator.of(context).maybePop();
  }

  Widget _searchBar() {
    OutlineInputBorder border([Color? color]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: color == null ? BorderSide.none : BorderSide(color: color),
      );
    }

    return TextField(
      controller: _searchCtrl,
      onChanged: (value) => setState(() => _query = value),
      cursorColor: _C.accentSoft,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: _C.text,
        fontSize: 16,
        fontFamily: _C.fontFamily,
      ),
      decoration: InputDecoration(
        hintText: 'Search exercises',
        hintStyle: const TextStyle(
          color: _C.textDim,
          fontSize: 16,
          fontFamily: _C.fontFamily,
        ),
        filled: true,
        fillColor: const Color(0xFF39393B),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: _C.textSec),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
                icon: const Icon(Icons.close_rounded, size: 20),
                color: _C.textSec,
              ),
        border: border(),
        enabledBorder: border(),
        focusedBorder: border(_C.accentSoft),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 14),
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(child: _searchBar()),
              const SizedBox(width: 10),
              SizedBox(
                width: 46,
                height: 46,
                child: Material(
                  color: const Color(0xFF39393B),
                  shape: const CircleBorder(
                    side: BorderSide(color: _C.glassBorder),
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      Icons.close_rounded,
                      color: _C.text,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

  Widget _exerciseImage(Map<String, dynamic> exercise) {
    final imageUrl = _imageUrl(exercise);

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFF353537),
        borderRadius: BorderRadius.circular(17),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const Icon(
              Icons.fitness_center_rounded,
              color: _C.textSec,
              size: 27,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.low,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: _C.textSec,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.fitness_center_rounded,
                  color: _C.textSec,
                  size: 27,
                );
              },
            ),
    );
  }

  Widget _exerciseCard(Map<String, dynamic> exercise, int index, int total) {
    final name = _value(exercise, 'name');
    final bodyPart = _value(exercise, 'body_part');
    final equipment = _value(exercise, 'equipment');
    final category = _value(exercise, 'category');
    final target = _value(exercise, 'target');

    final details = [
      if (bodyPart.isNotEmpty) _titleCase(bodyPart),
      if (target.isNotEmpty) _titleCase(target),
      if (equipment.isNotEmpty) _titleCase(equipment),
      if (bodyPart.isEmpty && target.isEmpty && category.isNotEmpty)
        _titleCase(category),
    ].join(' · ');

    final isFirst = index == 0;
    final isLast = index == total - 1;

    final radius = BorderRadius.only(
      topLeft: Radius.circular(isFirst ? 28 : 13),
      topRight: Radius.circular(isFirst ? 28 : 13),
      bottomLeft: Radius.circular(isLast ? 25 : 13),
      bottomRight: Radius.circular(isLast ? 25 : 13),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 5),
      child: Material(
        color: const Color(0xFF2D2D2F),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _selectExercise(exercise),
          borderRadius: radius,
          child: Container(
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                _exerciseImage(exercise),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name.isEmpty ? 'Unnamed exercise' : _titleCase(name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _C.text,
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          fontFamily: _C.fontFamily,
                        ),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          details,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _C.textSec,
                            fontSize: 11,
                            height: 1.4,
                            fontFamily: _C.fontFamily,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF39393B),
                    borderRadius: BorderRadius.circular(11),
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

  Widget _exerciseList(List<Map<String, dynamic>> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF202022),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _C.glassBorder, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _exerciseCard(items[index], index, items.length);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                        : items.isEmpty
                        ? _message(
                            icon: _query.trim().isEmpty
                                ? Icons.fitness_center_rounded
                                : Icons.search_off_rounded,
                            title: _query.trim().isEmpty
                                ? 'No exercises available'
                                : 'No exercises found',
                          )
                        : _exerciseList(items),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
