import 'package:flutter/material.dart';

class StyleView extends StatelessWidget {
  static String routeName = '/Style';
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Style',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'inter',
          ),
        ),
      ),
      body: Center(child: Text('Coming soon', style: TextStyle(fontSize: 24))),
    );
  }
}
