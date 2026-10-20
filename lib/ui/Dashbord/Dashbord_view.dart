import 'package:flutter/material.dart';

class DashbordView extends StatelessWidget {
  static String routeName = '/Dashbord';
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
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
              icon: Icon(
                Icons.add_circle_outline_rounded,
                size: 22,
                color: Colors.black87,
              ),
              label: Text(
                'Add Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'inter',
                  color: Colors.black87,
                ),
              ),
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.white,
                side: BorderSide(color: Colors.white60, width: 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Add your new activity',
                style: TextStyle(fontSize: 14, fontFamily: 'inter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
