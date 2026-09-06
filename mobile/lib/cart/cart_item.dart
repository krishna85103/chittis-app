import '../models/food.dart';

class CartItem {
  final int id;
  final String email;
  final Food food;
  int quantity;

  CartItem({
    required this.id,
    required this.email,
    required this.food,
    required this.quantity,
  });

  factory CartItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return CartItem(
      id: (json['id'] as num).toInt(),
      email: json['email']?.toString() ?? '',
      food: Food.fromJson(
        Map<String, dynamic>.from(
          json['food'],
        ),
      ),
      quantity: (json['quantity'] as num).toInt(),
    );
  }

  double get total {
    return food.price * quantity;
  }
}
