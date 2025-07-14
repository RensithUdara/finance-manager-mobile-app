import 'dart:async';

import '../../domain/entities/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static final List<Expense> _expenses = [];
  static int _currentId = 1;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  // Simulate database initialization
  Future<void> get database async {
    // For web compatibility, we'll use in-memory storage
    await Future.delayed(const Duration(milliseconds: 100));

    // Add some sample data if empty
    if (_expenses.isEmpty) {
      _addSampleData();
    }
  }

  void _addSampleData() {
    // No sample data - start with empty list
  }

  Future<int> insertExpense(Expense expense) async {
    await Future.delayed(
        const Duration(milliseconds: 50)); // Simulate async operation

    final newExpense = expense.copyWith(id: _currentId++);
    _expenses.add(newExpense);

    return newExpense.id!;
  }

  Future<List<Expense>> getExpenses() async {
    await Future.delayed(
        const Duration(milliseconds: 50)); // Simulate async operation

    // Sort by date (newest first)
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    return List.from(_expenses);
  }

  Future<int> deleteExpense(int id) async {
    await Future.delayed(
        const Duration(milliseconds: 50)); // Simulate async operation

    final index = _expenses.indexWhere((expense) => expense.id == id);
    if (index != -1) {
      _expenses.removeAt(index);
      return 1; // Success
    }
    return 0; // Not found
  }

  Future<int> updateExpense(Expense expense) async {
    await Future.delayed(
        const Duration(milliseconds: 50)); // Simulate async operation

    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      return 1; // Success
    }
    return 0; // Not found
  }

  // Clear all data (useful for testing)
  Future<void> clearAll() async {
    _expenses.clear();
    _currentId = 1;
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _expenses.where((expense) => expense.category == category).toList();
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }
}
