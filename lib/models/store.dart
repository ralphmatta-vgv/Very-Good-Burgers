/// A VGB store location.
class Store {
  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.distance,
    required this.hours,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String distance;
  final String hours;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'city': city,
        'distance': distance,
        'hours': hours,
      };

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        city: json['city'] as String,
        distance: json['distance'] as String,
        hours: json['hours'] as String,
      );
}
