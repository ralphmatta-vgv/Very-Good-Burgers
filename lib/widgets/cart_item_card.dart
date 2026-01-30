import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../utils/theme.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.cartItem,
  });

  final CartItem cartItem;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cartItem.item.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (cartItem.customizations.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        cartItem.customizations.map((c) => c.name).join(', '),
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () => cart.decrementQuantity(cartItem.id),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => cart.incrementQuantity(cartItem.id),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => cart.removeItem(cartItem.id),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: AppColors.error, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
