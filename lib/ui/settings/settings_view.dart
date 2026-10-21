import 'package:flutter/material.dart';

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
}

const double _kMaxWidth = 340;
const double _kTileHeight = 48;
const double _kTextSize = 18;
const double _kTilePadding = 20;
const double _kIconSize = 24;
const double _kNavBarSpace = 52 + 8 + 24;

enum _DisplayMode { automatic, light, dark }

class _Item {
  final String label;
  final bool external;
  final VoidCallback? onTap;

  const _Item(this.label, {this.external = false, this.onTap});
}

class SettingsView extends StatelessWidget {
  static String routeName = '/settings';

  const SettingsView({super.key});

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
                  const _Item('Notifications'),
                  _Item('Display', onTap: () => _showDisplaySheet(context)),
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

  void _showDisplaySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => const _DisplaySheet(),
    );
  }
}

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

class _DisplaySheet extends StatefulWidget {
  const _DisplaySheet();

  @override
  State<_DisplaySheet> createState() => _DisplaySheetState();
}

class _DisplaySheetState extends State<_DisplaySheet> {
  _DisplayMode _selectedMode = _DisplayMode.automatic;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomInset),
      child: Material(
        color: _C.surface,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 24),
              const Text(
                'Display',
                style: TextStyle(
                  color: _C.text,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: _C.fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose how Life looks on your device.',
                style: TextStyle(
                  color: _C.muted,
                  fontSize: 14,
                  height: 1.5,
                  fontFamily: _C.fontFamily,
                ),
              ),
              const SizedBox(height: 24),
              _DisplayOption(
                title: 'Automatic',
                subtitle: 'Follow system settings',
                icon: Icons.brightness_auto_rounded,
                selected: _selectedMode == _DisplayMode.automatic,
                onTap: () => _selectMode(_DisplayMode.automatic),
              ),
              const SizedBox(height: 8),
              _DisplayOption(
                title: 'Light Mode',
                subtitle: 'Always use light appearance',
                icon: Icons.light_mode_rounded,
                selected: _selectedMode == _DisplayMode.light,
                onTap: () => _selectMode(_DisplayMode.light),
              ),
              const SizedBox(height: 8),
              _DisplayOption(
                title: 'Dark Mode',
                subtitle: 'Always use dark appearance',
                icon: Icons.dark_mode_rounded,
                selected: _selectedMode == _DisplayMode.dark,
                onTap: () => _selectMode(_DisplayMode.dark),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFFFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: _C.fontFamily,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectMode(_DisplayMode mode) {
    setState(() {
      _selectedMode = mode;
    });
  }
}

class _DisplayOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DisplayOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF303031) : const Color(0xFF222223),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: _C.text, size: 23),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _C.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: _C.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _C.muted,
                        fontSize: 12,
                        fontFamily: _C.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 21,
                color: selected ? _C.accent : Colors.white30,
              ),
            ],
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
