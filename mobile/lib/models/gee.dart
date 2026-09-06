class Gee {
  final int id;
  final String name;
  final String description;
  final double price;

  Gee({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Gee.fromJson(Map<String, dynamic> json) {
    return Gee(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
