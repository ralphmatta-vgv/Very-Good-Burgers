import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../data/menu_data.dart';
import '../models/menu_item.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../widgets/punch_card.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key, this.onRedeemRewardItem});

  final void Function(MenuItem item)? onRedeemRewardItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Lead with Bites count (no navy header); top padding + centered
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Consumer<AppProvider>(
                  builder: (context, app, _) {
                    final bites = app.loyaltyPoints;
                    final filled = bites.clamp(0, 10);
                    final rewardsAvailable = app.availableRewards;
                    final rewardReady = rewardsAvailable >= 1;
                    final remaining = (10 - filled).clamp(0, 10);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$bites',
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Bites',
                          style: TextStyle(
                            color: AppColors.gray500,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (rewardsAvailable > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            '$rewardsAvailable reward${rewardsAvailable == 1 ? '' : 's'} available',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        PunchCard(
                          filledCount: filled,
                          total: 10,
                          showNumbers: true,
                          size: 44,
                          useBurgerIcon: true,
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: filled / 10,
                            minHeight: 6,
                            backgroundColor: AppColors.gray200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          rewardReady
                              ? '🎉 Reward ready — pick a free item below!'
                              : '$remaining Bites until your next reward',
                          style: TextStyle(
                            color: rewardReady ? AppColors.primary : AppColors.gray500,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How It Works',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Every \$10+ order earns you a Bite. Spend Bites and earn a free menu item. Rewards never expire!',
                      style: TextStyle(color: AppColors.gray700, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Available Rewards',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final reward = MenuData.redeemableRewards[index];
                return Consumer<AppProvider>(
                  builder: (context, app, _) {
                    final canRedeem = app.availableRewards >= 1;
                    final bitesToNext = (10 - app.loyaltyPoints).clamp(0, 10);
                    final itemId = reward['itemId'] as String?;
                    final menuItem = itemId != null ? MenuData.getItemById(itemId) : null;
                    final onTap = canRedeem && menuItem != null && onRedeemRewardItem != null
                        ? () => onRedeemRewardItem!(menuItem)
                        : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Material(
                        color: canRedeem ? AppColors.white : AppColors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        child: InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                          child: Opacity(
                            opacity: canRedeem ? 1 : 0.75,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                                border: Border.all(
                                  color: canRedeem ? AppColors.gray200 : AppColors.gray200.withValues(alpha: 0.8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    reward['emoji'] as String,
                                    style: TextStyle(fontSize: 36, color: canRedeem ? null : AppColors.gray500),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reward['name'] as String,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: canRedeem ? AppColors.navy : AppColors.gray500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: canRedeem
                                                ? AppColors.success.withValues(alpha: 0.2)
                                                : AppColors.primary.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            canRedeem ? 'Ready! Tap to redeem' : '$bitesToNext Bites to go',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: canRedeem ? AppColors.success : AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (canRedeem && onTap != null)
                                    const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: MenuData.redeemableRewards.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer<AppProvider>(
              builder: (context, app, _) {
                final history = app.orderHistory.take(10).toList();
                if (history.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'No orders yet. Place your first order to start earning Bites!',
                      style: TextStyle(color: AppColors.gray500, fontSize: 14),
                    ),
                  );
                }
                return Column(
                  children: history.map((order) {
                    final hasPoints = order.pointsEarned > 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        ),
                        child: Row(
                          children: [
                            Text(
                              hasPoints ? '⭐' : '🛒',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hasPoints
                                        ? 'Earned ${order.pointsEarned} Bite'
                                        : 'Order placed',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    DateFormat.MMMd().format(order.createdAt),
                                    style: const TextStyle(
                                      color: AppColors.gray500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
