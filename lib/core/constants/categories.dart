import 'package:flutter/material.dart';

class Categories {
  static const List<CategoryData> expenseCategories = [
    CategoryData(
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    CategoryData(
      name: 'Transportation',
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    CategoryData(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.green,
    ),
    CategoryData(
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.purple,
    ),
    CategoryData(
      name: 'Bills & Utilities',
      icon: Icons.receipt,
      color: Colors.red,
    ),
    CategoryData(
      name: 'Healthcare',
      icon: Icons.medical_services,
      color: Colors.teal,
    ),
    CategoryData(
      name: 'Education',
      icon: Icons.school,
      color: Colors.indigo,
    ),
    CategoryData(
      name: 'Others',
      icon: Icons.category,
      color: Colors.grey,
    ),
  ];

  static CategoryData getCategoryByName(String name) {
    return expenseCategories.firstWhere(
      (category) => category.name == name,
      orElse: () => expenseCategories.last,
    );
  }
}

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryData({
    required this.name,
    required this.icon,
    required this.color,
  });
}
