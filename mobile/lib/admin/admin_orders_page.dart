import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({
    super.key,
  });

  @override
  State<AdminOrdersPage> createState() =>
      _AdminOrdersPageState();
}

class _AdminOrdersPageState
    extends State<AdminOrdersPage> {

  late Future<List<Map<String, dynamic>>> ordersFuture;

  @override
  void initState() {
    super.initState();

    ordersFuture =
        ApiService.getAdminOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      ordersFuture =
          ApiService.getAdminOrders();
    });

    await ordersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Orders'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: FutureBuilder<
            List<Map<String, dynamic>>>(
          future: ordersFuture,
          builder: (context, snapshot) {

            // =================================================
            // LOADING
            // =================================================

            if (snapshot.connectionState ==
                ConnectionState.waiting) {

              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // =================================================
            // ERROR
            // =================================================

            if (snapshot.hasError) {

              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: [

                  SizedBox(
                    height:
                        MediaQuery.of(context)
                                .size
                                .height *
                            0.25,
                  ),

                  const Icon(
                    Icons.error_outline,
                    size: 70,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Unable to load orders',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          ordersFuture =
                              ApiService
                                  .getAdminOrders();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              );
            }

            final orders =
                snapshot.data ?? [];

            // =================================================
            // NO ORDERS
            // =================================================

            if (orders.isEmpty) {

              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: [

                  SizedBox(
                    height:
                        MediaQuery.of(context)
                                .size
                                .height *
                            0.3,
                  ),

                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'No customer orders',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'New customer orders will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ],
              );
            }

            // =================================================
            // ORDERS
            // =================================================

            return ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {

                return _buildOrderCard(
                  orders[index],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // ORDER CARD
  // =========================================================

  Widget _buildOrderCard(
      Map<String, dynamic> order) {

    final orderId =
        order['id'];

    final email =
        order['email']?.toString() ??
            'Unknown customer';

    final total =
        _toDouble(order['total']);

    final status =
        order['status']?.toString() ??
            'UNKNOWN';

    final createdAt =
        order['createdAt']?.toString() ??
            '';

    final items =
        order['items'];

    final List<dynamic> orderItems =
        items is List ? items : [];

    return Card(
      margin:
          const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // =================================================
            // HEADER
            // =================================================

            Row(
              children: [

                const Icon(
                  Icons.receipt_long,
                  color: Color(0xFFFF6B35),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Order #$orderId',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                _buildStatusChip(
                  status,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // =================================================
            // CUSTOMER
            // =================================================

            Row(
              children: [

                Icon(
                  Icons.person_outline,
                  size: 18,
                  color:
                      Colors.grey.shade600,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Text(
                    email,
                    style: TextStyle(
                      color:
                          Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            // =================================================
            // DATE
            // =================================================

            if (createdAt.isNotEmpty) ...[

              const SizedBox(height: 8),

              Row(
                children: [

                  Icon(
                    Icons
                        .calendar_today_outlined,
                    size: 16,
                    color:
                        Colors.grey.shade600,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    _formatDate(
                      createdAt,
                    ),
                    style: TextStyle(
                      color:
                          Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 8),

            // =================================================
            // ITEMS
            // =================================================

            if (orderItems.isEmpty)

              const Text(
                'No item details available',
                style: TextStyle(
                  color: Colors.grey,
                ),
              )

            else

              Column(
                children:
                    orderItems
                        .map(
                          (item) =>
                              _buildOrderItem(
                            item,
                          ),
                        )
                        .toList(),
              ),

            const SizedBox(height: 8),

            const Divider(),

            const SizedBox(height: 10),

            // =================================================
            // TOTAL
            // =================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                const Text(
                  'Order Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // =================================================
            // ACTIONS
            // =================================================

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showOrderDetails(
                        order,
                      );
                    },
                    child:
                        const Text('View'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showStatusMessage(
                        context,
                        orderId,
                      );
                    },
                    child:
                        const Text('Manage'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ORDER ITEM
  // =========================================================

  Widget _buildOrderItem(
      dynamic item) {

    if (item
        is! Map<String, dynamic>) {
      return const SizedBox.shrink();
    }

    final name =
        item['foodName']
                ?.toString() ??
            'Unknown item';

    final quantity =
        item['quantity'] ?? 0;

    final price =
        _toDouble(item['price']);

    final subtotal =
        _toDouble(item['subtotal']);

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [

          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFFF6B35,
              ).withValues(
                alpha: 0.1,
              ),
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
            ),
            child: const Icon(
              Icons.fastfood_outlined,
              color:
                  Color(0xFFFF6B35),
              size: 21,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  name,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '$quantity × ₹${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₹${subtotal.toStringAsFixed(2)}',
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS CHIP
  // =========================================================

  Widget _buildStatusChip(
      String status) {

    Color color;

    switch (
        status.toUpperCase()) {

      case 'PLACED':
        color = Colors.green;
        break;

      case 'PROCESSING':
        color = Colors.orange;
        break;

      case 'DELIVERED':
        color = Colors.blue;
        break;

      case 'CANCELLED':
        color = Colors.red;
        break;

      default:
        color = Colors.grey;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight:
              FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // =========================================================
  // ORDER DETAILS
  // =========================================================

  void _showOrderDetails(
      Map<String, dynamic> order) {

    final orderId =
        order['id'];

    final email =
        order['email']
                ?.toString() ??
            '';

    final status =
        order['status']
                ?.toString() ??
            '';

    final total =
        _toDouble(
      order['total'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {

        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  'Order #$orderId',
                  style:
                      const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Customer: $email',
                ),

                const SizedBox(height: 8),

                Text(
                  'Status: $status',
                ),

                const SizedBox(height: 8),

                Text(
                  'Total: ₹${total.toStringAsFixed(2)}',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child:
                      ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    child:
                        const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // TEMPORARY STATUS ACTION
  // =========================================================

  void _showStatusMessage(
      BuildContext context,
      dynamic orderId) {

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Order #$orderId management will be connected next.',
        ),
      ),
    );
  }

  // =========================================================
  // DOUBLE
  // =========================================================

  double _toDouble(
      dynamic value) {

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  // =========================================================
  // DATE
  // =========================================================

  String _formatDate(
      String value) {

    try {

      final date =
          DateTime.parse(value);

      final day =
          date.day
              .toString()
              .padLeft(2, '0');

      final month =
          date.month
              .toString()
              .padLeft(2, '0');

      final year =
          date.year.toString();

      final hour =
          date.hour
              .toString()
              .padLeft(2, '0');

      final minute =
          date.minute
              .toString()
              .padLeft(2, '0');

      return '$day/$month/$year • $hour:$minute';

    } catch (_) {

      return value;
    }
  }
}
