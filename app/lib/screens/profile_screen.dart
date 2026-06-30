import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'account_details_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.person_outline, 'Account details'),
      (Icons.location_on_outlined, 'Saved addresses'),
      (Icons.notifications_outlined, 'Notifications'),
      (Icons.lock_outline, 'Privacy & security'),
      (Icons.help_outline, 'Help & support'),
    ];

    return Column(
      children: [
        const SizedBox(height: 24),
        const CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primaryPurpleLight,
          child: Icon(Icons.person_outline, size: 44, color: AppColors.primaryPurple),
        ),
        const SizedBox(height: 12),
        const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, i) {
              final it = items[i];
              return ListTile(
                leading: Icon(it.$1, color: AppColors.accentBlue),
                title: Text(it.$2),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  if (i == 0) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AccountDetailsScreen()),
                    );
                  }
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: AppColors.border, width: 1.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const ClyroApp()),
                (route) => false,
              );
            },
            child: const Text('Log out', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}