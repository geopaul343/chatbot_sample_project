import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'version_config.dart';

class VersionCheckService {
  // You can replace this with your actual server endpoint
  // For demo purposes, I'm using a simple JSON response
  static const String versionCheckUrl = 'https://api.example.com/version-check';

  // Using configuration from VersionConfig

  static Future<VersionCheckResult> checkVersion() async {
    try {
      // Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      int currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      // For demo purposes, we'll do a local comparison
      // In production, you would call your server to get the latest required version

      // Use VersionConfig to determine if update is required
      bool isUpdateRequired = VersionConfig.isUpdateRequired(
        currentVersion,
        currentBuildNumber,
      );

      return VersionCheckResult(
        currentVersion: currentVersion,
        currentBuildNumber: currentBuildNumber,
        requiredVersion: VersionConfig.minimumRequiredVersion,
        requiredBuildNumber: VersionConfig.minimumRequiredBuildNumber,
        isUpdateRequired: isUpdateRequired,
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
      );
    } catch (e) {
      print('Error checking version: $e');
      // In case of error, don't block the user
      return VersionCheckResult(
        currentVersion: '0.0.0',
        currentBuildNumber: 0,
        requiredVersion: '0.0.0',
        requiredBuildNumber: 0,
        isUpdateRequired: false,
        appName: 'Laennec AI Health Assistant',
        packageName: 'com.laennecai.healthassistant',
      );
    }
  }

  // Alternative method to check against server (uncomment when you have a server)
  /*
  static Future<VersionCheckResult> checkVersionFromServer() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      
      final response = await http.get(
        Uri.parse(versionCheckUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        String requiredVersion = data['minimum_version'] ?? '1.0.0';
        int requiredBuildNumber = data['minimum_build_number'] ?? 1;
        
        List<int> currentVersionParts = packageInfo.version.split('.').map(int.parse).toList();
        List<int> requiredVersionParts = requiredVersion.split('.').map(int.parse).toList();
        
        bool isUpdateRequired = _isVersionLower(
          currentVersionParts, 
          requiredVersionParts,
          int.tryParse(packageInfo.buildNumber) ?? 0,
          requiredBuildNumber
        );

        return VersionCheckResult(
          currentVersion: packageInfo.version,
          currentBuildNumber: int.tryParse(packageInfo.buildNumber) ?? 0,
          requiredVersion: requiredVersion,
          requiredBuildNumber: requiredBuildNumber,
          isUpdateRequired: isUpdateRequired,
          appName: packageInfo.appName,
          packageName: packageInfo.packageName,
        );
      }
    } catch (e) {
      print('Server version check failed: $e');
    }
    
    // Fallback to local check
    return checkVersion();
  }
  */

  static bool _isVersionLower(
    List<int> currentVersion,
    List<int> requiredVersion,
    int currentBuild,
    int requiredBuild,
  ) {
    // Compare major.minor.patch versions
    for (int i = 0; i < 3; i++) {
      int current = i < currentVersion.length ? currentVersion[i] : 0;
      int required = i < requiredVersion.length ? requiredVersion[i] : 0;

      if (current < required) return true;
      if (current > required) return false;
    }

    // If versions are equal, compare build numbers
    return currentBuild < requiredBuild;
  }

  // Method to update the minimum required version (call this when you want to force updates)
  static void updateMinimumVersion(String version, int buildNumber) {
    // In production, you would update this on your server
    // For demo, you would manually update the constants above
    print('Update minimum version to: $version+$buildNumber');
  }
}

class VersionCheckResult {
  final String currentVersion;
  final int currentBuildNumber;
  final String requiredVersion;
  final int requiredBuildNumber;
  final bool isUpdateRequired;
  final String appName;
  final String packageName;

  VersionCheckResult({
    required this.currentVersion,
    required this.currentBuildNumber,
    required this.requiredVersion,
    required this.requiredBuildNumber,
    required this.isUpdateRequired,
    required this.appName,
    required this.packageName,
  });

  @override
  String toString() {
    return 'VersionCheck: Current: $currentVersion+$currentBuildNumber, Required: $requiredVersion+$requiredBuildNumber, Update Required: $isUpdateRequired';
  }
}
