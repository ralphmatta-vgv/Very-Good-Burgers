import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/customization.dart';
import '../models/menu_item.dart';
import '../utils/constants.dart';
import '../utils/storage_service.dart';
import '../services/braze_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.totalPrice);

  double get tax => subtotal * AppConstants.taxRate;

  double get total => subtotal + tax;

  CartProvider() {
    _items = StorageService.getCart();
  }

  String _generateCartItemId() {
    return 'ci_${DateTime.now().millisecondsSinceEpoch}_${_items.length}';
  }

  void addToCart(
    MenuItem item,
    List<Customization> customizations,
    int quantity, {
    bool isRedeemedReward = false,
  }) {
    final id = _generateCartItemId();
    final cartItem = CartItem(
      id: id,
      item: item,
      customizations: customizations,
      quantity: quantity,
      isRedeemedReward: isRedeemedReward,
    );
    _items.add(cartItem);
    _persist();

    final customizationTotal = customizations.fold(0.0, (s, c) => s + c.price);
    final totalPrice = (item.price + customizationTotal) * quantity;

    BrazeService.logCustomEvent('add_to_cart', {
      'product_id': item.id,
      'product_name': item.name,
      'product_category': item.category,
      'base_price': item.price,
      'quantity': quantity,
      'customizations': customizations.map((c) => c.name).toList(),
      'customization_total': customizationTotal,
      'total_price': totalPrice,
    });

    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    final index = _items.indexWhere((e) => e.id == cartItemId);
    if (index < 0) return;
    final oldQty = _items[index].quantity;
    if (newQuantity < 1) {
    } else {
      _items[index].quantity = newQuantity;
      _persist();
      BrazeService.logCustomEvent('update_cart_quantity', {
        'product_id': _items[index].item.id,
        'product_name': _items[index].item.name,
        'old_quantity': oldQty,
        'new_quantity': newQuantity,
      });
    }
    notifyListeners();
  }

  void incrementQuantity(String cartItemId) {
    final item = _items.firstWhere((e) => e.id == cartItemId, orElse: () => _items.first);
    if (item.id == cartItemId) {
      updateQuantity(cartItemId, item.quantity + 1);
    }
  }

  void decrementQuantity(String cartItemId) {
    final index = _items.indexWhere((e) => e.id == cartItemId);
    if (index < 0) return;
    final qty = _items[index].quantity;
    if (qty <= 1) {
      removeItem(cartItemId);
    } else {
      updateQuantity(cartItemId, qty - 1);
    }
  }

  void removeItem(String cartItemId) {
    final index = _items.indexWhere((e) => e.id == cartItemId);
    if (index < 0) return;
    final removed = _items.removeAt(index);
    _persist();
    BrazeService.logCustomEvent('remove_from_cart', {
      'product_id': removed.item.id,
      'product_name': removed.item.name,
      'quantity': removed.quantity,
      'total_price': removed.totalPrice,
    });
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _persist();
    notifyListeners();
  }

  void _persist() {
    StorageService.saveCart(_items);
  }
}
