import 'package:flutter/material.dart';

import 'Beers/beers_page.dart';
import 'wisky/wisky_page.dart';
import 'juice/juice_page.dart';

class Tab2Page extends StatelessWidget {
  final String email;

  const Tab2Page({
    super.key,
    required this.email,
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

        // -----------------------------------------
        // BEERS
        // -----------------------------------------
        _category(
          context,
          title: 'Beers',
          image: 'assets/images/beers.png',
          page: BeersPage(
            email: email,
          ),
        ),

        // -----------------------------------------
        // WICKY
        // -----------------------------------------
        _category(
          context,
          title: 'Wicky',
          image: 'assets/images/wisky.png',
          page: WickyPage(
            email: email,
          ),
        ),

        // -----------------------------------------
        // JUICE
        // -----------------------------------------
        _category(
          context,
          title: 'Juice',
          image: 'assets/images/juice.png',
          page: JuicePage(
            email: email,
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

