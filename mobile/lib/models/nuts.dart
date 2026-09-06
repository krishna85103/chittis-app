class Nuts {
  final int id;
  final String name;
  final String description;
  final double price;

  Nuts({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Nuts.fromJson(Map<String, dynamic> json) {
    return Nuts(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
