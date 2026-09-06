import 'package:flutter/material.dart';

import '../admin/admin_orders_page.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../cart/cart_page.dart';
import '../orders/orders_page.dart';
import 'login_page.dart';
import 'tab1/tab1_page.dart';

class HomePage extends StatefulWidget {
  final String email;
  final bool isAdmin;

  const HomePage({
    super.key,
    required this.email,
    required this.isAdmin,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  late Future<ApiResponse> tab1Future;
  late Future<ApiResponse> tab2Future;
  late Future<ApiResponse> tab3Future;

  @override
  void initState() {
    super.initState();

    tab1Future = ApiService.getTab1();
    tab2Future = ApiService.getTab2();
    tab3Future = ApiService.getTab3();

    debugPrint('========================================');
    debugPrint('HOME PAGE');
    debugPrint('EMAIL: ${widget.email}');
    debugPrint('IS ADMIN: ${widget.isAdmin}');
    debugPrint('========================================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==================================================
      // APP BAR
      // ==================================================

      appBar: AppBar(
        title: const Text('Chitti'),
        actions: [
          // ------------------------------------------
          // CART
          // ------------------------------------------

          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
            ),
            tooltip: 'Cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartPage(
                    email: widget.email,
                  ),
                ),
              );
            },
          ),

          // ------------------------------------------
          // ADMIN LABEL
          // ------------------------------------------

          if (widget.isAdmin)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'ADMIN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
        ],
      ),

      // ==================================================
      // DRAWER
      // ==================================================

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // ------------------------------------------
              // USER HEADER
              // ------------------------------------------

              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B35),
                ),
                accountName: Text(
                  widget.isAdmin
                      ? 'Administrator'
                      : 'Customer',
                ),
                accountEmail: Text(widget.email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    widget.isAdmin
                        ? Icons.admin_panel_settings
                        : Icons.person,
                    color: const Color(0xFFFF6B35),
                    size: 34,
                  ),
                ),
              ),

              // ------------------------------------------
              // HOME
              // ------------------------------------------

              ListTile(
                leading: const Icon(
                  Icons.home,
                ),
                title: const Text(
                  'Home',
                ),
                onTap: () {
                  setState(() {
                    selectedIndex = 0;
                  });

                  Navigator.pop(context);
                },
              ),

              // ------------------------------------------
              // CART
              // ------------------------------------------

              ListTile(
                leading: const Icon(
                  Icons.shopping_cart_outlined,
                ),
                title: const Text(
                  'Cart',
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartPage(
                        email: widget.email,
                      ),
                    ),
                  );
                },
              ),

              // ------------------------------------------
              // MY ORDERS
              // ------------------------------------------

              ListTile(
                leading: const Icon(
                  Icons.receipt_long_outlined,
                ),
                title: const Text(
                  'My Orders',
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrdersPage(
                        email: widget.email,
                      ),
                    ),
                  );
                },
              ),

              // ------------------------------------------
              // ADMIN ORDERS
              // ------------------------------------------

              if (widget.isAdmin)
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Admin Orders',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminOrdersPage(),
                      ),
                    );
                  },
                ),

              const Divider(),

              // ------------------------------------------
              // LOGOUT
              // ------------------------------------------

              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  _showLogoutDialog();
                },
              ),

              const Spacer(),

              // ------------------------------------------
              // FOOTER
              // ------------------------------------------

              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Chitti • Food & Drinks',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ==================================================
      // BODY
      // ==================================================

      body: _buildBody(),

      // ==================================================
      // BOTTOM NAVIGATION
      // ==================================================

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.restaurant,
            ),
            label: 'Tab 1',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.local_drink,
            ),
            label: 'Tab 2',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.more_horiz,
            ),
            label: 'Tab 3',
          ),
        ],
      ),
    );
  }

  // ==================================================
  // LOGOUT CONFIRMATION
  // ==================================================

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================================================
  // LOGOUT
  // ==================================================

  void _logout() {
    debugPrint('========================================');
    debugPrint('USER LOGOUT');
    debugPrint('EMAIL: ${widget.email}');
    debugPrint('========================================');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  // ==================================================
  // BODY
  // ==================================================

  Widget _buildBody() {
    switch (selectedIndex) {
      // ------------------------------------------
      // TAB 1
      // ------------------------------------------

      case 0:
        return Tab1Page(
          email: widget.email,
          isAdmin: widget.isAdmin,
        );

      // ------------------------------------------
      // TAB 2
      // ------------------------------------------

      case 1:
        return _buildBackendTab(
          tabFuture: tab2Future,
          title: 'Tab 2',
        );

      // ------------------------------------------
      // TAB 3
      // ------------------------------------------

      case 2:
        return _buildBackendTab(
          tabFuture: tab3Future,
          title: 'Tab 3',
        );

      default:
        return Tab1Page(
          email: widget.email,
          isAdmin: widget.isAdmin,
        );
    }
  }

  // ==================================================
  // BACKEND TAB
  // ==================================================

  Widget _buildBackendTab({
    required Future<ApiResponse> tabFuture,
    required String title,
  }) {
    return FutureBuilder<ApiResponse>(
      future: tabFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load $title\n\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data;

        if (data == null) {
          return const Center(
            child: Text(
              'No data',
            ),
          );
        }

        if (!data.success) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                data.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                data.message,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Data received from Java backend',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
