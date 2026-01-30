import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/menu_data.dart';
import '../models/menu_item.dart';
import '../providers/app_provider.dart';
import '../providers/user_provider.dart';
import '../utils/theme.dart';
import '../services/braze_service.dart';
import '../widgets/promo_card.dart';
import '../widgets/punch_card.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/modals/item_detail_modal.dart';
import '../widgets/modals/store_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gray300.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<UserProvider>(
                    builder: (context, userProv, _) {
                      return Text(
                        'Welcome back, ${userProv.user?.firstName ?? 'Guest'}! 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                          letterSpacing: -0.3,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<AppProvider>(
                    builder: (context, app, _) {
                      final store = app.selectedStore;
                      if (store == null) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () => _showStoreModal(context),
                        child: Row(
                          children: [
                            const Text('📍', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  Text(
                                    store.address,
                                    style: const TextStyle(
                                      color: AppColors.gray500,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'Change',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: PromoCard(
                tag: 'LIMITED TIME',
                title: 'Double Smash Deal',
                description: 'Get any combo for 20% off this weekend only!',
                ctaLabel: 'Order Now',
                onTap: () {
                  BrazeService.logCustomEvent('tab_viewed', {'tab_name': 'order'});
                  // Could navigate to Order tab - handled by parent
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildListDelegate([
                _QuickAction(icon: '🍔', label: 'Order', onTap: () {}),
                _QuickAction(icon: '🎁', label: 'Rewards', onTap: () {}),
                _QuickAction(icon: '📍', label: 'Locations', onTap: () {}),
                _QuickAction(icon: '📜', label: 'History', onTap: () {}),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: _LoyaltyPreviewCard(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Items',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 88,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: MenuData.burgers.take(5).length,
                itemBuilder: (context, index) {
                  final item = MenuData.burgers[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _PopularItemChip(
                      item: item,
                      onTap: () => _showItemDetail(context, item),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _showItemDetail(BuildContext context, item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ItemDetailModal(
          item: item,
          onAdded: () => Navigator.of(ctx).pop(),
          onClose: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _showStoreModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StoreModal(
        onClose: () => Navigator.of(ctx).pop(),
        onStoreSelected: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}

class _PopularItemChip extends StatelessWidget {
  const _PopularItemChip({required this.item, required this.onTap});

  final MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoyaltyPreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        final points = app.loyaltyPoints;
        final filled = points.clamp(0, 10);
        final rewardReady = filled >= 10;
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            boxShadow: [
              BoxShadow(
                color: AppColors.gray300.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Rewards',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              if (rewardReady)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text('🎉', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Free item ready to redeem!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Center(
                child: PunchCard(
                  filledCount: filled,
                  total: 10,
                  showNumbers: true,
                  size: 36,
                  useBurgerIcon: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
