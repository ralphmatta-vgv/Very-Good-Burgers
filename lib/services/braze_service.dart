import 'dart:convert';

import 'package:braze_plugin/braze_plugin.dart';

/// Braze SDK integration. Set plugin in main (after Braze is inited in iOS/Android) to enable real SDK.
class BrazeService {
  static bool _initialized = false;
  static BrazePlugin? _plugin;

  /// Messages that arrived before the UI subscribed (e.g. session-start). Drained when handler mounts.
  static final List<BrazeInAppMessage> _pendingInAppMessages = [];
  static bool _inAppMessageHandlerMounted = false;

  static void setPlugin(BrazePlugin? plugin) {
    _plugin = plugin;
  }

  /// Use for in-app message subscription (display) and other stream-based features.
  static BrazePlugin? get plugin => _plugin;

  /// Call when the in-app message UI handler mounts/unmounts so we only buffer until then.
  static void setInAppMessageHandlerMounted(bool mounted) {
    _inAppMessageHandlerMounted = mounted;
  }

  /// Call from main() when creating the plugin so we capture messages immediately (e.g. session start).
  static void onInAppMessageFromNative(BrazeInAppMessage message) {
    if (!_inAppMessageHandlerMounted) _pendingInAppMessages.add(message);
  }

  /// Drains and clears pending messages so the UI can show them. Call when handler mounts.
  static List<BrazeInAppMessage> drainPendingInAppMessages() {
    final list = List<BrazeInAppMessage>.from(_pendingInAppMessages);
    _pendingInAppMessages.clear();
    return list;
  }

  static void setInitialized(bool value) {
    _initialized = value;
  }

  static bool get isActive => _initialized && _plugin != null;

  static void logCustomEvent(String eventName, Map<String, dynamic> properties) {
    if (isActive) {
      if (properties.isEmpty) {
        _plugin!.logCustomEvent(eventName);
      } else {
        _plugin!.logCustomEventWithProperties(eventName, properties);
      }
      return;
    }
    print('📊 BRAZE EVENT: $eventName');
    print(jsonEncode(properties));
  }

  static void logPurchase(
    String productId,
    double price,
    String currency,
    int quantity,
    Map<String, dynamic> properties,
  ) {
    if (isActive) {
      if (properties.isEmpty) {
        _plugin!.logPurchase(productId, currency, price, quantity);
      } else {
        _plugin!.logPurchaseWithProperties(productId, currency, price, quantity, properties);
      }
      return;
    }
    print('💰 BRAZE PURCHASE: $productId - \$$price x $quantity');
    print(jsonEncode(properties));
  }

  static void setUserAttribute(String key, dynamic value) {
    if (isActive) {
      if (value == null) {
        _plugin!.unsetCustomUserAttribute(key);
        return;
      }
      if (value is int) {
        _plugin!.setIntCustomUserAttribute(key, value);
        return;
      }
      if (value is double) {
        _plugin!.setDoubleCustomUserAttribute(key, value);
        return;
      }
      if (value is bool) {
        _plugin!.setBoolCustomUserAttribute(key, value);
        return;
      }
      _plugin!.setStringCustomUserAttribute(key, value.toString());
      return;
    }
    print('👤 BRAZE ATTRIBUTE: $key = $value');
  }

  static void changeUser(String userId) {
    if (isActive) {
      _plugin!.changeUser(userId);
      return;
    }
    print('🔑 BRAZE USER: $userId');
  }

  /// Braze standard profile fields (show in main profile, used for messaging/deduplication).
  static void setFirstName(String? value) {
    if (isActive) {
      _plugin!.setFirstName(value);
      return;
    }
    print('👤 BRAZE first_name: $value');
  }

  static void setLastName(String? value) {
    if (isActive) {
      _plugin!.setLastName(value);
      return;
    }
    print('👤 BRAZE last_name: $value');
  }

  static void setEmail(String? value) {
    if (isActive) {
      _plugin!.setEmail(value);
      return;
    }
    print('👤 BRAZE email: $value');
  }

  static void setPhoneNumber(String? value) {
    if (isActive) {
      _plugin!.setPhoneNumber(value);
      return;
    }
    print('👤 BRAZE phone: $value');
  }

  /// year, month, day (1-based month).
  static void setDateOfBirth(int year, int month, int day) {
    if (isActive) {
      _plugin!.setDateOfBirth(year, month, day);
      return;
    }
    print('👤 BRAZE date_of_birth: $year-$month-$day');
  }

  static void setPushSubscription(bool subscribed) {
    if (isActive) {
      _plugin!.setPushNotificationSubscriptionType(
        subscribed ? SubscriptionType.subscribed : SubscriptionType.unsubscribed,
      );
      return;
    }
    print('🔔 BRAZE SUBSCRIPTION: push = $subscribed');
  }

  static void setEmailSubscription(bool subscribed) {
    if (isActive) {
      _plugin!.setEmailNotificationSubscriptionType(
        subscribed ? SubscriptionType.subscribed : SubscriptionType.unsubscribed,
      );
      return;
    }
    print('📧 BRAZE SUBSCRIPTION: email = $subscribed');
  }

  static void setSMSSubscription(bool subscribed) {
    // braze_plugin has no setSmsSubscriptionType; use subscription groups or leave as console log
    print('💬 BRAZE SUBSCRIPTION: sms = $subscribed');
  }

  /// Request a refresh of content cards from Braze (results come via content cards stream).
  static void requestContentCardsRefresh() {
    if (isActive) _plugin!.requestContentCardsRefresh();
  }

  /// Cached content cards for immediate display (e.g. on app launch).
  static Future<List<BrazeContentCard>> getCachedContentCards() async {
    if (!isActive) return [];
    return _plugin!.getCachedContentCards();
  }

  static void logContentCardImpression(BrazeContentCard card) {
    if (isActive) _plugin!.logContentCardImpression(card);
  }

  static void logContentCardClicked(BrazeContentCard card) {
    if (isActive) _plugin!.logContentCardClicked(card);
  }
}
