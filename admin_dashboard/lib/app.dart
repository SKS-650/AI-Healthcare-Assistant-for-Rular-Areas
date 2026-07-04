import 'package:flutter/material.dart';

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AI Healthcare Admin Dashboard',
      home: Scaffold(
        body: Center(child: Text('Admin Dashboard')),
      ),
    );
  }
}
