//dummy_items.dart
import 'package:fetchit/models/category.dart';
import 'package:fetchit/models/grocery_item.dart';
import 'package:fetchit/data/categories.dart';

final groceryItems = [
  GroceryItem(
      id: 'a',
      name: 'Milk',
      quantity: 1,
      category: categories[Categories.dairy]!),
  GroceryItem(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categories[Categories.fruit]!),
  GroceryItem(
      id: 'c',
      name: ' Chicken',
      quantity: 1,
      category: categories[Categories.meat]!),
];