import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Frosted-glass pill nav: Home, AI, Search, Chat, Profile.
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
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
    final Color color = selected ? activeColor : AppColors.navInactive.withOpacity(0.65);

    Widget child;
    if (isProfile) {
      child = CircleAvatar(
        radius: 16,
        backgroundColor: selected
            ? AppColors.primaryPurpleLight
            : AppColors.primaryPurpleLight.withOpacity(0.5),
        child: Icon(Icons.person_outline, size: 18, color: AppColors.primaryPurple),
      );
    } else if (label != null) {
      child = AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color,
        ),
        child: Text(label!),
      );
    } else {
      child = AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: Icon(icon, color: color, key: ValueKey(selected)),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        width: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(child: child),
            if (selected && !isProfile)
              Positioned(
                bottom: 12,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}