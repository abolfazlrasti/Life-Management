import 'package:flutter/material.dart';

class GymView extends StatelessWidget {
  static String routeName = '/Gym';
  const GymView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gym',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'inter',
          ),
        )),
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
