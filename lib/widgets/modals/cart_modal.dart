import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/app_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../cart_item_card.dart';

class CartModal extends StatelessWidget {
  const CartModal({
    super.key,
    required this.onClose,
    required this.onPlaceOrder,
  });

  final VoidCallback onClose;
  final void Function(Order order) onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusModal)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(context),
          Flexible(
            child: Consumer2<CartProvider, AppProvider>(
              builder: (context, cart, app, _) {
                if (cart.items.isEmpty) {
                  return _buildEmptyState();
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCartInfo(context),
                      const SizedBox(height: 16),
                      ...cart.items.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CartItemCard(cartItem: e),
                          )),
                      if (app.canRedeemReward) _buildRewardBanner(context),
                      const SizedBox(height: 16),
                      _buildOrderSummary(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
          Consumer2<CartProvider, AppProvider>(
            builder: (context, cart, app, _) {
              if (cart.items.isEmpty) return const SizedBox.shrink();
              final rewardDiscount = app.redeemReward && app.canRedeemReward
                  ? AppConstants.rewardDiscountAmount
                  : 0.0;
              final total = cart.subtotal + cart.tax - rewardDiscount;
              return _buildPlaceOrderBar(context, total, cart, app);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.gray300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Your Cart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some delicious items to get started!',
            style: TextStyle(color: AppColors.gray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartInfo(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        final store = app.selectedStore;
        if (store == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Pickup time',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.gray700,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppConstants.pickupTimeOptions.map((key) {
                    final isSelected = app.pickupTime == key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: isSelected ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => app.setPickupTime(key),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Text(
                              AppConstants.pickupTimeLabel(key),
                              style: TextStyle(
                                color: isSelected ? AppColors.white : AppColors.gray700,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardBanner(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.gold),
          ),
          child: Row(
            children: [
              const Text('🎁', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Free Item Available!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Redeem 10 points for \$10 off',
                      style: TextStyle(
                        color: AppColors.gray700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: app.redeemReward,
                onChanged: (v) => app.setRedeemReward(v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Consumer2<CartProvider, AppProvider>(
      builder: (context, cart, app, _) {
        final rewardDiscount = app.redeemReward && app.canRedeemReward
            ? AppConstants.rewardDiscountAmount
            : 0.0;
        final total = cart.subtotal + cart.tax - rewardDiscount;
        final earnsPoint = total >= AppConstants.qualifyingAmountForPoint;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
          child: Column(
            children: [
              _summaryRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
              _summaryRow('Tax (8.875%)', '\$${cart.tax.toStringAsFixed(2)}'),
              if (rewardDiscount > 0)
                _summaryRow(
                  'Reward Discount',
                  '-\$${rewardDiscount.toStringAsFixed(2)}',
                  valueColor: AppColors.success,
                ),
              const Divider(height: 24),
              _summaryRow(
                'Total',
                '\$${total.toStringAsFixed(2)}',
                bold: true,
                large: true,
              ),
              if (earnsPoint) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text('⭐', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 4),
                    Text(
                      "You'll earn 1 loyalty point with this order!",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    bool large = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: large ? 16 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.gray700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: large ? 18 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderBar(
    BuildContext context,
    double total,
    CartProvider cart,
    AppProvider app,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray300.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final rewardDiscount = app.redeemReward && app.canRedeemReward
                  ? AppConstants.rewardDiscountAmount
                  : 0.0;
              final orderTotal = cart.subtotal + cart.tax - rewardDiscount;
              final pointsEarned = orderTotal >= AppConstants.qualifyingAmountForPoint
                  ? AppConstants.pointsPerQualifyingOrder
                  : 0;
              final order = Order(
                id: AppProvider.generateOrderId(),
                store: app.selectedStore!,
                pickupTime: app.pickupTime,
                items: List.from(cart.items),
                subtotal: cart.subtotal,
                tax: cart.tax,
                total: orderTotal,
                rewardDiscount: rewardDiscount,
                pointsEarned: pointsEarned,
                createdAt: DateTime.now(),
              );
              app.completeOrder(order, pointsEarned, app.redeemReward);
              cart.clear();
              app.setRedeemReward(false);
              onPlaceOrder(order);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
            ),
            child: Text('Place Order • \$${total.toStringAsFixed(2)}'),
          ),
        ),
      ),
    );
  }
}
