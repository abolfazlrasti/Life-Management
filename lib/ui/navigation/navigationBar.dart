import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'addButton.dart';
import '../../Routes/routes.dart';

abstract final class _C {
  static const background = Color(0xFF0B0B0C);
  static const surface = Color(0xFF19191A);
  static const selectedFill = Color(0xFF303031);
  static const border = Color(0xFF29292B);
  static const active = Color(0xFFFFFFFF);
  // Dimmed color for unselected rows so the selected one stands out clearly.
  static const inactive = Color(0xFFA1A1A8);

  // ---- Android 17 style glass ------------------------------------------
  static const glassTop = Color(0x99262628); // translucent surface (top)
  static const glassBottom = Color(0x8019191A); // translucent surface (bottom)
  static const glassBorder = Color(0x1FFFFFFF); // thin light edge
  static const glassSelected = Color(0x26FFFFFF); // white @ ~15%

  // Change the font in ONE place (family name from pubspec.yaml).
  static const fontFamily = 'inter';
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class Navigationbarview extends StatefulWidget {
  static const String routeName = '/navigationbarview';

  const Navigationbarview({super.key});

  @override
  State<Navigationbarview> createState() => _NavigationbarviewState();
}

class _NavigationbarviewState extends State<Navigationbarview>
    with SingleTickerProviderStateMixin {
  // ---- Layout constants -------------------------------------------------
  static const double _barHeight = 52;
  static const double _rowExtent = 48; // 46 row + 2 vertical padding
  static const double _menuVerticalPadding = 10; // 5 top + 5 bottom

  // Distance (px) the finger must travel for a full open/close.
  late final double _dragRange =
      (_allItems.length * _rowExtent + _menuVerticalPadding) - _barHeight;

  // ---- Animation --------------------------------------------------------
  late final AnimationController _controller;

  // Critically damped (ratio 1): no overshoot. The controller clamps to 0..1,
  // so an underdamped spring would hit the end with speed and stop abruptly.
  // Closing is a little softer than opening.
  static final _openSpring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 480,
    ratio: 1,
  );
  static final _closeSpring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 400,
    ratio: 1,
  );

  // ---- iOS-style sheet effect ------------------------------------------
  // 0 = sheet closed, 1 = sheet fully open. Drives the page-behind scale.
  final ValueNotifier<double> _sheetT = ValueNotifier(0);
  // Same curve for the sheet and the page behind it, so they stay in sync.
  static const _sheetCurve = Curves.easeOutCubic;

  bool _isExpanded = false;
  bool _isDragging = false;
  bool _passedHalf = false;

  double _dragStartValue = 0;
  double _dragStartY = 0;

  int _selectedIndex = 0;

  // Pages are built lazily and kept alive (IndexedStack) so switching tabs
  // does not reset scroll position / state.
  final Map<String, Widget> _pages = {};
  final Set<int> _visited = {0};

  final List<_NavItem> _mainItems = const [
    _NavItem(
      label: 'Dashboard',
      icon: Symbols.space_dashboard_rounded,
      route: '/Dashbord',
    ),
    _NavItem(label: 'Daily', icon: Symbols.task_alt_rounded, route: '/Daily'),
    _NavItem(label: 'Finance', icon: Symbols.wallet_rounded, route: '/Money'),
  ];

  late final List<_NavItem> _allItems = [
    ..._mainItems,
    const _NavItem(
      label: 'Calendar',
      icon: Symbols.calendar_month_rounded,
      route: '/Calendar',
    ),
    const _NavItem(
      label: 'Deadline',
      icon: Symbols.hourglass_top_rounded,
      route: '/Deadline',
    ),
    const _NavItem(
      label: 'Gym',
      icon: Symbols.fitness_center_rounded,
      route: '/Gym',
    ),
    const _NavItem(
      label: 'Settings',
      icon: Symbols.settings_rounded,
      route: '/settings',
    ),
    const _NavItem(
      label: 'Style',
      icon: Symbols.checkroom_rounded,
      route: '/Style',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _sheetT.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ---- Open / close with spring ----------------------------------------

  void _settle(bool expand, {double pixelVelocity = 0}) {
    // pixelVelocity: px/s, negative = finger moving up.
    // Convert to controller units per second (positive = opening).
    final velocity = -pixelVelocity / _dragRange;

    if (mounted) {
      setState(() => _isExpanded = expand);
    }

    final simulation = SpringSimulation(
      expand ? _openSpring : _closeSpring,
      _controller.value,
      expand ? 1.0 : 0.0,
      velocity,
      snapToEnd: true,
    );

    _controller.animateWith(simulation);
  }

  void _toggleMenu() {
    HapticFeedback.selectionClick();
    _settle(!_isExpanded);
  }

  void _dismissMenu() {
    if (!_isExpanded && _controller.value == 0) return;
    _settle(false);
  }

  // ---- Drag -------------------------------------------------------------

  void _handleDragStart(DragStartDetails details) {
    _controller.stop();
    _dragStartValue = _controller.value;
    _dragStartY = details.globalPosition.dy;
    _isDragging = true;
    _passedHalf = _controller.value > 0.5;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final distance = _dragStartY - details.globalPosition.dy;
    final raw = _dragStartValue + distance / _dragRange;

    final next = raw.clamp(0.0, 1.0).toDouble();
    _controller.value = next;

    final expanded = next > 0.02;
    if (_isExpanded != expanded) {
      setState(() => _isExpanded = expanded);
    }

    final half = next > 0.5;
    if (half != _passedHalf) {
      _passedHalf = half;
      HapticFeedback.selectionClick();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0;

    final projected = _controller.value + (-velocity / _dragRange) * 0.12;
    final shouldExpand = velocity.abs() > 300 ? velocity < 0 : projected >= 0.5;

    _settle(shouldExpand, pixelVelocity: velocity);
  }

  void _handleDragCancel() {
    if (!_isDragging) return;
    _isDragging = false;
    _settle(_controller.value >= 0.5);
  }

  // ---- Selection --------------------------------------------------------

  void _selectItem(int index) {
    if (index < 0 || index >= _allItems.length) return;

    final item = _allItems[index];

    HapticFeedback.selectionClick();

    if (routes[item.route] == null) return;

    setState(() {
      _selectedIndex = index;
      _visited.add(index);
    });

    if (_isExpanded) {
      // Short pause so the new selection is seen before the menu closes.
      Future.delayed(const Duration(milliseconds: 130), () {
        if (mounted && !_isDragging) _settle(false);
      });
    } else {
      _settle(false);
    }
  }

  Widget _pageFor(String route) {
    final cached = _pages[route];
    if (cached != null) return cached;

    final builder = routes[route];

    if (builder == null) {
      return const Scaffold(
        backgroundColor: _C.background,
        body: SizedBox.expand(),
      );
    }

    final page = Builder(builder: builder);
    _pages[route] = page;

    return page;
  }

  // ---- Add page (iOS-style sheet) --------------------------------------

  Future<void> _openAddPage() async {
    HapticFeedback.lightImpact();
    _dismissMenu();

    final route = PageRouteBuilder<Map<String, String>>(
      opaque: false, // the page behind must stay visible
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, _, __) {
        final top = MediaQuery.paddingOf(context).top;
        return Padding(
          padding: EdgeInsets.only(top: top + 12),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: const AddPage(),
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: _sheetCurve)),
          child: child,
        );
      },
    );

    final future = Navigator.of(context).push(route);

    // Hook the page behind into the route's animation.
    final anim = route.animation!;
    void tick() => _sheetT.value = _sheetCurve.transform(anim.value);
    void status(AnimationStatus s) {
      if (s == AnimationStatus.dismissed) {
        anim.removeListener(tick);
        anim.removeStatusListener(status);
        _sheetT.value = 0;
      }
    }

    anim.addListener(tick);
    anim.addStatusListener(status);

    final result = await future; // the Map returned by AddPage._save
    if (!mounted || result == null) return;
    // TODO: save `result` (type, title, amount, description) here.
  }

  // ---- Build ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0 && !_isExpanded,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (_isExpanded) {
          _dismissMenu();
        } else {
          _selectItem(0);
        }
      },
      child: Scaffold(
        // Black behind the scaled-down page, like iOS.
        backgroundColor: Colors.black,
        body: ValueListenableBuilder<double>(
          valueListenable: _sheetT,
          child: _buildContent(),
          builder: (context, t, child) {
            final topInset = MediaQuery.paddingOf(context).top;
            return Transform.translate(
              offset: Offset(0, topInset * 0.5 * t),
              child: Transform.scale(
                scale: 1 - 0.08 * t,
                alignment: Alignment.topCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36 * t),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      child!,
                      // Page behind gets a little darker.
                      IgnorePointer(
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: 0.35 * t),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ColoredBox(
      color: _C.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                for (int i = 0; i < _allItems.length; i++)
                  _visited.contains(i)
                      ? _pageFor(_allItems[i].route)
                      : const SizedBox.shrink(),
              ],
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value;
                return IgnorePointer(
                  ignoring: t < 0.01,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _dismissMenu,
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.45 * t),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: SafeArea(top: false, child: _buildNavigation()),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragStart: _handleDragStart,
                onVerticalDragUpdate: _handleDragUpdate,
                onVerticalDragEnd: _handleDragEnd,
                onVerticalDragCancel: _handleDragCancel,
                child: _GlassPanel(
                  radius: 30,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final t = _controller.value;

                        // The bar fades out early while opening and only
                        // comes back once the menu is mostly gone, so the two
                        // never overlap. Rows fade/slide with a stagger.
                        final barOpacity = Curves.easeIn.transform(
                          ((0.5 - t) / 0.4).clamp(0.0, 1.0),
                        );

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRect(
                              child: Align(
                                alignment: Alignment.topCenter,
                                heightFactor: t,
                                child: _buildExpandedMenu(t),
                              ),
                            ),
                            ClipRect(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                heightFactor: 1 - t,
                                child: IgnorePointer(
                                  ignoring: t > 0.3,
                                  child: Opacity(
                                    opacity: barOpacity,
                                    child: _buildMainBar(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _CreateButton(onTap: _openAddPage),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBar() {
    final slotCount = _mainItems.length + 1; // 3 tabs + more/split slot
    final indicatorSlot = _selectedIndex.clamp(0, slotCount - 1);

    return SizedBox(
      height: _barHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / slotCount;

          return Stack(
            children: [
              // Sliding active pill, snug against the bar edges.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutQuart,
                left: indicatorSlot * slotWidth,
                top: 0,
                width: slotWidth,
                height: _barHeight,
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _C.glassSelected,
                      borderRadius: BorderRadius.circular(_barHeight),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (int index = 0; index < _mainItems.length; index++)
                    SizedBox(
                      width: slotWidth,
                      height: _barHeight,
                      child: _MainTab(
                        item: _mainItems[index],
                        selected: _selectedIndex == index,
                        onTap: () => _selectItem(index),
                      ),
                    ),
                  SizedBox(
                    width: slotWidth,
                    height: _barHeight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.8,
                            end: 1,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: _selectedIndex >= _mainItems.length
                          ? _SplitButton(
                              key: ValueKey('split_$_selectedIndex'),
                              item: _allItems[_selectedIndex],
                              onSelect: _toggleMenu,
                            )
                          : _MoreButton(
                              key: const ValueKey('more'),
                              expanded: _isExpanded,
                              onTap: _toggleMenu,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExpandedMenu(double t) {
    const rowDelay = 0.035; // stagger between rows
    const rowSpan = 0.45; // how much of `t` one row takes to appear

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int index = 0; index < _allItems.length; index++)
            Builder(
              builder: (context) {
                // Top rows appear first when opening; the bottom rows
                // disappear first when closing (same curve, reversed t).
                final p = Curves.easeOutCubic.transform(
                  ((t - index * rowDelay) / rowSpan).clamp(0.0, 1.0),
                );
                return Opacity(
                  opacity: p,
                  child: Transform.translate(
                    offset: Offset(0, (1 - p) * 10),
                    child: _ListRow(
                      item: _allItems[index],
                      selected: _selectedIndex == index,
                      onTap: () => _selectItem(index),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Android 17 style frosted glass: strong blur + slight saturation boost on
/// whatever is behind, a translucent surface tint, and a thin light edge.
/// Used by the nav bar / expanded menu and the create button so they share
/// exactly the same effect.
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

class _MainTab extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _MainTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: const SizedBox.expand(),
          ),
        ),
        IgnorePointer(
          child: Center(
            child: AnimatedScale(
              scale: selected ? 1.06 : 1,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: Icon(
                item.icon,
                size: 27,
                weight: 700,
                fill: selected ? 1 : 0,
                color: _C.active,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MoreButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _MoreButton({super.key, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: expanded ? 'Close menu' : 'More',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Icon(
                expanded
                    ? Symbols.keyboard_arrow_up_rounded
                    : Symbols.unfold_more_rounded,
                key: ValueKey(expanded),
                color: _C.active,
                size: 25,
                weight: 700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplitButton extends StatelessWidget {
  final _NavItem item;
  final VoidCallback onSelect;

  const _SplitButton({super.key, required this.item, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onSelect,
        child: Center(
          child: Icon(
            item.icon,
            color: _C.active,
            size: 27,
            weight: 700,
            fill: 1,
          ),
        ),
      ),
    );
  }
}

/// A single row of the expanded menu.
/// Same language as the bar: a plain icon (no inner tile), a pill-shaped
/// glass fill for the selected row, bright icon + text when selected and
/// dimmed otherwise.
class _ListRow extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _ListRow({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? _C.active : _C.inactive;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 46,
        decoration: BoxDecoration(
          color: selected ? _C.glassSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(23),
        ),
        // Material + InkWell ABOVE the colored container so the ripple
        // is visible on top of the selected fill.
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(23),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 18, 0),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 24,
                    weight: selected ? 700 : 500,
                    fill: selected ? 1 : 0,
                    color: color,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontFamily: _C.fontFamily,
                        color: color,
                        fontSize: 15.5,
                        height: 1.2,
                        letterSpacing: -0.2,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Create',
      child: Tooltip(
        message: 'Create',
        child: SizedBox(
          width: 52,
          height: 52,
          child: _GlassPanel(
            radius: 26,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: const Center(
                  child: Icon(
                    Symbols.add_rounded,
                    color: _C.active,
                    size: 29,
                    weight: 700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
