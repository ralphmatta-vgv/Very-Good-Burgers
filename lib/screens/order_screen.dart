import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/menu_data.dart';
import '../models/menu_item.dart';
import '../providers/app_provider.dart';
import '../providers/cart_provider.dart';
import '../services/braze_service.dart';
import '../utils/theme.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/modals/item_detail_modal.dart';
import '../widgets/modals/store_modal.dart';
import '../widgets/modals/cart_modal.dart';
import '../widgets/modals/order_confirm_modal.dart';
import '../models/order.dart' as order_model;

const double _kSectionHeaderHeight = 56;
const double _kMenuItemHeight = 100;

/// LTO (Double Smash Deal) is only accessible via Home promo CTA; hide from Order menu.
const String _kLtoItemId = 'b_double_smash';

List<MenuItem> _orderMenuItemsForCategory(String category) {
  return MenuData.itemsForCategory(category)
      .where((item) => item.id != _kLtoItemId)
      .toList();
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({
    super.key,
    this.onOrderConfirmed,
    this.pendingItem,
    this.onClearPendingItem,
    this.pendingRewardItem,
    this.onClearPendingRewardItem,
    this.onOpenOrderHistory,
  });

  final VoidCallback? onOrderConfirmed;
  final MenuItem? pendingItem;
  final VoidCallback? onClearPendingItem;
  final MenuItem? pendingRewardItem;
  final VoidCallback? onClearPendingRewardItem;
  final VoidCallback? onOpenOrderHistory;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _selectedCategory = MenuData.categoryTabs.first;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  late List<double> _sectionOffsets;
  static const double _kCategoryChipWidth = 100;

  @override
  void initState() {
    super.initState();
    _sectionOffsets = _computeSectionOffsets();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pendingItem != null && mounted) {
        _showItemDetail(context, widget.pendingItem!, redeemReward: false);
        widget.onClearPendingItem?.call();
      } else if (widget.pendingRewardItem != null && mounted) {
        _showItemDetail(context, widget.pendingRewardItem!, redeemReward: true);
        widget.onClearPendingRewardItem?.call();
      }
    });
  }

  @override
  void didUpdateWidget(OrderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted) {
      if (widget.pendingItem != null && widget.pendingItem != oldWidget.pendingItem) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.pendingItem != null) {
            _showItemDetail(context, widget.pendingItem!, redeemReward: false);
            widget.onClearPendingItem?.call();
          }
        });
      } else if (widget.pendingRewardItem != null && widget.pendingRewardItem != oldWidget.pendingRewardItem) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.pendingRewardItem != null) {
            _showItemDetail(context, widget.pendingRewardItem!, redeemReward: true);
            widget.onClearPendingRewardItem?.call();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _scrollCategoryToSelected() {
    final index = MenuData.categoryTabs.indexOf(_selectedCategory);
    if (index < 0) return;
    final targetOffset = (index * _kCategoryChipWidth).toDouble().clamp(0.0, _categoryScrollController.position.maxScrollExtent);
    if (_categoryScrollController.hasClients) {
      _categoryScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  List<double> _computeSectionOffsets() {
    final offsets = <double>[0];
    for (final cat in MenuData.categoryTabs) {
      final len = _orderMenuItemsForCategory(cat).length;
      offsets.add(offsets.last + _kSectionHeaderHeight + len * _kMenuItemHeight);
    }
    return offsets;
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    int index = 0;
    for (var i = 0; i < _sectionOffsets.length - 1; i++) {
      if (offset >= _sectionOffsets[i] && offset < _sectionOffsets[i + 1] - 20) {
        index = i;
        break;
      }
      index = i + 1;
    }
    if (index >= MenuData.categoryTabs.length) index = MenuData.categoryTabs.length - 1;
    final newCat = MenuData.categoryTabs[index];
    if (newCat != _selectedCategory) {
      setState(() => _selectedCategory = newCat);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollCategoryToSelected());
    }
  }

  int _totalItemCount() {
    var count = 0;
    for (final cat in MenuData.categoryTabs) {
      count += 1 + _orderMenuItemsForCategory(cat).length;
    }
    return count + 1; // +1 for Order History footer
  }

  (int sectionIndex, bool isHeader, int itemIndex) _indexToSection(int index) {
    var remaining = index;
    for (var s = 0; s < MenuData.categoryTabs.length; s++) {
      final items = _orderMenuItemsForCategory(MenuData.categoryTabs[s]);
      if (remaining == 0) return (s, true, 0);
      remaining--;
      if (remaining < items.length) return (s, false, remaining);
      remaining -= items.length;
    }
    return (0, true, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Store card
            Consumer<AppProvider>(
              builder: (context, app, _) {
                final store = app.selectedStore ?? MenuData.defaultStore;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
                          const Text(
                            'Change',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Persistent section tabs (scroll to keep selected in view)
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: SingleChildScrollView(
              controller: _categoryScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: MenuData.categoryTabs.asMap().entries.map((e) {
                  final cat = e.value;
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: isSelected ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () {
                          final idx = MenuData.categoryTabs.indexOf(cat);
                          if (idx >= 0 && idx < _sectionOffsets.length) {
                            _scrollController.animateTo(
                              _sectionOffsets[idx],
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
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
          // Scrollable menu (all sections)
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: _totalItemCount(),
              itemBuilder: (context, index) {
                final menuCount = _totalItemCount() - 1;
                if (index == menuCount) {
                  return _OrderHistoryFooter(onTap: widget.onOpenOrderHistory);
                }
                final (sectionIndex, isHeader, itemIndex) = _indexToSection(index);
                final cat = MenuData.categoryTabs[sectionIndex];
                if (isHeader) {
                  return SizedBox(
                    height: _kSectionHeaderHeight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        child: Text(
                          cat,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                final items = _orderMenuItemsForCategory(cat);
                if (itemIndex >= items.length) return const SizedBox.shrink();
                final item = items[itemIndex];
                return SizedBox(
                  height: _kMenuItemHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MenuItemCard(
                      item: item,
                      onTap: () => _showItemDetail(context, item, redeemReward: false),
                      compact: true,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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

  void _showItemDetail(BuildContext context, MenuItem item, {bool redeemReward = false}) {
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
          redeemReward: redeemReward,
          onAdded: () {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  redeemReward ? 'Free item added to cart' : 'Item added to cart',
                ),
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

class _OrderHistoryFooter extends StatelessWidget {
  const _OrderHistoryFooter({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Text('📜', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'View order history',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.gray400, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
