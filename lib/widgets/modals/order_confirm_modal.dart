import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class OrderConfirmModal extends StatelessWidget {
  const OrderConfirmModal({
    super.key,
    required this.order,
    required this.onDone,
  });

  final Order order;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusModal)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Order Placed!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Order #${order.id}',
            style: const TextStyle(
              color: AppColors.gray700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order will be ready for pickup at ${order.store.name}',
            style: const TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            child: Column(
              children: [
                _row('Pickup Time', AppConstants.pickupTimeLabel(order.pickupTime)),
                _row('Total', '\$${order.total.toStringAsFixed(2)}'),
                if (order.pointsEarned > 0)
                  _row('Points Earned', '+${order.pointsEarned} ⭐'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray700,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
