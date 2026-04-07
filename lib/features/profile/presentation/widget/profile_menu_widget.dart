import 'package:flutter/material.dart';

class ProfileMenuWidget extends StatelessWidget {
  final List<ProfileMenuItem> items;

  const ProfileMenuWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(e.value.icon, color: Colors.blueAccent),
                title: Text(e.value.label),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${e.value.label}（功能開發中）')),
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String label;

  const ProfileMenuItem({required this.icon, required this.label});
}

const accountMenuItems = [
  ProfileMenuItem(icon: Icons.credit_card, label: '付款方式'),
  ProfileMenuItem(icon: Icons.notifications_outlined, label: '通知設定'),
  ProfileMenuItem(icon: Icons.favorite_border, label: '常用路線'),
];

const generalMenuItems = [
  ProfileMenuItem(icon: Icons.help_outline, label: '幫助中心'),
  ProfileMenuItem(icon: Icons.security, label: '隱私政策'),
  ProfileMenuItem(icon: Icons.settings_outlined, label: '設定'),
];
