
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laennec_ai_assistant/screens/privacy_policy_screen.dart';
import 'package:laennec_ai_assistant/screens/terms_condition_screen.dart';



class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(),

            _buildDrawerItem(
              context,
              icon: Icons.article_outlined,
              title: 'Terms and Conditions',
              onTap:
                  () =>
                      _navigateToScreen(context, const TermsConditionScreen()),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap:
                  () => _navigateToScreen(context, const PrivacyPolicyScreen()),
            ),
            const Divider(thickness: 1, indent: 16, endIndent: 16),
            _buildDrawerItem(
              context,
              icon: Icons.info_outline,
              title: 'About',
              onTap: () => _showAboutDialog(context),
            ),
            // _buildDrawerItem(
            //   context,
            //   icon: Icons.logout_outlined,
            //   title: 'Logout',
            //   onTap: () => _showLogoutDialog(context),
            //   isDestructive: true,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),

            // Icon(Icons.health_and_safety, size: 48, color: Colors.white),
            Image.asset('assets/laennec_logo.png', width: 50, height: 50),

            SizedBox(height: 16),
            Text(
              'Laennec AI Assistant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Your AI-powered companion',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red.shade600 : Colors.indigo.shade700,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red.shade600 : Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: isDestructive ? Colors.red.shade50 : Colors.indigo.shade50,
        splashColor:
            isDestructive ? Colors.red.shade100 : Colors.indigo.shade100,
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer first
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _showAboutDialog(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                const Text('About Laennec AI'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laennec AI Health Assistant',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('Version 1.0.0'),
                SizedBox(height: 16),
                Text(
                  'An AI-powered health companion designed to provide educational information and support for managing your health.',
                ),
                SizedBox(height: 16),
                Text(
                  'For support, contact: jase@laennec.ai',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(color: Colors.indigo.shade700),
                ),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout_outlined, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text('Logout'),
              ],
            ),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
