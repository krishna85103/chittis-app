class Food {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,

      // Spring Boot normally serializes imageUrl
      // because the Java field is called imageUrl.
      //
      // image_url is also accepted just in case
      // your backend returns snake_case.
      imageUrl: (
        json['imageUrl'] ??
        json['image_url']
      )?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
