import 'package:flutter/material.dart';

import '../../../models/food.dart';
import '../../../services/api_service.dart';

class GeePage extends StatefulWidget {
  final String email;
  final bool isAdmin;

  const GeePage({
    super.key,
    required this.email,
    this.isAdmin = false,
  });

  @override
  State<GeePage> createState() => _GeePageState();
}

class _GeePageState extends State<GeePage> {
  late Future<List<Food>> geeFuture;

  @override
  void initState() {
    super.initState();
    _loadGee();
  }

  void _loadGee() {
    geeFuture = ApiService.getGee();
  }

  Future<void> _editGee(Food item) async {
    final controller = TextEditingController(
      text: item.price.toStringAsFixed(2),
    );

    final price = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${item.name}'),
          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Price',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(
                  controller.text.trim(),
                );

                if (value == null || value < 0) {
                  return;
                }

                Navigator.pop(context, value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (price == null) return;

    try {
      await ApiService.updateGee(
        item.id,
        item.name,
        item.description,
        price,
      );

      if (!mounted) return;

      setState(_loadGee);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gee price updated'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gee'),
      ),
      body: FutureBuilder<List<Food>>(
        future: geeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load Gee\n\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No Gee available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(item.description),
                  trailing: widget.isAdmin
                      ? IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editGee(item),
                        )
                      : Text(
                          '₹${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
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
    );
  }
}
