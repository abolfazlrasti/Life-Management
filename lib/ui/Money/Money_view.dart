import 'package:flutter/material.dart';

class Moneyview extends StatelessWidget {
  static String routeName = '/Money';
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wallet',
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
