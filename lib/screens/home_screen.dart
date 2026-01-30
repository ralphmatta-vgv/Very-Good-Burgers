import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/menu_data.dart';
import '../models/menu_item.dart';
import '../providers/app_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../utils/theme.dart';
import '../widgets/promo_card.dart';
import '../widgets/punch_card.dart';
import '../widgets/modals/item_detail_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onOrderNow,
    this.onTapOrder,
    this.onTapRewards,
    this.onTapHistory,
    this.onOpenOrderHistory,
    this.onShowCart,
    this.onShowStoreModal,
  });

  final VoidCallback? onOrderNow;
  final VoidCallback? onTapOrder;
  final VoidCallback? onTapRewards;
  final VoidCallback? onTapHistory;
  final VoidCallback? onOpenOrderHistory;
  final VoidCallback? onShowCart;
  final VoidCallback? onShowStoreModal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Top bar: welcome + store left, cart right (no logo)
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
              child: SafeArea(
                bottom: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<UserProvider>(
                            builder: (context, userProv, _) {
                              return Text(
                                'Welcome back, ${userProv.user?.firstName ?? 'Guest'}! 👋',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy,
                                  letterSpacing: -0.3,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Consumer<AppProvider>(
                            builder: (context, app, _) {
                              final store = app.selectedStore;
                              if (store == null) return const SizedBox.shrink();
                              return GestureDetector(
                                onTap: onShowStoreModal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('📍', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                store.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: AppColors.navy,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Change',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            store.address,
                                            style: const TextStyle(
                                              color: AppColors.gray500,
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
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
                    if (onShowCart != null)
                      Consumer<CartProvider>(
                        builder: (context, cart, _) {
                          return IconButton(
                            icon: Badge(
                              isLabelVisible: cart.itemCount > 0,
                              label: Text(
                                '${cart.itemCount}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                              backgroundColor: AppColors.primary,
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                color: AppColors.navy,
                                size: 24,
                              ),
                            ),
                            onPressed: onShowCart,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.gray100,
                            ),
                          );
                        },
                      ),
                  ],
                ),
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
                onTap: onOrderNow ?? () {},
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
                _QuickAction(icon: '🍔', label: 'Order', onTap: onTapOrder ?? () {}),
                _QuickAction(icon: '🎁', label: 'Rewards', onTap: onTapRewards ?? () {}),
                _QuickAction(icon: '📍', label: 'Locations', onTap: onShowStoreModal ?? () {}),
                _QuickAction(icon: '📜', label: 'History', onTap: onOpenOrderHistory ?? () {}),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: _LoyaltyPreviewCard(onTapRewards: onTapRewards),
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
          onAdded: () {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Item added to cart'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.primary,
                margin: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).size.height - 140,
                ),
              ),
            );
          },
          onClose: () => Navigator.of(ctx).pop(),
        ),
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
  const _LoyaltyPreviewCard({this.onTapRewards});

  final VoidCallback? onTapRewards;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        final points = app.loyaltyPoints;
        final filled = points.clamp(0, 10);
        final rewardReady = app.availableRewards >= 1;
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
                    onPressed: onTapRewards ?? () {},
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
                  child: Row(
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Free item ready to redeem!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      if (onTapRewards != null)
                        TextButton(
                          onPressed: onTapRewards,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('Redeem'),
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
