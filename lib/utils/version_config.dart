// Version Configuration
// Update these values to control when users need to update their app

class VersionConfig {
  // **IMPORTANT**: Change these values to force app updates

  // Set this to a higher version than your current app version to test the update flow
  // Current app version: 1.0.7+12
  static const String minimumRequiredVersion =
      '1.0.7'; // Change to '1.0.8' to force updates
  static const int minimumRequiredBuildNumber =
      12; // Change to 13 or higher to force updates

  // Update messaging
  static const String updateTitle = 'Update Required';
  static const String updateMessage =
      'To continue using Laennec AI Health Assistant, please update to the latest version. This update includes important security improvements and new features.';

  // Store URLs (update these with your actual app store URLs)
  static const String androidPackageId =
      'com.laennecai.healthassistant'; // Replace with your actual package ID
  static const String iosAppId =
      '123456789'; // Replace with your actual iOS App Store ID

  // Force update settings
  static const bool allowSkipUpdate =
      false; // Set to true to allow users to skip updates (not recommended)
  static const bool enableVersionCheck =
      true; // Set to false to disable version checking entirely

  // Version check settings
  static const Duration versionCheckTimeout = Duration(seconds: 10);
  static const bool fallbackToLocalCheck =
      true; // Use local version check if server fails

  // **FOR TESTING ONLY**:
  // Temporarily set these to true to test the update screen
  static const bool forceShowUpdateScreen =
      false; // Set to true to always show update screen for testing

  /// Get the version string for display
  static String getVersionString(String version, int buildNumber) {
    return '$version+$buildNumber';
  }

  /// Check if current version is below minimum required
  static bool isUpdateRequired(String currentVersion, int currentBuildNumber) {
    if (forceShowUpdateScreen) return true; // For testing
    if (!enableVersionCheck) return false; // Version check disabled

    try {
      List<int> currentVersionParts =
          currentVersion.split('.').map(int.parse).toList();
      List<int> requiredVersionParts =
          minimumRequiredVersion.split('.').map(int.parse).toList();

      // Compare major.minor.patch versions
      for (int i = 0; i < 3; i++) {
        int current =
            i < currentVersionParts.length ? currentVersionParts[i] : 0;
        int required =
            i < requiredVersionParts.length ? requiredVersionParts[i] : 0;

        if (current < required) return true;
        if (current > required) return false;
      }

      // If versions are equal, compare build numbers
      return currentBuildNumber < minimumRequiredBuildNumber;
    } catch (e) {
      print('Error comparing versions: $e');
      return false; // Don't force update if there's an error
    }
  }
}

/// Instructions for using this configuration:
/// 
/// 1. **To test the update screen**: 
///    - Set `forceShowUpdateScreen = true`
///    - Run the app and you'll always see the update screen
/// 
/// 2. **To force real updates**:
///    - Increase `minimumRequiredVersion` (e.g., from '1.0.7' to '1.0.8')
///    - OR increase `minimumRequiredBuildNumber` (e.g., from 12 to 13)
///    - Users with older versions will be forced to update
/// 
/// 3. **To disable version checking**:
///    - Set `enableVersionCheck = false`
/// 
/// 4. **For production deployment**:
///    - Update `androidPackageId` with your actual package ID
///    - Update `iosAppId` with your actual App Store ID
///    - Set `forceShowUpdateScreen = false`
///    - Set `enableVersionCheck = true`
///    - Set appropriate minimum version requirements 