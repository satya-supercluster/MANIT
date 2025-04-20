import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:manit/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final ScrollController scrollController;
  const SettingsScreen({super.key, required this.scrollController});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBiometricEnabled = false;
  ThemeMode _currentThemeMode = ThemeMode.system;
  late final AuthProvider authProvider;
  bool _canCheckBiometrics = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _checkBiometricAvailability();
    });
  }

  Future<void> _checkBiometricAvailability() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = authProvider.canCheckBiometrics;
    } on PlatformException {
      canCheckBiometrics = false;
    }

    if (mounted) {
      setState(() {
        _canCheckBiometrics = canCheckBiometrics;
      });
    }
  }

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _currentThemeMode = mode;
    });
    // In a real app, you would save this preference
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('themeMode', mode.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionCard(
            title: 'Account & Security',
            children: [
              if (_canCheckBiometrics)
                _buildSwitchTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint to login',
                  value: _isBiometricEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isBiometricEnabled = value;
                    });
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
                groupValue: _currentThemeMode,
                onChanged: (value) {
                  _updateThemeMode(value as ThemeMode);
                },
              ),
              _buildRadioTile(
                title: 'Dark Theme',
                leadingIcon: Icons.dark_mode,
                value: ThemeMode.dark,
                groupValue: _currentThemeMode,
                onChanged: (value) {
                  _updateThemeMode(value as ThemeMode);
                },
              ),
              _buildRadioTile(
                title: 'System Default',
                leadingIcon: Icons.settings_system_daydream,
                value: ThemeMode.system,
                groupValue: _currentThemeMode,
                onChanged: (value) {
                  _updateThemeMode(value as ThemeMode);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                subtitle: 'Help us improve the MANIT Academic Portal',
                onTap: () {
                  _showComingSoonSnackbar('Feedback form will be available soon');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Handle logout
              _showLogoutDialog();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
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
      ),
    );
  }

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
        content: const Text('Are you sure you want to log out from MANIT Academic Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Here you would implement actual logout
              // Navigator.of(context).pushReplacementNamed(AppRouter.login);
              _showComingSoonSnackbar('Logout functionality will be implemented');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}