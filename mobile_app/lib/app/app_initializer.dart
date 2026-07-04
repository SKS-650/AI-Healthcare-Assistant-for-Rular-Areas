import '../bootstrap/dependency_injection.dart';
import '../bootstrap/firebase_initializer.dart';
import '../bootstrap/hive_initializer.dart';

class AppInitializer {
  const AppInitializer._();

  static Future<void> initialize() async {
    await FirebaseInitializer.initialize();
    await HiveInitializer.initialize();
    DependencyInjection.register();
  }
}
