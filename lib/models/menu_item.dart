/// A menu item (burger, side, drink, dessert, combo).
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.emoji,
    required this.calories,
    required this.category,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String emoji;
  final int calories;
  final String category;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'emoji': emoji,
        'calories': calories,
        'category': category,
      };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        emoji: json['emoji'] as String,
        calories: json['calories'] as int,
        category: json['category'] as String,
      );
}
