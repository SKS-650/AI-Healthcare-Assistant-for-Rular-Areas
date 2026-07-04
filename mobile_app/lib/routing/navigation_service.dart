import 'package:flutter/widgets.dart';

class NavigationService {
  NavigationService._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get currentState => navigatorKey.currentState;
}
