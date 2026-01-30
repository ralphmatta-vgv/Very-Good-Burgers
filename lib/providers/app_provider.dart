import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/store.dart';
import '../data/menu_data.dart';
import '../utils/constants.dart';
import '../utils/storage_service.dart';
import '../services/braze_service.dart';

class AppProvider with ChangeNotifier {
  int _loyaltyPoints = 7;
  Store? _selectedStore;
  String _pickupTime = 'asap';
  bool _redeemReward = false;
  List<Order> _orderHistory = [];

  int get loyaltyPoints => _loyaltyPoints;
  Store? get selectedStore => _selectedStore;
  String get pickupTime => _pickupTime;
  bool get redeemReward => _redeemReward;
  List<Order> get orderHistory => List.unmodifiable(_orderHistory);

  bool get canRedeemReward => _loyaltyPoints >= AppConstants.pointsForReward;

  AppProvider() {
    _loyaltyPoints = StorageService.getLoyaltyPoints();
    _selectedStore = StorageService.getSelectedStore();
    _pickupTime = StorageService.getPickupTime();
    _orderHistory = StorageService.getOrderHistory();
    if (_selectedStore == null) {
      _selectedStore = MenuData.defaultStore;
      StorageService.saveSelectedStore(_selectedStore!);
    }
  }

  void setSelectedStore(Store store) {
    _selectedStore = store;
    StorageService.saveSelectedStore(store);
    BrazeService.logCustomEvent('store_selected', {
      'store_id': store.id,
      'store_name': store.name,
      'store_distance': store.distance,
    });
    notifyListeners();
  }

  void setPickupTime(String value) {
    _pickupTime = value;
    StorageService.savePickupTime(value);
    notifyListeners();
  }

  void setRedeemReward(bool value) {
    _redeemReward = value;
    notifyListeners();
  }

  void completeOrder(Order order, int pointsEarned, bool rewardRedeemed) {
    _orderHistory.insert(0, order);
    if (rewardRedeemed && _loyaltyPoints >= AppConstants.pointsForReward) {
      _loyaltyPoints -= AppConstants.pointsForReward;
      BrazeService.logCustomEvent('reward_redeemed', {
        'points_spent': AppConstants.pointsForReward,
        'order_id': order.id,
      });
    }
    _loyaltyPoints += pointsEarned;
    if (pointsEarned > 0) {
      BrazeService.logCustomEvent('loyalty_point_earned', {
        'points_earned': pointsEarned,
        'new_total': _loyaltyPoints,
        'order_id': order.id,
        'qualifying_amount': AppConstants.qualifyingAmountForPoint,
      });
    }
    StorageService.saveLoyaltyPoints(_loyaltyPoints);
    StorageService.saveOrderHistory(_orderHistory);
    BrazeService.setUserAttribute('loyalty_points', _loyaltyPoints);
    BrazeService.setUserAttribute('total_orders', _orderHistory.length);
    BrazeService.setUserAttribute('last_order_date', order.createdAt.toIso8601String());

    for (final item in order.items) {
      BrazeService.logPurchase(
        item.item.id,
        item.totalPrice,
        'USD',
        item.quantity,
        {
          'product_name': item.item.name,
          'product_category': item.item.category,
          'customizations': item.customizations.map((c) => c.name).toList(),
          'order_id': order.id,
          'store_id': order.store.id,
          'store_name': order.store.name,
        },
      );
    }

    BrazeService.logCustomEvent('order_completed', {
      'order_id': order.id,
      'subtotal': order.subtotal,
      'tax': order.tax,
      'total': order.total,
      'items_count': order.items.fold(0, (s, i) => s + i.quantity),
      'unique_items': order.items.length,
      'store_id': order.store.id,
      'store_name': order.store.name,
      'pickup_time': order.pickupTime,
      'reward_redeemed': rewardRedeemed,
      'reward_discount': order.rewardDiscount,
      'points_earned': pointsEarned,
      'payment_method': 'card',
    });
    notifyListeners();
  }

  static String generateOrderId() {
    return 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }
}
