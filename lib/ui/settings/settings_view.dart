import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  static String routeName = '/settings';
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'inter',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: Text('Account'),
                onTap: () {
                  // Handle account settings tap
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('Notifications'),
                onTap: () {
                  // Handle account settings tap
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('Display'),
                onTap: () {
                  // Handle account settings tap
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('Rate Lift'),
                onTap: () {
                  // Handle account settings tap
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('Send feedback'),
                onTap: () {
                  // Handle account settings tap
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('Support'),
                onTap: () {
                  // Handle account settings tap
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('Privacy'),
                onTap: () {
                  // Handle account settings tap
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('Open source licenses'),
                onTap: () {
                  // Handle account settings tap
                },
              ),
            ),
            const SizedBox(height: 70),
            Center(child: Text('Life for Android 0.0.1 (1)')),
          ],
        ),
      ),
    );
  }
}
