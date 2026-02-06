import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/store.dart';
import '../data/menu_data.dart';
import '../utils/constants.dart';
import '../utils/storage_service.dart';
import '../services/braze_tracking.dart';

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
    // Refresh Braze with current favorite store and other derived attributes on every launch.
    _sendDerivedAttributes();
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
    BrazeTracking.trackStoreSelected(storeId: store.id, storeName: store.name, storeDistance: store.distance);
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

  Future<void> completeOrder(Order order, int pointsEarned, bool rewardRedeemed) async {
    final hadLTOCoupon = _appliedCoupon == AppConstants.doubleSmashCouponCode;

    _orderHistory.insert(0, order);
    if (rewardRedeemed && _availableRewards >= 1) {
      _availableRewards -= 1;
      BrazeTracking.trackRewardRedeemed(orderId: order.id);
    }
    if (pointsEarned >= 1) {
      _bites += pointsEarned;
      while (_bites >= AppConstants.pointsForReward) {
        _bites -= AppConstants.pointsForReward;
        _availableRewards += 1;
      }
      _bites = _bites.clamp(0, 10);
      BrazeTracking.trackLoyaltyPointEarned(
        pointsEarned: pointsEarned,
        newTotal: _bites,
        orderId: order.id,
        qualifyingAmount: AppConstants.qualifyingAmountForPoint.toDouble(),
      );
    }
    StorageService.saveLoyaltyPoints(_bites);
    await StorageService.saveOrderHistory(_orderHistory);

    BrazeTracking.setLoyaltyAttributes(
      loyaltyPoints: _bites,
      availableRewards: _availableRewards,
      totalOrders: _orderHistory.length,
      lastOrderDateIso: order.createdAt.toIso8601String(),
    );

    BrazeTracking.trackPurchases(order);

    final itemsCount = order.items.fold<int>(0, (s, i) => s + i.quantity);
    BrazeTracking.trackOrderCompleted(
      orderId: order.id,
      subtotal: order.subtotal,
      tax: order.tax,
      total: order.total,
      itemsCount: itemsCount,
      uniqueItems: order.items.length,
      storeId: order.store.id,
      storeName: order.store.name,
      pickupTime: order.pickupTime,
      rewardRedeemed: rewardRedeemed,
      rewardDiscount: order.rewardDiscount,
      couponDiscount: order.couponDiscount,
      pointsEarned: pointsEarned,
      paymentMethod: 'card',
    );

    if (hadLTOCoupon) {
      BrazeTracking.trackLTOCouponRedeemed();
    }

    _sendDerivedAttributes();
    _appliedCoupon = null;
    notifyListeners();
  }

  void _sendDerivedAttributes() {
    if (_orderHistory.isEmpty) return;

    int totalEarned = 0;
    int totalRedeemed = 0;
    int totalCoupons = 0;
    double sumTotal = 0;
    final storeCounts = <String, int>{};
    final itemCounts = <String, int>{};

    for (final order in _orderHistory) {
      totalEarned += order.pointsEarned;
      if (order.items.any((i) => i.isRedeemedReward)) totalRedeemed += 1;
      if (order.couponDiscount > 0) totalCoupons += 1;
      sumTotal += order.total;
      storeCounts[order.store.id] = (storeCounts[order.store.id] ?? 0) + 1;
      for (final line in order.items) {
        final key = '${line.item.category}:${line.item.name}';
        itemCounts[key] = (itemCounts[key] ?? 0) + line.quantity;
      }
    }

    BrazeTracking.setTotalEarnedRewards(totalEarned);
    BrazeTracking.setTotalRedeemedRewards(totalRedeemed);
    BrazeTracking.setTotalCouponsRedeemed(totalCoupons);
    BrazeTracking.setAverageCartValue(sumTotal / _orderHistory.length);

    if (storeCounts.isNotEmpty) {
      final favoriteStoreId = storeCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      Order? favoriteOrder;
      for (final o in _orderHistory) {
        if (o.store.id == favoriteStoreId) {
          favoriteOrder = o;
          break;
        }
      }
      final description = favoriteOrder != null
          ? '${favoriteOrder.store.name} — ${favoriteOrder.store.address}'
          : favoriteStoreId;
      BrazeTracking.setFavoriteStoreDescription(description);
    }

    String? topInCategory(String category) {
      final filtered = itemCounts.entries.where((e) => e.key.startsWith('$category:'));
      if (filtered.isEmpty) return null;
      return filtered.reduce((a, b) => a.value >= b.value ? a : b).key.split(':').last;
    }

    BrazeTracking.setFavoriteBurger(topInCategory('Burgers'));
    BrazeTracking.setFavoriteDrink(topInCategory('Drinks'));
    BrazeTracking.setFavoriteCombo(topInCategory('Combos'));
    BrazeTracking.setFavoriteDessert(topInCategory('Desserts'));
  }

  static String generateOrderId() {
    return 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }
}
