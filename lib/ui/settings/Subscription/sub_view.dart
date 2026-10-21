import 'package:flutter/material.dart';

class SubView extends StatefulWidget {
  const new({super.key});

  @override
  State<SubView> createState() => _SubViewState();
}

class _SubViewState extends State<SubView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.blue);
  }
}
