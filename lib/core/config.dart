
class ZippeddonConfig {
  static const String appName = 'ZIPPEDDON';
  static const String creator = 'Anonymous_beta';
  static const String version = '2.0.0';

  static const int maxSampleBytes = 8 * 1024 * 1024;
  static const int maxEntries = 100;
  static const int maxNestingDepth = 3;
  static const int maxBenchmarkBytes = 4 * 1024 * 1024;

  static const int maxExtractedBytes = 32 * 1024 * 1024;
  static const int maxExtractedEntries = 500;

  static const Duration operationTimeout = Duration(minutes: 2);
}

// Backwards-compatible name used by older screens.
class AppConfig {
  static const String appName = ZippeddonConfig.appName;
  static const String creator = ZippeddonConfig.creator;
  static const String version = ZippeddonConfig.version;
}
