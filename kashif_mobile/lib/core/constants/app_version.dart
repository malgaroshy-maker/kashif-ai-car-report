/// Single Source of Truth for App Version, Serial, and Build Identifier.
/// Updated with each release and build.
class AppVersion {
  /// Semantic version (Major.Minor.Patch)
  static const String version = '1.2.5';

  /// Incremental build number (matches pubspec.yaml versionCode)
  static const int buildNumber = 8;

  /// Build Release Date
  static const String buildDate = '2026-10-29';

  /// Hardware Optimization Target
  static const String buildDeviceTarget = 'Poco X7 Pro (ARM64-v8a)';

  /// Short badge displayed in AppBar, e.g. "v1.2.5 #8"
  static const String badge = 'v$version #$buildNumber';

  /// Standard display format, e.g. "الإصدار 1.2.5 (بناء #8)"
  static const String display = 'الإصدار $version (بناء #$buildNumber)';

  /// Unique serial number / build fingerprint for verification
  static const String serial = 'KASHIF-V$version-B$buildNumber-20261029';
}
