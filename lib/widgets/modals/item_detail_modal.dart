import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

import '../../models/customization.dart';
import '../../models/menu_item.dart';
import '../../data/menu_data.dart';
import '../../providers/cart_provider.dart';
import '../../services/braze_service.dart';
import '../../utils/theme.dart';

class ItemDetailModal extends StatefulWidget {
  const ItemDetailModal({
    super.key,
    required this.item,
    required this.onAdded,
    required this.onClose,
    this.redeemReward = false,
  });

  final MenuItem item;
  final VoidCallback onAdded;
  final VoidCallback onClose;
  final bool redeemReward;

  @override
  State<ItemDetailModal> createState() => _ItemDetailModalState();
}

class _ItemDetailModalState extends State<ItemDetailModal> {
  final Set<String> _selectedCustomizationIds = {};
  int _quantity = 1;

  List<Customization> get _availableCustomizations =>
      MenuData.customizationsForCategory(widget.item.category);

  double get _customizationTotal =>
      _availableCustomizations
          .where((c) => _selectedCustomizationIds.contains(c.id))
          .fold(0.0, (s, c) => s + c.price);

  double get _unitPrice => widget.redeemReward ? 0 : (widget.item.price + _customizationTotal);
  double get _totalPrice => _unitPrice * _quantity;

  @override
  void initState() {
    super.initState();
    BrazeService.logCustomEvent('product_viewed', {
      'product_id': widget.item.id,
      'product_name': widget.item.name,
      'product_category': widget.item.category,
      'price': widget.item.price,
    });
  }

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
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(),
                  if (_availableCustomizations.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildCustomizations(),
                  ],
                  const SizedBox(height: 24),
                  _buildQuantity(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildAddButton(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Customize',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Column(
        children: [
          Text(
            widget.item.emoji,
            style: const TextStyle(fontSize: 100),
          ),
          const SizedBox(height: 12),
          Text(
            widget.item.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.item.description,
            style: const TextStyle(
              color: AppColors.gray700,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.redeemReward ? 'Free with 10 Bites' : '${widget.item.calories} cal',
            style: const TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customizations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 12),
        ..._availableCustomizations.map((c) {
          final isSelected = _selectedCustomizationIds.contains(c.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCustomizationIds.remove(c.id);
                    } else {
                      _selectedCustomizationIds.add(c.id);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                        color: isSelected ? AppColors.primary : AppColors.gray400,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      if (c.price > 0)
                        Text(
                          '+\$${c.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuantity() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: _quantity > 1
              ? () => setState(() => _quantity--)
              : null,
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.gray200,
            foregroundColor: AppColors.navy,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '$_quantity',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton.filled(
          onPressed: () => setState(() => _quantity++),
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
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
              final customizations = _availableCustomizations
                  .where((c) => _selectedCustomizationIds.contains(c.id))
                  .toList();
              context.read<CartProvider>().addToCart(
                    widget.item,
                    customizations,
                    _quantity,
                    isRedeemedReward: widget.redeemReward,
                  );
              if (widget.redeemReward) {
                context.read<AppProvider>().setRedeemReward(true);
              }
              widget.onAdded();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    widget.redeemReward ? 'Add as reward' : 'Add to Cart',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.redeemReward ? '\$0.00' : '\$${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
