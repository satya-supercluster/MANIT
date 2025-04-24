import 'package:flutter/material.dart';
import 'package:manit/presentation/providers/auth_provider.dart';
import 'package:manit/presentation/providers/theme_provider.dart'; // Add this import
import 'package:manit/presentation/screens/login_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final ScrollController scrollController;
  const SettingsScreen({super.key, required this.scrollController});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Consumer<ThemeProvider>(  // Add ThemeProvider consumer
            builder: (context, themeProvider, _) {
              return ListView(
                controller: widget.scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionCard(
                    title: 'Account & Security',
                    children: [
                      if (authProvider.canCheckBiometrics)
                        _buildSwitchTile(
                          icon: Icons.fingerprint,
                          title: 'Biometric Login',
                          subtitle: 'Use fingerprint or face recognition to login',
                          value: authProvider.isBiometricEnabled,
                          onChanged: (value) {
                            authProvider.setBiometricEnabled(value);
                          },
                        ),
                      const Divider(),
                      _buildActionTile(
                        icon: Icons.password,
                        title: 'Change Password',
                        onTap: () {
                          _showComingSoonSnackbar('Password change will be available soon');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Appearance',
                    children: [
                      _buildRadioTile(
                        title: 'Light Theme',
                        leadingIcon: Icons.light_mode,
                        value: ThemeMode.light,
                        groupValue: themeProvider.themeMode,  // Use theme from provider
                        onChanged: (value) {
                          themeProvider.setThemeMode(value as ThemeMode);  // Update theme via provider
                        },
                      ),
                      _buildRadioTile(
                        title: 'Dark Theme',
                        leadingIcon: Icons.dark_mode,
                        value: ThemeMode.dark,
                        groupValue: themeProvider.themeMode,  // Use theme from provider
                        onChanged: (value) {
                          themeProvider.setThemeMode(value as ThemeMode);  // Update theme via provider
                        },
                      ),
                      _buildRadioTile(
                        title: 'System Default',
                        leadingIcon: Icons.settings_system_daydream,
                        value: ThemeMode.system,
                        groupValue: themeProvider.themeMode,  // Use theme from provider
                        onChanged: (value) {
                          themeProvider.setThemeMode(value as ThemeMode);  // Update theme via provider
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle logout
                      _showLogoutDialog();
                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = 0.0;
                              const end = 1.0;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var fadeAnimation = animation.drive(tween);
                              return FadeTransition(opacity: fadeAnimation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 600),
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'Support',
                    children: [
                      _buildActionTile(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        subtitle: 'Get answers to frequently asked questions',
                        onTap: () {
                          _showComingSoonSnackbar('Help center will be available soon');
                        },
                      ),
                      const Divider(),
                      _buildActionTile(
                        icon: Icons.headset_mic,
                        title: 'Contact Support',
                        subtitle: 'Reach out to our support team',
                        onTap: () {
                          _showComingSoonSnackbar('Support contact will be available soon');
                        },
                      ),
                      const Divider(),
                      _buildActionTile(
                        icon: Icons.message_outlined,
                        title: 'Suggestions & Feedback',
                        subtitle: 'Help us improve the Academic Portal',
                        onTap: () {
                          _showComingSoonSnackbar('Feedback form will be available soon');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'MANIT Academic Portal v1.0.0',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // The rest of the methods remain unchanged
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildRadioTile({
    required String title,
    required IconData leadingIcon,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        leadingIcon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      trailing: Radio<ThemeMode>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showComingSoonSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out from Academic Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout(context);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}