import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../utils/theme.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.emojiSize = 48,
    this.compact = false,
  });

  final MenuItem item;
  final VoidCallback onTap;
  final double emojiSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray300.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.emoji,
                  style: TextStyle(fontSize: emojiSize),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${item.calories} cal',
                              style: const TextStyle(
                                color: AppColors.gray500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (!compact)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.gray400,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
