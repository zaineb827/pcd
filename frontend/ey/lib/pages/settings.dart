import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ey/appcolor.dart';
import 'package:ey/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    Color appcolor = AppColors.getBackground(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: appcolor,
        title: const Text('App Settings', textAlign: TextAlign.center),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.gettextcolor(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppColors.getBackgroundImage(context)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListView(
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                secondary: const Icon(Icons.notifications),
              ),
              SwitchListTile(
                title: const Text("Dark Mode"),
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Privacy Settings'),
                subtitle: const Text('Manage permissions & security'),
                onTap: () {
                  // Could open a subpage or settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                subtitle: const Text('Version 1.0.0'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'PCD',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_applications),
                title: const Text('Open App System Settings'),
                onTap: _openAppSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }
}
