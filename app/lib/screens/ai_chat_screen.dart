import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ChatBubbleData {
  final String text;
  final bool isUser;
  ChatBubbleData(this.text, this.isUser);
}

class AiChatScreen extends StatefulWidget {
  final String userName;
  const AiChatScreen({super.key, required this.userName});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final List<ChatBubbleData> _messages = [];
  final _scrollController = ScrollController();
  bool _sending = false;

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatBubbleData(text, true));
      _controller.clear();
      _sending = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    try {
      final reply = await ApiService.instance.sendChatMessage(text);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatBubbleData(reply, false));
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatBubbleData(
          "CLYROAI couldn't respond right now. Make sure the backend is running and your Gemini API key is set.",
          false,
        ));
        _sending = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMessages = _messages.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${widget.userName}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: hasMessages
              ? ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length + (_sending ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i >= _messages.length) {
                      return const _TypingBubble();
                    }
                    final m = _messages[i];
                    return _Bubble(text: m.text, isUser: m.isUser);
                  },
                )
              : Center(
                  child: Icon(Icons.auto_awesome, size: 56, color: AppColors.accentBlue.withOpacity(0.25)),
                ),
        ),
        
        // Wrapped the input actions container inside a SafeArea to handle system overlays
        SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Ask CLYROAI...',
                          prefixIcon: Icon(Icons.add_circle_outline, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.accentBlue,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'CLYROAI can make mistakes, always double check the responses.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _Bubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.textPrimary : AppColors.accentBlueLight,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accentBlueLight,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const SizedBox(
          width: 18,
          height: 12,
          child: Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentBlue),
            ),
          ),
        ),
      ),
    );
  }
}