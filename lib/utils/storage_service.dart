import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/store.dart';
import '../models/user.dart';

/// Persists app state with SharedPreferences.
class StorageService {
  StorageService._();
  static late SharedPreferences _prefs;
  static bool _initialized = false;

  static const _keyCart = 'cart';
  static const _keyLoyaltyPoints = 'loyalty_points';
  static const _keyUser = 'user';
  static const _keySelectedStore = 'selected_store';
  static const _keyPickupTime = 'pickup_time';
  static const _keyOrderHistory = 'order_history';

  static Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  static List<CartItem> getCart() {
    final json = _prefs.getString(_keyCart);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCart(List<CartItem> items) async {
    final list = items.map((e) => e.toJson()).toList();
    await _prefs.setString(_keyCart, jsonEncode(list));
  }

  static int getLoyaltyPoints() {
    return _prefs.getInt(_keyLoyaltyPoints) ?? 7;
  }

  static Future<void> saveLoyaltyPoints(int points) async {
    await _prefs.setInt(_keyLoyaltyPoints, points);
  }

  static User? getUser() {
    final json = _prefs.getString(_keyUser);
    if (json == null) return null;
    try {
      return User.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUser(User user) async {
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static Store? getSelectedStore() {
    final json = _prefs.getString(_keySelectedStore);
    if (json == null) return null;
    try {
      return Store.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSelectedStore(Store store) async {
    await _prefs.setString(_keySelectedStore, jsonEncode(store.toJson()));
  }

  static String getPickupTime() {
    return _prefs.getString(_keyPickupTime) ?? 'asap';
  }

  static Future<void> savePickupTime(String value) async {
    await _prefs.setString(_keyPickupTime, value);
  }

  static List<Order> getOrderHistory() {
    final json = _prefs.getString(_keyOrderHistory);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveOrderHistory(List<Order> orders) async {
    final list = orders.map((e) => e.toJson()).toList();
    await _prefs.setString(_keyOrderHistory, jsonEncode(list));
  }
}
