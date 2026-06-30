import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'provider_chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _threads = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.instance.getMessageThreads();
      if (!mounted) return;
      setState(() {
        _threads = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load messages. Make sure the backend is running.';
        _loading = false;
      });
    }
  }

  String _relativeTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('Messages', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          TextButton(onPressed: _loadThreads, child: const Text('Retry')),
                        ],
                      ),
                    )
                  : _threads.isEmpty
                      ? const Center(
                          child: Text(
                            'No conversations yet.\nMessage a provider to get started.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadThreads,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _threads.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                            itemBuilder: (context, i) {
                              final t = _threads[i];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.accentBlueLight,
                                  child: const Icon(Icons.person_outline, color: AppColors.accentBlue),
                                ),
                                title: Text(t['provider_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  (t['last_message'] as String?) ?? 'No messages yet',
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                                trailing: Text(
                                  _relativeTime(t['last_message_at'] as String?),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProviderChatScreen(
                                        providerId: t['provider_id'] as String,
                                        providerName: t['provider_name'] as String,
                                      ),
                                    ),
                                  );
                                  _loadThreads();
                                },
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}