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
            TextButton(
              onPressed: () {},
              child: Text(
                'Add Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'inter',
                  color: Colors.black87,
                ),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.white),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 180,
                child: Text(
                  'Whatever you have in mind for today, start right here.',
                  style: TextStyle(fontSize: 14, fontFamily: 'inter'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
