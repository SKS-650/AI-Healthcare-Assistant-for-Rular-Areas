enum Environment { development, production }

class AppEnvironment {
  const AppEnvironment._();

  static const current = Environment.development;
}
