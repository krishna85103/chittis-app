import 'package:flutter/material.dart';

import '../../../models/food.dart';
import '../../../services/api_service.dart';

class BeersPage extends StatefulWidget {
  final String email;

  const BeersPage({
    super.key,
    required this.email,
  });

  @override
  State<BeersPage> createState() => _BeersPageState();
}

class _BeersPageState extends State<BeersPage> {
  late Future<List<Food>> foodFuture;

  @override
  void initState() {
    super.initState();

    foodFuture = ApiService.getFood();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beers'),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------------------------
          // LOGGED-IN USER
          // -----------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
          ),

          const SizedBox(height: 10),

          // -----------------------------------------
          // FOOD / BEERS FROM BACKEND
          // -----------------------------------------
          Expanded(
            child: FutureBuilder<List<Food>>(
              future: foodFuture,

              builder: (context, snapshot) {
                // LOADING
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // ERROR
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Unable to load beers\n\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }

                // DATA
                final foods = snapshot.data ?? [];

                // EMPTY
                if (foods.isEmpty) {
                  return const Center(
                    child: Text(
                      'No beers available',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                // LIST
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: foods.length,

                  itemBuilder: (context, index) {
                    final food = foods[index];

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),

                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.all(16),

                        // BEER ICON
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.amber.shade100,
                          child: const Icon(
                            Icons.local_drink,
                            color: Colors.brown,
                          ),
                        ),

                        // NAME
                        title: Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // DESCRIPTION
                        subtitle: Padding(
                          padding:
                              const EdgeInsets.only(top: 8),
                          child: Text(
                            food.description,
                          ),
                        ),

                        // PRICE
                        trailing: Text(
                          '₹${food.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
