/// Braze tracking layer: only sends events/attributes in the approved data plan (SENT).
/// See docs/braze_data_tracking_plan.csv and docs/BRAZE_DATA_SPEC.md.
import 'package:intl/intl.dart';

import '../models/order.dart';
import 'braze_service.dart';

/// Braze-friendly date format for segmentation (e.g. "Feb 05 2026").
final DateFormat _brazeDateFmt = DateFormat('MMM dd yyyy');

class BrazeTracking {
  BrazeTracking._();

  static void changeUser(String userId) {
    BrazeService.changeUser(userId);
  }

  // --- Standard profile attributes (SENT) — use Braze’s profile APIs so they show in main profile and work for messaging/deduplication ---
  static void setStandardAttributes({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    BrazeService.setFirstName(firstName.isEmpty ? null : firstName);
    BrazeService.setLastName(lastName.isEmpty ? null : lastName);
    BrazeService.setEmail(email.isEmpty ? null : email);
  }

  // --- Custom attributes (SENT) ---
  static void setLoyaltyAttributes({
    required int loyaltyPoints,
    required int availableRewards,
    required int totalOrders,
    required String lastOrderDateIso,
  }) {
    BrazeService.setUserAttribute('loyalty_points', loyaltyPoints);
    BrazeService.setUserAttribute('available_rewards', availableRewards);
    BrazeService.setUserAttribute('total_orders', totalOrders);
    final lastOrderFormatted = _formatDateForBraze(lastOrderDateIso);
    BrazeService.setUserAttribute('last_order_date', lastOrderFormatted ?? lastOrderDateIso);
  }

  /// Format date for Braze segmentation (e.g. "Feb 05 2026"). Returns null if unparseable.
  static String? _formatDateForBraze(String isoOrDateStr) {
    final dt = DateTime.tryParse(isoOrDateStr.trim());
    if (dt != null) return _brazeDateFmt.format(dt);
    return null;
  }

  static void setPhone(String? value) {
    if (value != null && value.isNotEmpty) {
      BrazeService.setPhoneNumber(value);
    }
  }

  static void setBirthday(String? value) {
    if (value == null || value.isEmpty) return;
    // Braze standard profile: setDateOfBirth(year, month, day); also keep custom 'birthday' string for display/backup.
    final parsed = _parseBirthday(value);
    if (parsed != null) {
      BrazeService.setDateOfBirth(parsed.$1, parsed.$2, parsed.$3);
    }
    BrazeService.setUserAttribute('birthday', value);
  }

  /// Parses birthday string to (year, month, day) for Braze setDateOfBirth. Returns null if unparseable.
  static (int, int, int)? _parseBirthday(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final dt = DateTime.tryParse(trimmed);
    if (dt != null) return (dt.year, dt.month, dt.day);
    // Try yyyy-MM-dd explicitly
    final parts = trimmed.split(RegExp(r'[-/.\s]'));
    if (parts.length >= 3) {
      final y = int.tryParse(parts[0]);
      var m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null && y > 1900 && y < 2100 && m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        return (y, m, d);
      }
      // month might be in second position (US format)
      final m2 = int.tryParse(parts[0]);
      final d2 = int.tryParse(parts[1]);
      final y2 = int.tryParse(parts[2]);
      if (y2 != null && m2 != null && d2 != null && y2 > 1900 && y2 < 2100 && m2 >= 1 && m2 <= 12 && d2 >= 1 && d2 <= 31) {
        return (y2, m2, d2);
      }
    }
    return null;
  }

  static void setHasPayment(bool value) {
    BrazeService.setUserAttribute('has_payment', value);
  }

  /// Descriptive store for Braze (e.g. "VGB Downtown — 123 Main Street" or "120 Grand").
  static void setFavoriteStoreDescription(String? description) {
    if (description != null && description.isNotEmpty) {
      BrazeService.setUserAttribute('favorite_store', description);
    }
  }

  static void setFavoriteBurger(String? itemName) {
    if (itemName != null && itemName.isNotEmpty) {
      BrazeService.setUserAttribute('favorite_burger', itemName);
    }
  }

  static void setFavoriteDrink(String? itemName) {
    if (itemName != null && itemName.isNotEmpty) {
      BrazeService.setUserAttribute('favorite_drink', itemName);
    }
  }

  static void setFavoriteCombo(String? itemName) {
    if (itemName != null && itemName.isNotEmpty) {
      BrazeService.setUserAttribute('favorite_combo', itemName);
    }
  }

  static void setFavoriteDessert(String? itemName) {
    if (itemName != null && itemName.isNotEmpty) {
      BrazeService.setUserAttribute('favorite_dessert', itemName);
    }
  }

  static void setTotalEarnedRewards(int value) {
    BrazeService.setUserAttribute('total_earned_rewards', value);
  }

  static void setTotalRedeemedRewards(int value) {
    BrazeService.setUserAttribute('total_redeemed_rewards', value);
  }

  static void setTotalCouponsRedeemed(int value) {
    BrazeService.setUserAttribute('total_coupons_redeemed', value);
  }

  /// Braze allows at most 2 decimals for numeric attributes.
  static void setAverageCartValue(double value) {
    final rounded = _roundTo2Decimals(value);
    BrazeService.setUserAttribute('average_cart_value', rounded);
  }

  static double _roundTo2Decimals(double value) {
    return (value * 100).round() / 100;
  }

  /// When user updates profile photo, set Braze custom attribute to a public URL if you have one.
  /// App stores only a local filename; to sync to Braze you need to upload the image and pass the URL here.
  static void setProfileImageUrl(String? url) {
    BrazeService.setUserAttribute('profile_image_url', url);
  }

  // --- Custom events (SENT) ---
  /// product_id sent as productName so Braze shows marketer-friendly name (not b1); product_sku = internal id.
  static void trackAddToCart({
    required String productId,
    required String productName,
    required String productCategory,
    required double basePrice,
    required int quantity,
    required List<String> customizations,
    required double customizationTotal,
    required double totalPrice,
  }) {
    BrazeService.logCustomEvent('add_to_cart', {
      'product_id': productName,
      'product_sku': productId,
      'product_name': productName,
      'product_category': productCategory,
      'base_price': _roundTo2Decimals(basePrice),
      'quantity': quantity,
      'customizations': customizations,
      'customization_total': _roundTo2Decimals(customizationTotal),
      'total_price': _roundTo2Decimals(totalPrice),
    });
  }

  static void trackUpdateCartQuantity({
    required String productId,
    required String productName,
    required int oldQuantity,
    required int newQuantity,
  }) {
    BrazeService.logCustomEvent('update_cart_quantity', {
      'product_id': productName,
      'product_sku': productId,
      'product_name': productName,
      'old_quantity': oldQuantity,
      'new_quantity': newQuantity,
    });
  }

  // remove_from_cart: NOT SENT — no-op
  static void trackRemoveFromCart({required String productId, required String productName, required int quantity, required double totalPrice}) {}

  // product_viewed: NOT SENT — no-op
  static void trackProductViewed({required String productId, required String productName, required String productCategory, required double price}) {}

  // category_viewed: NOT SENT — no-op
  static void trackCategoryViewed(String category) {}

  static void trackStoreSelected({required String storeId, required String storeName, required String storeDistance}) {
    BrazeService.logCustomEvent('store_selected', {
      'store_id': storeId,
      'store_name': storeName,
      'store_distance': storeDistance,
    });
  }

  // tab_viewed: NOT SENT — no-op
  static void trackTabViewed(String tabName) {}

  static void trackOrderCompleted({
    required String orderId,
    required double subtotal,
    required double tax,
    required double total,
    required int itemsCount,
    required int uniqueItems,
    required String storeId,
    required String storeName,
    required String pickupTime,
    required bool rewardRedeemed,
    required double rewardDiscount,
    required double couponDiscount,
    required int pointsEarned,
    required String paymentMethod,
  }) {
    BrazeService.logCustomEvent('order_completed', {
      'order_id': orderId,
      'subtotal': _roundTo2Decimals(subtotal),
      'tax': _roundTo2Decimals(tax),
      'total': _roundTo2Decimals(total),
      'items_count': itemsCount,
      'unique_items': uniqueItems,
      'store_id': storeId,
      'store_name': storeName,
      'pickup_time': pickupTime,
      'reward_redeemed': rewardRedeemed,
      'reward_discount': _roundTo2Decimals(rewardDiscount),
      'coupon_discount': _roundTo2Decimals(couponDiscount),
      'points_earned': pointsEarned,
      'payment_method': paymentMethod,
    });
  }

  static void trackRewardRedeemed({required String orderId}) {
    BrazeService.logCustomEvent('reward_redeemed', {'order_id': orderId});
  }

  static void trackLoyaltyPointEarned({
    required int pointsEarned,
    required int newTotal,
    required String orderId,
    required double qualifyingAmount,
  }) {
    BrazeService.logCustomEvent('loyalty_point_earned', {
      'points_earned': pointsEarned,
      'new_total': newTotal,
      'order_id': orderId,
      'qualifying_amount': _roundTo2Decimals(qualifyingAmount),
    });
  }

  // profile_updated: NOT SENT — no-op
  static void trackProfileUpdated(List<String> updatedFields) {}

  static void trackPaymentMethodPrimaryChanged(String paymentMethodId) {
    BrazeService.logCustomEvent('payment_method_primary_changed', {'id': paymentMethodId});
  }

  static void trackNotificationPreferenceChanged({required String type, required bool enabled}) {
    BrazeService.logCustomEvent('notification_preference_changed', {'type': type, 'enabled': enabled});
  }

  static void trackLTOCouponRedeemed() {
    BrazeService.logCustomEvent('LTO coupon redeemed', {});
  }

  // --- Purchase events (SENT) ---
  /// Sends product_id as human-readable name (e.g. "Classic Smash") so Braze shows clear names for marketers.
  /// Internal id is in product_sku for reporting/debugging.
  static void trackPurchases(Order order) {
    for (final item in order.items) {
      BrazeService.logPurchase(
        item.item.name, // product_id: marketer-friendly name, not internal id (e.g. b1)
        _roundTo2Decimals(item.totalPrice),
        'USD',
        item.quantity,
        {
          'product_sku': item.item.id,
          'product_name': item.item.name,
          'product_category': item.item.category,
          'customizations': item.customizations.map((c) => c.name).toList(),
          'order_id': order.id,
          'store_id': order.store.id,
          'store_name': order.store.name,
        },
      );
    }
  }

  // --- Subscription groups (messaging preferences) — map app toggles to Braze ---
  static void setPushSubscription(bool subscribed) {
    BrazeService.setPushSubscription(subscribed);
  }

  static void setEmailSubscription(bool subscribed) {
    BrazeService.setEmailSubscription(subscribed);
  }

  static void setSMSSubscription(bool subscribed) {
    BrazeService.setSMSSubscription(subscribed);
  }
}
