import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../cart/cart_page.dart';
import '../../../cart/cart_service.dart';
import '../../../cart/cart_item.dart';
import '../../../models/food.dart';
import '../../../services/api_service.dart';
import '../../../config/api_config.dart';

class FoodPage extends StatefulWidget {
  final String email;
  final bool isAdmin;

  const FoodPage({
    super.key,
    required this.email,
    this.isAdmin = false,
  });

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  final List<Food> _foods = [];

  static const int _pageSize = 20;

  int _currentPage = 0;

  bool _isLoading = false;
  bool _hasMore = true;
  bool _cartLoading = true;

  String? _error;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    _loadCart();
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  // =========================================================
  // CART
  // =========================================================

  Future<void> _loadCart() async {
    if (widget.isAdmin) {
      if (!mounted) return;

      setState(() {
        _cartLoading = false;
      });

      return;
    }

    try {
      await CartService.load(widget.email);

      if (!mounted) return;

      setState(() {
        _cartLoading = false;
      });
    } catch (e) {
      debugPrint('Cart load error: $e');

      if (!mounted) return;

      setState(() {
        _cartLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // LOAD FIRST PAGE
  // =========================================================

  Future<void> _loadFirstPage() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _foods.clear();
        _currentPage = 0;
        _hasMore = true;
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final foods = await ApiService.getFood(
        page: 0,
        size: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _foods.clear();
        _foods.addAll(foods);

        _currentPage = 0;
        _isLoading = false;

        _hasMore = foods.length >= _pageSize;
      });
    } catch (e) {
      debugPrint('Food load error: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // =========================================================
  // LOAD NEXT PAGE
  // =========================================================

  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) return;

    final nextPage = _currentPage + 1;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final foods = await ApiService.getFood(
        page: nextPage,
        size: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _foods.addAll(foods);

        _currentPage = nextPage;

        _isLoading = false;

        _hasMore = foods.length >= _pageSize;
      });
    } catch (e) {
      debugPrint('Next food page error: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load more food: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // SCROLL
  // =========================================================

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_isLoading || !_hasMore) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadNextPage();
    }
  }

  // =========================================================
  // IMAGE URL
  // =========================================================

  String _imageUrl(String imageUrl) {
    final value = imageUrl.trim();

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${ApiConfig.baseUrl}$value';
    }

    return '${ApiConfig.baseUrl}/$value';
  }

  // =========================================================
  // FOOD IMAGE
  // =========================================================

  Widget _buildFoodImage(Food food) {
    final imageUrl = food.imageUrl;

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.fastfood,
          size: 40,
          color: Colors.grey,
        ),
      );
    }

    final fullUrl = _imageUrl(imageUrl);

    debugPrint('========================================');
    debugPrint('FOOD IMAGE');
    debugPrint('Food: ${food.name}');
    debugPrint('Original URL: $imageUrl');
    debugPrint('Full URL: $fullUrl');
    debugPrint('========================================');

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        fullUrl,
        width: 90,
        height: 90,
        fit: BoxFit.cover,

        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            width: 90,
            height: 90,
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },

        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          debugPrint('========================================');
          debugPrint('IMAGE LOAD ERROR');
          debugPrint('Food: ${food.name}');
          debugPrint('URL: $fullUrl');
          debugPrint('ERROR: $error');
          debugPrint('STACK: $stackTrace');
          debugPrint('========================================');

          return Container(
            width: 90,
            height: 90,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.broken_image,
              size: 40,
              color: Colors.red,
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // EDIT FOOD
  // =========================================================

  Future<void> _editFood(Food food) async {
    final priceController = TextEditingController(
      text: food.price.toStringAsFixed(2),
    );

    File? selectedImage;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            BuildContext dialogContext,
            StateSetter setDialogState,
          ) {
            return AlertDialog(
              title: Text('Edit ${food.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // =====================================================
                    // IMAGE PREVIEW
                    // =====================================================

                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: selectedImage != null
                          ? Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : food.imageUrl != null &&
                                  food.imageUrl!.trim().isNotEmpty
                              ? Image.network(
                                  _imageUrl(food.imageUrl!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    debugPrint(
                                      'EDIT IMAGE ERROR: '
                                      '${_imageUrl(food.imageUrl!)}',
                                    );

                                    return const Icon(
                                      Icons.broken_image,
                                      size: 60,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                    ),

                    const SizedBox(height: 15),

                    // =====================================================
                    // CHOOSE IMAGE
                    // =====================================================

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('Choose Image'),
                        onPressed: () async {
                          try {
                            final XFile? pickedFile =
                                await _imagePicker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );

                            if (pickedFile == null) {
                              return;
                            }

                            setDialogState(() {
                              selectedImage = File(
                                pickedFile.path,
                              );
                            });
                          } catch (e) {
                            debugPrint(
                              'Image picker error: $e',
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    // =====================================================
                    // PRICE
                    // =====================================================

                    TextField(
                      controller: priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
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
                    final price = double.tryParse(
                      priceController.text.trim(),
                    );

                    if (price == null || price < 0) {
                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter a valid price',
                          ),
                        ),
                      );

                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    final price = double.tryParse(
      priceController.text.trim(),
    );

    priceController.dispose();

    if (result != true || price == null) {
      return;
    }

    try {
      // =====================================================
      // UPDATE PRICE
      // =====================================================

      await ApiService.updateFood(
        food.id,
        food.name,
        food.description,
        price,
      );

      // =====================================================
      // UPLOAD IMAGE
      // =====================================================

      if (selectedImage != null) {
        await ApiService.uploadFoodImage(
          food.id,
          selectedImage!,
        );
      }

      // =====================================================
      // RELOAD
      // =====================================================

      await _loadFirstPage();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedImage != null
                ? 'Food updated with image'
                : 'Price updated successfully',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Food update error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update food: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // ADD TO CART
  // =========================================================

  Future<void> _addToCart(Food food) async {
    if (_cartLoading) return;

    try {
      await CartService.add(
        widget.email,
        food,
      );

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${food.name} added to cart',
          ),
          duration: const Duration(seconds: 1),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: _openCart,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add ${food.name}: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // INCREASE
  // =========================================================

  Future<void> _increaseQuantity(Food food) async {
    final CartItem? item = CartService.find(food);

    if (item == null) return;

    try {
      await CartService.increase(
        widget.email,
        item,
      );

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      if (!mounted) return;

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
  // DECREASE
  // =========================================================

  Future<void> _decreaseQuantity(Food food) async {
    final CartItem? item = CartService.find(food);

    if (item == null) return;

    try {
      await CartService.decrease(
        widget.email,
        item,
      );

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      if (!mounted) return;

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
  // OPEN CART
  // =========================================================

  Future<void> _openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(
          email: widget.email,
        ),
      ),
    );

    if (!mounted) return;

    try {
      await CartService.load(widget.email);
    } catch (e) {
      debugPrint(
        'Failed to reload cart: $e',
      );
    }

    if (!mounted) return;

    setState(() {});
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food'),

        actions: widget.isAdmin
            ? null
            : [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart,
                      ),
                      tooltip: 'Cart',
                      onPressed:
                          _cartLoading ? null : _openCart,
                    ),

                    if (CartService.itemCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          constraints:
                              const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration:
                              const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${CartService.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
      ),

      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: widget.isAdmin
                ? Colors.orange.shade50
                : Colors.red.shade50,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Logged in user',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (widget.isAdmin) ...[
                  const SizedBox(height: 5),

                  const Text(
                    'ADMIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: _buildFoodList(),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FOOD LIST
  // =========================================================

  Widget _buildFoodList() {
    if (_isLoading && _foods.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _foods.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),

              const SizedBox(height: 12),

              const Text(
                'Unable to load food',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _error!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: _loadFirstPage,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_foods.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadFirstPage,
        child: ListView(
          controller: _scrollController,
          children: const [
            SizedBox(height: 180),

            Center(
              child: Text(
                'No food available',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final showBottomLoader =
        _isLoading && _foods.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadFirstPage,

      child: ListView.builder(
        controller: _scrollController,

        physics:
            const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(16),

        itemCount:
            _foods.length +
            (showBottomLoader ? 1 : 0),

        itemBuilder: (context, index) {
          if (index == _foods.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final food = _foods[index];

          final CartItem? cartItem =
              CartService.find(food);

          final int cartQuantity =
              cartItem?.quantity ?? 0;

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
                  // =====================================================
                  // IMAGE
                  // =====================================================

                  _buildFoodImage(food),

                  const SizedBox(width: 12),

                  // =====================================================
                  // FOOD DETAILS
                  // =====================================================

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

                        const SizedBox(height: 8),

                        Text(
                          food.description,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          '₹${food.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),

                        if (!widget.isAdmin &&
                            cartQuantity > 0) ...[
                          const SizedBox(height: 6),

                          Text(
                            '$cartQuantity in cart',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // =====================================================
                  // ADMIN
                  // =====================================================

                  if (widget.isAdmin)
                    SizedBox(
                      width: 55,
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        tooltip:
                            'Edit price and image',
                        onPressed: () {
                          _editFood(food);
                        },
                      ),
                    )

                  // =====================================================
                  // CUSTOMER
                  // =====================================================

                  else
                    SizedBox(
                      width: 120,

                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [
                          if (_cartLoading)
                            const SizedBox(
                              height: 40,
                              child: Center(
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )

                          else if (cartQuantity == 0)
                            SizedBox(
                              width:
                                  double.infinity,
                              child:
                                  ElevatedButton.icon(
                                onPressed: () {
                                  _addToCart(food);
                                },
                                icon: const Icon(
                                  Icons
                                      .add_shopping_cart,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Add',
                                ),
                              ),
                            )

                          else
                            Container(
                              decoration:
                                  BoxDecoration(
                                border: Border.all(
                                  color: Colors
                                      .grey
                                      .shade400,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(8),
                              ),

                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,

                                children: [
                                  IconButton(
                                    padding:
                                        EdgeInsets.zero,

                                    constraints:
                                        const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),

                                    icon: const Icon(
                                      Icons.remove,
                                      size: 18,
                                    ),

                                    onPressed: () {
                                      _decreaseQuantity(
                                        food,
                                      );
                                    },
                                  ),

                                  Text(
                                    '$cartQuantity',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  IconButton(
                                    padding:
                                        EdgeInsets.zero,

                                    constraints:
                                        const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),

                                    icon: const Icon(
                                      Icons.add,
                                      size: 18,
                                    ),

                                    onPressed: () {
                                      _increaseQuantity(
                                        food,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
