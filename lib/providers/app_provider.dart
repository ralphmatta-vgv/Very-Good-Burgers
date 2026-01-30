import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/store.dart';
import '../data/menu_data.dart';
import '../utils/constants.dart';
import '../utils/storage_service.dart';
import '../services/braze_service.dart';

class AppProvider with ChangeNotifier {
  int _bites = 0; // Progress 0–10 toward next reward; resets to 0 when reaching 10
  int _availableRewards = 0; // Banked rewards (earned every 10 qualifying orders)
  Store? _selectedStore;
  String _pickupTime = 'asap';
  bool _redeemReward = false;
  List<Order> _orderHistory = [];
  String? _appliedCoupon;

  /// Current Bites progress (0–10). Qualifying orders add 1; at 10 you earn a reward and reset to 0.
  int get loyaltyPoints => _bites;
  int get availableRewards => _availableRewards;
  Store? get selectedStore => _selectedStore;
  String get pickupTime => _pickupTime;
  bool get redeemReward => _redeemReward;
  List<Order> get orderHistory => List.unmodifiable(_orderHistory);
  String? get appliedCoupon => _appliedCoupon;

  /// Can redeem a free item if user has at least one banked reward (separate from Bites).
  bool get canRedeemReward => _availableRewards >= 1;

  /// 20% off when Double Smash coupon is applied (applies to subtotal before tax).
  double get couponDiscount {
    if (_appliedCoupon != AppConstants.doubleSmashCouponCode) return 0;
    return 0; // computed per-cart in CartModal from cart.subtotal
  }

  void applyCoupon(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized == AppConstants.doubleSmashCouponCode) {
      _appliedCoupon = normalized;
      notifyListeners();
    }
  }

  void clearCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  AppProvider() {
    _orderHistory = StorageService.getOrderHistory();
    final (bites, rewards) = _deriveBitesAndRewardsFromOrderHistory();
    _bites = bites;
    _availableRewards = rewards;
    _selectedStore = StorageService.getSelectedStore();
    _pickupTime = StorageService.getPickupTime();
    if (_selectedStore == null) {
      _selectedStore = MenuData.defaultStore;
      StorageService.saveSelectedStore(_selectedStore!);
    }
  }

  /// Earning and redeeming are separate: Bites 0–10 loop; at 10 → +1 reward, Bites→0. Redeeming spends a banked reward.
  (int bites, int availableRewards) _deriveBitesAndRewardsFromOrderHistory() {
    int bites = 0;
    int rewards = 0;
    for (final order in _orderHistory.reversed) {
      final hadRedeemedItem = order.items.any((i) => i.isRedeemedReward);
      if (hadRedeemedItem) {
        rewards = (rewards - 1).clamp(0, 999);
      } else if (order.pointsEarned >= 1) {
        bites += order.pointsEarned;
        while (bites >= AppConstants.pointsForReward) {
          bites -= AppConstants.pointsForReward;
          rewards += 1;
        }
      }
    }
    return (bites.clamp(0, 10), rewards);
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
    if (rewardRedeemed && _availableRewards >= 1) {
      _availableRewards -= 1;
      BrazeService.logCustomEvent('reward_redeemed', {
        'order_id': order.id,
      });
    }
    if (pointsEarned >= 1) {
      _bites += pointsEarned;
      while (_bites >= AppConstants.pointsForReward) {
        _bites -= AppConstants.pointsForReward;
        _availableRewards += 1;
      }
      _bites = _bites.clamp(0, 10);
      BrazeService.logCustomEvent('loyalty_point_earned', {
        'points_earned': pointsEarned,
        'new_total': _bites,
        'order_id': order.id,
        'qualifying_amount': AppConstants.qualifyingAmountForPoint,
      });
    }
    StorageService.saveLoyaltyPoints(_bites);
    StorageService.saveOrderHistory(_orderHistory);
    BrazeService.setUserAttribute('loyalty_points', _bites);
    BrazeService.setUserAttribute('available_rewards', _availableRewards);
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
      'coupon_discount': order.couponDiscount,
      'points_earned': pointsEarned,
      'payment_method': 'card',
    });
    _appliedCoupon = null;
    notifyListeners();
  }

  static String generateOrderId() {
    return 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }
}
