import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/food.dart';
import '../cart/cart_item.dart';

class ApiService {
  // =========================================================
  // LOGIN
  // =========================================================

  static Future<ApiResponse> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse(ApiConfig.loginUrl);

    debugPrint('========================================');
    debugPrint('LOGIN REQUEST');
    debugPrint('URL: $url');
    debugPrint('EMAIL: $email');
    debugPrint('========================================');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('LOGIN STATUS: ${response.statusCode}');
      debugPrint('LOGIN BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Login failed: HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid login response format: expected JSON object',
        );
      }

      return ApiResponse.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('LOGIN ERROR: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  // =========================================================
  // TAB 1
  // =========================================================

  static Future<ApiResponse> getTab1() async {
    return _get(ApiConfig.tab1Url);
  }

  // =========================================================
  // FOOD
  // =========================================================

  static Future<List<Food>> getFood({
    int page = 0,
    int size = 20,
  }) async {
    return _getProducts(
      ApiConfig.tab1FoodUrl,
      page: page,
      size: size,
      endpointName: 'FOOD',
    );
  }

  // =========================================================
  // GEE
  // =========================================================

  static Future<List<Food>> getGee({
    int page = 0,
    int size = 20,
  }) async {
    return _getProducts(
      ApiConfig.tab1GeeUrl,
      page: page,
      size: size,
      endpointName: 'GEE',
    );
  }

  // =========================================================
  // NUTS
  // =========================================================

  static Future<List<Food>> getNuts({
    int page = 0,
    int size = 20,
  }) async {
    return _getProducts(
      ApiConfig.tab1NutsUrl,
      page: page,
      size: size,
      endpointName: 'NUTS',
    );
  }

  // =========================================================
  // UPDATE FOOD
  // =========================================================

  static Future<Food> updateFood(
    int id,
    String name,
    String description,
    double price,
  ) async {
    return _updateProduct(
      ApiConfig.tab1FoodUrl,
      id,
      name,
      description,
      price,
      endpointName: 'FOOD',
    );
  }

  // =========================================================
  // UPDATE GEE
  // =========================================================

  static Future<Food> updateGee(
    int id,
    String name,
    String description,
    double price,
  ) async {
    return _updateProduct(
      ApiConfig.tab1GeeUrl,
      id,
      name,
      description,
      price,
      endpointName: 'GEE',
    );
  }

  // =========================================================
  // UPDATE NUTS
  // =========================================================

  static Future<Food> updateNuts(
    int id,
    String name,
    String description,
    double price,
  ) async {
    return _updateProduct(
      ApiConfig.tab1NutsUrl,
      id,
      name,
      description,
      price,
      endpointName: 'NUTS',
    );
  }

  // =========================================================
  // COMMON PRODUCT GET
  // =========================================================

  static Future<List<Food>> _getProducts(
    String baseUrl, {
    required int page,
    required int size,
    required String endpointName,
  }) async {
    final url = Uri.parse(baseUrl).replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    debugPrint('========================================');
    debugPrint('GET $endpointName');
    debugPrint('PAGE: $page');
    debugPrint('SIZE: $size');
    debugPrint('URL: $url');
    debugPrint('========================================');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'GET $endpointName STATUS: ${response.statusCode}',
      );
      debugPrint(
        'GET $endpointName BODY: ${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load $endpointName: '
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception(
          'Invalid $endpointName response: expected JSON array, '
          'received ${decoded.runtimeType}',
        );
      }

      final products = decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception(
            'Invalid $endpointName item: expected JSON object',
          );
        }

        return Food.fromJson(item);
      }).toList();

      debugPrint(
        'GET $endpointName SUCCESS: '
        'page=$page, size=$size, '
        '${products.length} item(s)',
      );

      for (final product in products) {
        debugPrint(
          '  id=${product.id}, '
          'name=${product.name}, '
          'price=${product.price}',
        );
      }

      return products;
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('GET $endpointName ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('========================================');

      rethrow;
    }
  }

  // =========================================================
  // COMMON PRODUCT UPDATE
  // =========================================================

  static Future<Food> _updateProduct(
    String baseUrl,
    int id,
    String name,
    String description,
    double price, {
    required String endpointName,
  }) async {
    final url = Uri.parse('$baseUrl/$id');

    debugPrint('========================================');
    debugPrint('UPDATE $endpointName');
    debugPrint('URL: $url');
    debugPrint('ID: $id');
    debugPrint('NAME: $name');
    debugPrint('DESCRIPTION: $description');
    debugPrint('PRICE: $price');
    debugPrint('========================================');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
        }),
      );

      debugPrint(
        'UPDATE $endpointName STATUS: ${response.statusCode}',
      );

      debugPrint(
        'UPDATE $endpointName BODY: ${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update $endpointName: '
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid update response: expected JSON object',
        );
      }

      return Food.fromJson(decoded);
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('UPDATE $endpointName ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('========================================');

      rethrow;
    }
  }

  // =========================================================
  // CART - GET
  // =========================================================

  static Future<List<CartItem>> getCart(
    String email,
  ) async {
    final url = Uri.parse(
      ApiConfig.baseUrl,
    ).replace(
      path: '/api/cart',
      queryParameters: {
        'email': email,
      },
    );

    debugPrint('========================================');
    debugPrint('GET CART');
    debugPrint('URL: $url');
    debugPrint('EMAIL: $email');
    debugPrint('========================================');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'GET CART STATUS: ${response.statusCode}',
      );
      debugPrint(
        'GET CART BODY: ${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load cart: '
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception(
          'Invalid cart response: expected JSON array',
        );
      }

      return decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception(
            'Invalid cart item: expected JSON object',
          );
        }

        return CartItem.fromJson(item);
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('GET CART ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('========================================');

      rethrow;
    }
  }

  // =========================================================
  // CART - ADD
  // =========================================================

  static Future<CartItem> addToCart({
    required String email,
    required int foodId,
    int quantity = 1,
  }) async {
    final url = Uri.parse(
      ApiConfig.baseUrl,
    ).replace(
      path: '/api/cart',
      queryParameters: {
        'email': email,
        'foodId': foodId.toString(),
        'quantity': quantity.toString(),
      },
    );

    debugPrint('========================================');
    debugPrint('ADD TO CART');
    debugPrint('URL: $url');
    debugPrint('EMAIL: $email');
    debugPrint('FOOD ID: $foodId');
    debugPrint('QUANTITY: $quantity');
    debugPrint('========================================');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'ADD TO CART STATUS: ${response.statusCode}',
      );
      debugPrint(
        'ADD TO CART BODY: ${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to add to cart: '
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid add-to-cart response: expected JSON object',
        );
      }

      return CartItem.fromJson(decoded);
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('ADD TO CART ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('========================================');

      rethrow;
    }
  }

  // =========================================================
  // CART - UPDATE QUANTITY
  // =========================================================

  static Future<CartItem> updateCartQuantity({
    required String email,
    required int foodId,
    required int quantity,
  }) async {
    final url = Uri.parse(
      ApiConfig.baseUrl,
    ).replace(
      path: '/api/cart',
      queryParameters: {
        'email': email,
        'foodId': foodId.toString(),
        'quantity': quantity.toString(),
      },
    );

    debugPrint('========================================');
    debugPrint('UPDATE CART QUANTITY');
    debugPrint('URL: $url');
    debugPrint('EMAIL: $email');
    debugPrint('FOOD ID: $foodId');
    debugPrint('QUANTITY: $quantity');
    debugPrint('========================================');

    try {
      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'UPDATE CART STATUS: ${response.statusCode}',
      );
      debugPrint(
        'UPDATE CART BODY: ${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update cart: '
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid update-cart response: expected JSON object',
        );
      }

      return CartItem.fromJson(decoded);
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('UPDATE CART ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('========================================');

      rethrow;
    }
  }

  // =========================================================
  // CART - REMOVE ITEM
  // =========================================================

  static Future<void> removeFromCart({
    required String email,
    required int foodId,
  }) async {
    final url = Uri.parse(
      ApiConfig.baseUrl,
    ).replace(
      path: '/api/cart',
      queryParameters: {
        'email': email,
        'foodId': foodId.toString(),
      },
    );

    debugPrint('========================================');
    debugPrint('REMOVE FROM CART');
    debugPrint('URL: $url');
    debugPrint('EMAIL: $email');
    debugPrint('FOOD ID: $foodId');
    debugPrint('========================================');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'REMOVE CART STATUS: ${response.statusCode}',
      );
      debugPrint(
        'REMOVE CART BODY: ${response.body}',
      );

      if (response.statusCode != 204 &&
          response.statusCode != 200) {
        throw Exception(
          'Failed to remove cart item: '
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('REMOVE CART ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('========================================');

      rethrow;
    }
  }

  // =========================================================
  // CART - CLEAR
  // =========================================================

  static Future<void> clearCart(
    String email,
  ) async {
    final url = Uri.parse(
      ApiConfig.baseUrl,
    ).replace(
      path: '/api/cart/clear',
      queryParameters: {
        'email': email,
      },
    );

    debugPrint('========================================');
    debugPrint('CLEAR CART');
    debugPrint('URL: $url');
    debugPrint('EMAIL: $email');
    debugPrint('========================================');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'CLEAR CART STATUS: ${response.statusCode}',
      );
      debugPrint(
        'CLEAR CART BODY: ${response.body}',
      );

      if (response.statusCode != 204 &&
          response.statusCode != 200) {
        throw Exception(
          'Failed to clear cart: '
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('CLEAR CART ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('========================================');

      rethrow;
    }
  }

  // =========================================================
  // TAB 2
  // =========================================================

  static Future<ApiResponse> getTab2() async {
    return _get(ApiConfig.tab2Url);
  }

  // =========================================================
  // TAB 3
  // =========================================================

  static Future<ApiResponse> getTab3() async {
    return _get(ApiConfig.tab3Url);
  }

  // =========================================================
  // COMMON GET
  // =========================================================

  static Future<ApiResponse> _get(String url) async {
    final uri = Uri.parse(url);

    debugPrint('========================================');
    debugPrint('GET REQUEST');
    debugPrint('URL: $uri');
    debugPrint('========================================');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint('GET STATUS: ${response.statusCode}');
      debugPrint('GET BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Request failed: '
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid API response: expected JSON object',
        );
      }

      return ApiResponse.fromJson(data);
    } catch (e, stackTrace) {
      debugPrint('GET ERROR: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }
}
