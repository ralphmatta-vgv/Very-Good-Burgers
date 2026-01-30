/// A menu item customization option (e.g. extra cheese, no onions).
class Customization {
  const Customization({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };

  factory Customization.fromJson(Map<String, dynamic> json) => Customization(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
      );
}
