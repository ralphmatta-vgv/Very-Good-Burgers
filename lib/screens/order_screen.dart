import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/menu_data.dart';
import '../models/menu_item.dart';
import '../providers/app_provider.dart';
import '../providers/cart_provider.dart';
import '../services/braze_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/modals/item_detail_modal.dart';
import '../widgets/modals/store_modal.dart';
import '../widgets/modals/cart_modal.dart';
import '../widgets/modals/order_confirm_modal.dart';
import '../models/order.dart' as order_model;

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, this.onOrderConfirmed});

  final VoidCallback? onOrderConfirmed;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _selectedCategory = MenuData.categoryTabs.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Consumer<AppProvider>(
              builder: (context, app, _) {
                final store = app.selectedStore ?? MenuData.defaultStore;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                  child: Material(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    child: InkWell(
                      onTap: () => _showStoreModal(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Text('📍', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    store.address,
                                    style: const TextStyle(
                                      color: AppColors.gray500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text('Change', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: MenuData.categoryTabs.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: isSelected ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          BrazeService.logCustomEvent('category_viewed', {'category': cat});
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.gray700,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final items = MenuData.itemsForCategory(_selectedCategory);
                  if (index >= items.length) return null;
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MenuItemCard(
                      item: item,
                      onTap: () => _showItemDetail(context, item),
                    ),
                  );
                },
                childCount: MenuData.itemsForCategory(_selectedCategory).length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _showCartModal(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.shopping_cart),
            label: Text('${cart.itemCount}'),
          );
        },
      ),
    );
  }

  void _showItemDetail(BuildContext context, MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) => ItemDetailModal(
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

  void _showCartModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) => CartModal(
          onClose: () => Navigator.of(ctx).pop(),
          onPlaceOrder: (order_model.Order order) {
            Navigator.of(ctx).pop();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx2) => OrderConfirmModal(
                order: order,
                onDone: () {
                  Navigator.of(ctx2).pop();
                  widget.onOrderConfirmed?.call();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
