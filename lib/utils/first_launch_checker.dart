import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchChecker {
  static const String _privacyPolicyKey = 'privacy_policy_accepted';
  static const String _firstLaunchKey = 'first_launch_completed';

  /// Check if user has accepted privacy policy
  static Future<bool> hasAcceptedPrivacyPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyPolicyKey) ?? false;
  }

  /// Check if this is the first app launch
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_firstLaunchKey) ?? false);
  }

  /// Mark privacy policy as accepted
  static Future<void> markPrivacyPolicyAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyPolicyKey, true);
  }

  /// Mark first launch as completed
  static Future<void> markFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
  }

  /// Reset all preferences (for testing purposes)
  static Future<void> resetPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_privacyPolicyKey);
    await prefs.remove(_firstLaunchKey);
  }
}
