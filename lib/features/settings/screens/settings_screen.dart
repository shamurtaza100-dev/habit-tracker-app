import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: const [
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark mode',
                  subtitle: 'Follows the device theme',
                ),
                Divider(height: 1),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Reminder scheduling foundation is ready',
                ),
                Divider(height: 1),
                _SettingsTile(
                  icon: Icons.file_download_outlined,
                  title: 'Export data',
                  subtitle: 'Planned for a future backup release',
                ),
                Divider(height: 1),
                _SettingsTile(
                  icon: Icons.cloud_sync_outlined,
                  title: 'Cloud sync',
                  subtitle: 'Prepared for Firebase or Supabase',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
