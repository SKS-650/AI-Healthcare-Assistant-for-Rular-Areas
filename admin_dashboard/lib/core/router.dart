import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Unknown route')),
        body: Center(child: Text('No route for ${settings.name}')),
      ),
    );
  }
}

