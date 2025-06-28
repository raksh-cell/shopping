// Improved UI Version of GroceryList.dart with updated app bar color and stylish snackbar
import 'dart:convert';
import 'package:fetchit/models/category.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:fetchit/models/grocery_item.dart';
import 'package:fetchit/data/categories.dart';
import 'package:fetchit/widget/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final Future<List<GroceryItem>> _groceryFuture = _loadItems();

  static Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
      //your firebase link,
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to load items');
      }

      final Map<String, dynamic>? listData = json.decode(response.body);
      if (listData == null) return [];

      final List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
              (catItem) => catItem.value.title == item.value['category'],
          orElse: () => MapEntry(Categories.vegetables, categories[Categories.vegetables]!),
        )
            .value;

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      return loadedItems;
    } catch (error) {
      throw Exception('Something went wrong: $error');
    }
  }

  List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItem()),
    );

    if (newItem == null) return;

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      //your firebase link//
      ${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepPurple.shade300,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('Item deleted', style: TextStyle(color: Colors.white)),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.yellow,
            onPressed: () async {
              setState(() {
                _groceryItems.insert(index, item);
              });
              final undoUrl = Uri.https(//add your firebase link here

              );
              await http.put(
                undoUrl,
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'name': item.name,
                  'quantity': item.quantity,
                  'category': item.category.title,
                }),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groceries'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 103, 58, 183),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<GroceryItem>>(
        future: _groceryFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            _groceryItems = snapshot.data!;

            if (_groceryItems.isEmpty) {
              return const Center(child: Text('No items added yet.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                final items = await _loadItems();
                setState(() {
                  _groceryItems = items;
                });
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _groceryItems.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.grey, height: 1),
                itemBuilder: (ctx, index) => Dismissible(
                  key: ValueKey(_groceryItems[index].id),
                  onDismissed: (direction) {
                    _removeItem(_groceryItems[index]);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  child: Card(
                    color: theme.colorScheme.surface,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        _groceryItems[index].name,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: _groceryItems[index].category.color,
                        radius: 12,
                      ),
                      trailing: Text(
                        'x${_groceryItems[index].quantity}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return const Center(child: Text('No data found.'));
        },
      ),
    );
  }
}
