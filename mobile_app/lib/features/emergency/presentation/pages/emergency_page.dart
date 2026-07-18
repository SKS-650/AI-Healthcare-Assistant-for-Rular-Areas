/// emergency_page.dart
///
/// Legacy entry point kept for backward compatibility.
/// Immediately redirects to EmergencyHomePage so any stale
/// Navigator.pushNamed(RouteNames.emergency) calls still work.
///
/// The router (app_router.dart) already points /emergency directly
/// to EmergencyHomePage, so this file is only reached by any
/// remaining direct widget references inside the codebase.
library;

export 'emergency_home_page.dart';
