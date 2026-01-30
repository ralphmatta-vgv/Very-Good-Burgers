import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/theme.dart';

enum NavTab { home, order, rewards, profile }

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray300.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == NavTab.home.index,
                onTap: () => onTap(NavTab.home.index),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: 'Order',
                isSelected: currentIndex == NavTab.order.index,
                onTap: () => onTap(NavTab.order.index),
                badge: cartCount > 0 ? cartCount : null,
              ),
              _NavItem(
                icon: Icons.star_rounded,
                label: 'Rewards',
                isSelected: currentIndex == NavTab.rewards.index,
                onTap: () => onTap(NavTab.rewards.index),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: currentIndex == NavTab.profile.index,
                onTap: () => onTap(NavTab.profile.index),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: isSelected ? AppColors.white : AppColors.gray500,
                      ),
                    ),
                    if (badge != null && badge! > 0)
                      Positioned(
                        top: -2,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          ),
                          child: Text(
                            badge! > 99 ? '99+' : '$badge',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
