import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'ai_chat_screen.dart';
import 'search_services_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

/// Top-level shell: owns the bottom nav and swaps between the five
/// sections shown in the wireframes (Home, AI, Search, Chat, Profile).
class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTabPage(userName: widget.userName),
      const AiChatScreen(userName: 'User'),
      const SearchServicesScreen(),
      const MessagesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.accentBlueLight],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: IndexedStack(index: _navIndex, children: pages),
        ),
      ),
      bottomNavigationBar: ClyroBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _HomeTabPage extends StatefulWidget {
  final String userName;
  const _HomeTabPage({required this.userName});

  @override
  State<_HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<_HomeTabPage> {
  int _tabIndex = 0;
  final _tabs = const ['My services', 'Work with CLYRO', 'About us', 'Learn how CLYRO works'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text(
            'Welcome, ${widget.userName} to CLYRO!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border, width: 1.4)),
          ),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final selected = i == _tabIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tabIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: selected ? AppColors.accentBlue : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      _tabs[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                        color: selected ? AppColors.accentBlue : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _tabIndex,
            children: const [
              _MyServicesTab(),
              _WorkWithClyroTab(),
              _AboutUsTab(),
              _LearnHowClyroWorksTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _MyServicesTab extends StatelessWidget {
  const _MyServicesTab();

  @override
  Widget build(BuildContext context) {
    final services = [
      ('Plumbing repair', 'Completed · 2 weeks ago'),
      ('Electrician visit', 'In progress'),
      ('House cleaning', 'Scheduled · Friday 10:00'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        const Text(
          'Your recent requests',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...services.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1.4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlueLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.build_outlined, color: AppColors.accentBlue),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(s.$2, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            )),
      ],
    );
  }
}

class _WorkWithClyroTab extends StatelessWidget {
  const _WorkWithClyroTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.handshake_outlined, size: 48, color: AppColors.accentBlue),
            const SizedBox(height: 16),
            const Text(
              'Become a CLYRO provider',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'List your services, get matched with nearby customers, and manage bookings all in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Apply now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutUsTab extends StatelessWidget {
  const _AboutUsTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(28),
      child: Text(
        'CLYRO connects people who need help around the house with trusted, '
        'nearby service providers — plumbers, electricians, cleaners, and more. '
        'Our AI assistant helps you describe your problem and find the right pro fast.',
        style: TextStyle(color: AppColors.textSecondary, height: 1.5),
      ),
    );
  }
}

class _LearnHowClyroWorksTab extends StatelessWidget {
  const _LearnHowClyroWorksTab();

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('1', 'Tell CLYROAI what you need OR upload a picture of your issue'),
      ('2', 'Get matched with nearby providers and choose one to your liking.'),
      ('3', 'Chat, book, and get it done'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: steps
          .map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.accentBlue,
                      child: Text(s.$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(s.$2, style: const TextStyle(fontSize: 15))),
                  ],
                ),
              ))
          .toList(),
    );
  }
}