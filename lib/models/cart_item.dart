import 'package:very_good_burgers/models/customization.dart';
import 'package:very_good_burgers/models/menu_item.dart';

/// A line item in the cart (menu item + customizations + quantity).
class CartItem {
  CartItem({
    required this.id,
    required this.item,
    List<Customization>? customizations,
    this.quantity = 1,
  }) : customizations = customizations ?? [];

  final String id;
  final MenuItem item;
  final List<Customization> customizations;
  int quantity;

  double get customizationTotal =>
      customizations.fold(0.0, (sum, c) => sum + c.price);

  double get unitPrice => item.price + customizationTotal;

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'item': item.toJson(),
        'customizations': customizations.map((e) => e.toJson()).toList(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final item = MenuItem.fromJson(json['item'] as Map<String, dynamic>);
    final customizations = (json['customizations'] as List<dynamic>?)
            ?.map((e) => Customization.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return CartItem(
      id: json['id'] as String,
      item: item,
      customizations: customizations,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}
