/// Everything global is built once, at startup, in one place.
/// Nothing else creates repositories or use cases.
class AppDependencies {
  // Set once in main() before runApp. Tests can replace it.
  static late AppDependencies instance;

  AppDependencies._();

  static Future<void> init() async {
    // 1. Data layer (the only place that knows the real implementations).
    // 2. Domain layer (use cases).
    instance = AppDependencies._();
  }
}
