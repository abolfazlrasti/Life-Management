import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'account/profile_view.dart';
import 'Subscription/sub_view.dart';

import '../../Routes/ios_sheet.dart';

abstract final class _C {
  static const background = Color(0xFF0B0B0C);
  static const surface = Color(0xFF19191A);
  static const text = Color(0xFFF1F1F1);
  static const muted = Color(0xFF858589);
  static const danger = Color(0xFFFC6358);
  static const accent = Color(0xFFFFFFFF);
  static const fontFamily = 'inter';

  // ---- Android 17 style glass (same values as the nav bar) -------------
  static const glassTop = Color(0x99262628);
  static const glassBottom = Color(0x8019191A);
  static const glassBorder = Color(0x1FFFFFFF);
  static const glassSelected = Color(0x26FFFFFF);
}

const double _kMaxWidth = 340;
const double _kTileHeight = 48;
const double _kTextSize = 18;
const double _kTilePadding = 20;
const double _kIconSize = 24;
const double _kNavBarSpace = 52 + 8 + 24;

enum _DisplayMode {
  automatic('Automatic', Icons.brightness_auto_rounded),
  light('Light', Icons.light_mode_rounded),
  dark('Dark', Icons.dark_mode_rounded);

  final String label;
  final IconData icon;
  const _DisplayMode(this.label, this.icon);
}

enum _Lang {
  english('English'),
  persian('فارسی');

  final String label;
  const _Lang(this.label);
}

class _Item {
  final String label;
  final String? value; // small muted text before the chevron
  final bool external;
  final VoidCallback? onTap;

  const _Item(this.label, {this.value, this.external = false, this.onTap});
}

class SettingsView extends StatefulWidget {
  static String routeName = '/settings';

  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  _Lang _language = _Lang.english;
  _DisplayMode _displayMode = _DisplayMode.automatic;

  Future<void> _pickLanguage() async {
    final result = await _showGlassSheet<_Lang>(
      context,
      _ChoiceSheet<_Lang>(
        title: 'Language',
        selected: _language,
        options: [
          for (final l in _Lang.values) _Option(value: l, label: l.label),
        ],
      ),
    );
    if (result != null && mounted) setState(() => _language = result);
  }

  Future<void> _pickDisplay() async {
    final result = await _showGlassSheet<_DisplayMode>(
      context,
      _ChoiceSheet<_DisplayMode>(
        title: 'Display',
        selected: _displayMode,
        options: [
          for (final m in _DisplayMode.values)
            _Option(value: m, label: m.label, icon: m.icon),
        ],
      ),
    );
    if (result != null && mounted) setState(() => _displayMode = result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: _C.fontFamily,
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxWidth + 36),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              18 + _kNavBarSpace + bottomInset,
            ),
            children: [
              _Group(
                items: [
                  _Item(
                    'Account',
                    onTap: () => showIosSheet(context, const ProfileView()),
                  ),
                  _Item(
                    'Subscription',
                    onTap: () => showIosSheet(context, const SubView()),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _Group(
                items: [
                  _Item(
                    'Language',
                    value: _language.label,
                    onTap: _pickLanguage,
                  ),
                  _Item(
                    'Display',
                    value: _displayMode.label,
                    onTap: _pickDisplay,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _Group(
                items: [
                  _Item('Rate Life', external: true),
                  _Item('Send feedback', external: true),
                  _Item('Support', external: true),
                  _Item('Privacy', external: true),
                  _Item('Open source licenses', external: true),
                ],
              ),
              const SizedBox(height: 20),
              _LogoutTile(onTap: () {}),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Life for Android 0.0.1 (1)',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontFamily: _C.fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glass sheet (Android 17 style blur)
// ---------------------------------------------------------------------------

Future<T?> _showGlassSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    // Light barrier so the blur has something to show.
    barrierColor: Colors.black45,
    builder: (_) => child,
  );
}

class _GlassPanel extends StatelessWidget {
  final double radius;
  final Widget child;

  const _GlassPanel({required this.radius, required this.child});

  // Saturation ~1.6 so colors behind the glass stay lively.
  static const List<double> _saturate = [
    1.47244, -0.42912, -0.04332, 0, 0, //
    -0.12756, 1.17088, -0.04332, 0, 0, //
    -0.12756, -0.42912, 1.55668, 0, 0, //
    0, 0, 0, 1, 0,
  ];

  static final ImageFilter _filter = ImageFilter.compose(
    outer: const ColorFilter.matrix(_saturate),
    inner: ImageFilter.blur(sigmaX: 28, sigmaY: 28, tileMode: TileMode.mirror),
  );

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: _filter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: br,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_C.glassTop, _C.glassBottom],
            ),
            border: Border.all(color: _C.glassBorder, width: 0.8),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Option<T> {
  final T value;
  final String label;
  final IconData? icon;

  const _Option({required this.value, required this.label, this.icon});
}

/// One simple sheet used for both Language and Display:
/// a title and a few rows. Tapping a row selects it and closes the sheet
/// (no radio buttons, no extra "Close" button).
class _ChoiceSheet<T> extends StatefulWidget {
  final String title;
  final List<_Option<T>> options;
  final T selected;

  const _ChoiceSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  @override
  State<_ChoiceSheet<T>> createState() => _ChoiceSheetState<T>();
}

class _ChoiceSheetState<T> extends State<_ChoiceSheet<T>> {
  late T _current = widget.selected;
  bool _closing = false;

  Future<void> _choose(T value) async {
    if (_closing) return;
    _closing = true;
    HapticFeedback.selectionClick();
    setState(() => _current = value);
    // Short pause so the person sees the selection before it closes.
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (mounted) Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomInset),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _GlassPanel(
            radius: 30,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: _C.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: _C.fontFamily,
                      ),
                    ),
                  ),
                  for (final o in widget.options)
                    _OptionRow(
                      label: o.label,
                      icon: o.icon,
                      selected: _current == o.value,
                      onTap: () => _choose(o.value),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionRow({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: 54,
        decoration: BoxDecoration(
          color: selected ? _C.glassSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 22,
                      color: selected ? _C.accent : _C.muted,
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? _C.accent : _C.text,
                        fontSize: 17,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontFamily: _C.fontFamily,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: selected ? 1 : 0,
                    child: const Icon(
                      Icons.check_rounded,
                      size: 22,
                      color: _C.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings list
// ---------------------------------------------------------------------------

class _Group extends StatelessWidget {
  final List<_Item> items;

  const _Group({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 2),
          _Tile(item: items[i], first: i == 0, last: i == items.length - 1),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final _Item item;
  final bool first;
  final bool last;

  const _Tile({required this.item, required this.first, required this.last});

  @override
  Widget build(BuildContext context) {
    const big = Radius.circular(20);
    const small = Radius.circular(4);

    return SizedBox(
      height: _kTileHeight,
      child: Material(
        color: _C.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: first ? big : small,
            bottom: last ? big : small,
          ),
        ),
        child: InkWell(
          onTap: item.onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kTilePadding),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _C.text,
                      fontSize: _kTextSize,
                      fontFamily: _C.fontFamily,
                    ),
                  ),
                ),
                if (item.value != null) ...[
                  Text(
                    item.value!,
                    maxLines: 1,
                    style: const TextStyle(
                      color: _C.muted,
                      fontSize: 15,
                      fontFamily: _C.fontFamily,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(
                  item.external
                      ? Icons.north_east_rounded
                      : Icons.chevron_right_rounded,
                  size: _kIconSize,
                  color: Colors.white30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kTileHeight,
      child: Material(
        color: _C.surface,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: _kIconSize, color: _C.danger),
              SizedBox(width: 8),
              Text(
                'Log out',
                style: TextStyle(
                  color: _C.danger,
                  fontSize: _kTextSize,
                  fontFamily: _C.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
