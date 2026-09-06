import '../models/food.dart';
import '../services/api_service.dart';
import 'cart_item.dart';

class CartService {
  static final List<CartItem> _items = [];

  static List<CartItem> get items =>
      List.unmodifiable(_items);

  static int get itemCount {
    return _items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  static double get total {
    return _items.fold(
      0,
      (sum, item) => sum + item.total,
    );
  }

  static bool contains(Food food) {
    return _items.any(
      (item) => item.food.id == food.id,
    );
  }

  static CartItem? find(Food food) {
    for (final item in _items) {
      if (item.food.id == food.id) {
        return item;
      }
    }

    return null;
  }

  static Future<void> load(
    String email,
  ) async {
    final items = await ApiService.getCart(email);

    _items
      ..clear()
      ..addAll(items);
  }

  static Future<void> add(
    String email,
    Food food,
  ) async {
    final item = await ApiService.addToCart(
      email: email,
      foodId: food.id,
      quantity: 1,
    );

    final index = _items.indexWhere(
      (x) => x.food.id == food.id,
    );

    if (index >= 0) {
      _items[index] = item;
    } else {
      _items.add(item);
    }
  }

  static Future<void> increase(
    String email,
    CartItem item,
  ) async {
    final updated = await ApiService.updateCartQuantity(
      email: email,
      foodId: item.food.id,
      quantity: item.quantity + 1,
    );

    final index = _items.indexWhere(
      (x) => x.food.id == item.food.id,
    );

    if (index >= 0) {
      _items[index] = updated;
    }
  }

  static Future<void> decrease(
    String email,
    CartItem item,
  ) async {
    final newQuantity = item.quantity - 1;

    if (newQuantity <= 0) {
      await remove(email, item.food);
      return;
    }

    final updated = await ApiService.updateCartQuantity(
      email: email,
      foodId: item.food.id,
      quantity: newQuantity,
    );

    final index = _items.indexWhere(
      (x) => x.food.id == item.food.id,
    );

    if (index >= 0) {
      _items[index] = updated;
    }
  }

  static Future<void> remove(
    String email,
    Food food,
  ) async {
    await ApiService.removeFromCart(
      email: email,
      foodId: food.id,
    );

    _items.removeWhere(
      (item) => item.food.id == food.id,
    );
  }

  static Future<void> clear(
    String email,
  ) async {
    await ApiService.clearCart(email);

    _items.clear();
  }
}
