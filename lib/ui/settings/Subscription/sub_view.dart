import 'dart:ui';

import 'package:flutter/material.dart';

abstract final class _C {
  // Android 17 style glass (same values as the nav bar and settings sheets)
  static const glassTop = Color(0x99262628);
  static const glassBottom = Color(0x8019191A);
}

class SubView extends StatefulWidget {
  const SubView({super.key});

  @override
  State<SubView> createState() => _SubViewState();
}

class _SubViewState extends State<SubView> {
  // Strong blur + slight saturation boost on whatever is behind the page.
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
    return Scaffold(
      // No solid color: the glass layer below is the background.
      backgroundColor: Colors.transparent,
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
          // Page content goes here.
          const SafeArea(child: SizedBox.expand()),
        ],
      ),
    );
  }
}
