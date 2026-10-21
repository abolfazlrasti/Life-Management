import 'package:flutter/material.dart';

/// 0 = no sheet, 1 = sheet fully open.
/// Navigationbarview listens to this to scale the page behind the sheet.
final ValueNotifier<double> iosSheetProgress = ValueNotifier(0);

const Curve _sheetCurve = Curves.easeOutCubic;

/// Opens [child] as an iOS-style sheet: slides up from the bottom, the page
/// behind scales back with rounded corners.
Future<T?> showIosSheet<T>(
  BuildContext context,
  Widget child, {
  Color? backgroundColor,
}) {
  final route = PageRouteBuilder<T>(
    opaque: false, // the page behind must stay visible
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, _, __) {
      final top = MediaQuery.paddingOf(context).top;
      Widget content = child;
      if (backgroundColor != null) {
        content = ColoredBox(color: backgroundColor, child: content);
      }
      return Padding(
        padding: EdgeInsets.only(top: top + 12),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: content,
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

  final future = Navigator.of(context).push<T>(route);

  // Hook the page behind into the route's animation.
  final anim = route.animation!;
  void tick() => iosSheetProgress.value = _sheetCurve.transform(anim.value);
  void status(AnimationStatus s) {
    if (s == AnimationStatus.dismissed) {
      anim.removeListener(tick);
      anim.removeStatusListener(status);
      iosSheetProgress.value = 0;
    }
  }

  anim.addListener(tick);
  anim.addStatusListener(status);

  return future;
}
