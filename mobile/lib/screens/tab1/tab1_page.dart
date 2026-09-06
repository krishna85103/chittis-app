import 'package:flutter/material.dart';

import 'nuts/nuts_page.dart';
import 'gee/gee_page.dart';
import 'food/food_page.dart';

class Tab1Page extends StatelessWidget {
  final String email;
  final bool isAdmin;

  const Tab1Page({
    super.key,
    required this.email,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // NUTS
        _category(
          context,
          title: 'Nuts',
          image: 'assets/images/nuts.png',
          page: NutsPage(
            email: email,
            isAdmin: isAdmin,
          ),
        ),

        // GEE
        _category(
          context,
          title: 'Gee',
          image: 'assets/images/gee.png',
          page: GeePage(
            email: email,
            isAdmin: isAdmin,
          ),
        ),

        // FOOD
        _category(
          context,
          title: 'Food',
          image: 'assets/images/food.png',
          page: FoodPage(
            email: email,
            isAdmin: isAdmin,
          ),
        ),
      ],
    );
  }

  Widget _category(
    BuildContext context, {
    required String title,
    required String image,
    required Widget page,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),

        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            image,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
      ),
    );
  }
}
