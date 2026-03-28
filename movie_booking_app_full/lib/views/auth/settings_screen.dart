import 'package:flutter/material.dart';

/// SettingsScreen - Màn hình cài đặt
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Chế độ tối'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Implement theme toggle
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Ngôn ngữ'),
            trailing: const Text('Tiếng Việt'),
            onTap: () {
              // TODO: Implement language selection
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Thông báo'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification settings
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Phiên bản'),
            trailing: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
