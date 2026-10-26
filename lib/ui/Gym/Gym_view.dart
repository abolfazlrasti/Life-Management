
import 'package:flutter/material.dart';

import '../../Routes/ios_sheet.dart';
import 'page_view.dart';

class GymView extends StatelessWidget {
  static String routeName = '/Gym';

  const GymView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gym',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'inter',
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                size: 22,
                color: Colors.black87,
              ),
              label: const Text(
                'Add Program',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'inter',
                  color: Colors.black87,
                ),
              ),
              onPressed: () => showIosSheet(
                context,
                GymPageView(
                  onExerciseSelected: (exercise) {},
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.white,
                side: const BorderSide(
                  color: Colors.white60,
                  width: 7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Add your new activity',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
