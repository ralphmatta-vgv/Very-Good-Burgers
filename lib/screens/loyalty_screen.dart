import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../data/menu_data.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/punch_card.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              decoration: const BoxDecoration(
                color: AppColors.navy,
              ),
              child: Consumer<AppProvider>(
                builder: (context, app, _) {
                  final points = app.loyaltyPoints;
                  final filled = points.clamp(0, 10);
                  final rewardReady = filled >= 10;
                  final remaining = (10 - filled).clamp(0, 10);
                  return Column(
                    children: [
                      Text(
                        '$points',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Reward Points',
                        style: TextStyle(
                          color: AppColors.gray300,
                          fontSize: 16,
                        ),
                      ),
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
                          backgroundColor: AppColors.navyLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        rewardReady
                            ? '🎉 Reward ready to redeem!'
                            : '$remaining more points until your next reward',
                        style: const TextStyle(
                          color: AppColors.gray300,
                          fontSize: 14,
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
                      'Earn 1 point for every qualifying purchase of \$10 or more.',
                      style: TextStyle(color: AppColors.gray700, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Collect 10 points to redeem a free item of your choice!',
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
                    final canRedeem = app.loyaltyPoints >= 10;
                    final pts = reward['points'] as int;
                    final needed = (pts - app.loyaltyPoints).clamp(0, pts);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: Row(
                          children: [
                            Text(
                              reward['emoji'] as String,
                              style: const TextStyle(fontSize: 36),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reward['name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: canRedeem
                                          ? AppColors.success.withValues(alpha: 0.2)
                                          : AppColors.gray200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      canRedeem ? 'Ready!' : '$needed more',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: canRedeem ? AppColors.success : AppColors.gray700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                      'No orders yet. Place your first order to start earning points!',
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
                                        ? 'Earned ${order.pointsEarned} point'
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
    );
  }
}
