import 'package:flutter/material.dart';

class DailyView extends StatelessWidget {
  static String routeName = '/Daily';
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'inter',
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to Page',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'inter',
          ),
        ),
      ),
    );
  }
}
