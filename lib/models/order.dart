import 'package:very_good_burgers/models/cart_item.dart';
import 'package:very_good_burgers/models/store.dart';

/// A completed order.
class Order {
  const Order({
    required this.id,
    required this.store,
    required this.pickupTime,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.rewardDiscount = 0,
    this.couponDiscount = 0,
    this.pointsEarned = 0,
    required this.createdAt,
  });

  final String id;
  final Store store;
  final String pickupTime;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final double rewardDiscount;
  final double couponDiscount;
  final int pointsEarned;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'store': store.toJson(),
        'pickupTime': pickupTime,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'rewardDiscount': rewardDiscount,
        'couponDiscount': couponDiscount,
        'pointsEarned': pointsEarned,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        store: Store.fromJson(json['store'] as Map<String, dynamic>),
        pickupTime: json['pickupTime'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal: (json['subtotal'] as num).toDouble(),
        tax: (json['tax'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        rewardDiscount: (json['rewardDiscount'] as num?)?.toDouble() ?? 0,
        couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0,
        pointsEarned: json['pointsEarned'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
