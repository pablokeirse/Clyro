import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Matches the wireframe's pill-shaped bottom nav: Home, AI, Search, Chat, Profile.
class ClyroBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ClyroBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppColors.border, width: 1.6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                label: 'AI',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.search,
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline,
                selected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                isProfile: true,
                selected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final bool isProfile;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    this.icon,
    this.label,
    this.isProfile = false,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        isProfile ? AppColors.primaryPurple : AppColors.accentBlue;
    final Color color = selected ? activeColor : AppColors.navInactive;

    Widget child;
    if (isProfile) {
      child = CircleAvatar(
        radius: 16,
        backgroundColor: selected
            ? AppColors.primaryPurpleLight
            : AppColors.primaryPurpleLight.withOpacity(0.6),
        child: Icon(Icons.person_outline, size: 18, color: AppColors.primaryPurple),
      );
    } else if (label != null) {
      child = Text(
        label!,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color,
        ),
      );
    } else {
      child = Icon(icon, color: color);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(height: 64, width: 50, child: Center(child: child)),
    );
  }
}
