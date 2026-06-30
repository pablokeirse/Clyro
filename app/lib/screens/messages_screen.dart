import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'provider_chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = [
      ('Plumber 1', 'Sure, Thursday works for me', '2m'),
      ('Electrician 1', 'I can come by tomorrow morning', '1h'),
      ('Cleaner 1', 'Thanks for booking!', 'Yesterday'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('Messages', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: threads.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, i) {
              final t = threads[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.accentBlueLight,
                  child: const Icon(Icons.person_outline, color: AppColors.accentBlue),
                ),
                title: Text(t.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(t.$2, style: const TextStyle(color: AppColors.textSecondary)),
                trailing: Text(t.$3, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProviderChatScreen(providerName: t.$1)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
