import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'cart_item.dart';
import 'cart_service.dart';

class CartPage extends StatefulWidget {
  final String email;

  const CartPage({
    super.key,
    required this.email,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool loading = true;
  bool checkoutLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // =========================================================
  // LOAD CART
  // =========================================================

  Future<void> _loadCart() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      await CartService.load(widget.email);

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        errorMessage = 'Failed to load cart: $e';
      });
    }
  }

  // =========================================================
  // REMOVE ITEM
  // =========================================================

  Future<void> _removeItem(CartItem item) async {
    try {
      await CartService.remove(
        widget.email,
        item.food,
      );

      if (!mounted) {
        return;
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.food.name} removed from cart',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove item: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // INCREASE QUANTITY
  // =========================================================

  Future<void> _increaseQuantity(CartItem item) async {
    try {
      await CartService.increase(
        widget.email,
        item,
      );

      if (!mounted) {
        return;
      }

      setState(() {});
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to increase quantity: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // DECREASE QUANTITY
  // =========================================================

  Future<void> _decreaseQuantity(CartItem item) async {
    try {
      await CartService.decrease(
        widget.email,
        item,
      );

      if (!mounted) {
        return;
      }

      setState(() {});
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to decrease quantity: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // CLEAR CART
  // =========================================================

  Future<void> _clearCart() async {
    if (CartService.items.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear cart?'),
          content: const Text(
            'Are you sure you want to remove all items?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await CartService.clear(widget.email);

      if (!mounted) {
        return;
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart cleared'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to clear cart: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // CHECKOUT
  // =========================================================

  Future<void> _checkout() async {
    if (checkoutLoading) {
      return;
    }

    if (CartService.items.isEmpty) {
      return;
    }

    setState(() {
      checkoutLoading = true;
    });

    try {
      final order = await ApiService.checkout(
        widget.email,
      );

      /*
       * The backend checkout endpoint:
       *
       * 1. Reads cart items
       * 2. Creates an order
       * 3. Creates order items
       * 4. Saves the order
       * 5. Clears the cart
       */

      if (!mounted) {
        return;
      }

      await CartService.load(widget.email);

      if (!mounted) {
        return;
      }

      setState(() {
        checkoutLoading = false;
      });

      final orderId = order['id'];

      final total = order['total'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order #$orderId placed successfully. '
            'Total: ₹$total',
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        checkoutLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Checkout failed: $e',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final items = CartService.items;
    final total = CartService.total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep,
              ),
              tooltip: 'Clear cart',
              onPressed:
                  checkoutLoading ? null : _clearCart,
            ),
        ],
      ),
      body: _buildBody(
        items,
        total,
      ),
    );
  }

  // =========================================================
  // BODY
  // =========================================================

  Widget _buildBody(
    List<CartItem> items,
    double total,
  ) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),

              const SizedBox(height: 16),

              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed:
                    checkoutLoading ? null : _loadCart,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey,
            ),

            SizedBox(height: 16),

            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Add some food to your cart',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // =====================================================
        // CART ITEMS
        // =====================================================

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final food = item.food;

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // =================================================
                      // FOOD DETAILS
                      // =================================================

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              food.name,

                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              '₹${food.price.toStringAsFixed(2)} each',

                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              '₹${item.total.toStringAsFixed(2)}',

                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // =================================================
                      // CONTROLS
                      // =================================================

                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed:
                                checkoutLoading
                                    ? null
                                    : () {
                                        _removeItem(item);
                                      },
                          ),

                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Colors.grey.shade400,
                              ),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),

                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min,

                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    size: 18,
                                  ),
                                  onPressed:
                                      checkoutLoading
                                          ? null
                                          : () {
                                              _decreaseQuantity(
                                                item,
                                              );
                                            },
                                ),

                                Text(
                                  '${item.quantity}',

                                  style:
                                      const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    size: 18,
                                  ),
                                  onPressed:
                                      checkoutLoading
                                          ? null
                                          : () {
                                              _increaseQuantity(
                                                item,
                                              );
                                            },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // =========================================================
        // TOTAL + CHECKOUT
        // =========================================================

        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      'Total',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      '₹${total.toStringAsFixed(2)}',

                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed:
                        checkoutLoading
                            ? null
                            : _checkout,

                    child: Padding(
                      padding:
                          const EdgeInsets.all(14),

                      child: checkoutLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
