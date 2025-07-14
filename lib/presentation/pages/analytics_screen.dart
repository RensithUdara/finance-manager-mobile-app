import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/categories.dart';
import '../blocs/expense/expense_bloc.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadExpenses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseLoaded) {
            if (state.expenses.isEmpty) {
              return _buildEmptyState(context);
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMonthlyOverview(context, state.expenses),
                  const SizedBox(height: 16),
                  _buildCategoryChart(context, state.expenses),
                  const SizedBox(height: 16),
                  _buildTopCategories(context, state.expenses),
                  const SizedBox(height: 16),
                  _buildSpendingInsights(context, state.expenses),
                ],
              ),
            );
          } else if (state is ExpenseError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Data to Analyze',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some expenses to see analytics',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add-expense'),
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyOverview(BuildContext context, List expenses) {
    final now = DateTime.now();
    final thisMonth = expenses
        .where((expense) =>
            expense.date.year == now.year && expense.date.month == now.month)
        .toList();

    final lastMonth = expenses.where((expense) {
      final lastMonthDate = DateTime(now.year, now.month - 1);
      return expense.date.year == lastMonthDate.year &&
          expense.date.month == lastMonthDate.month;
    }).toList();

    final thisMonthTotal =
        thisMonth.fold(0.0, (sum, expense) => sum + expense.amount);
    final lastMonthTotal =
        lastMonth.fold(0.0, (sum, expense) => sum + expense.amount);
    final difference = thisMonthTotal - lastMonthTotal;
    final percentageChange =
        lastMonthTotal > 0 ? (difference / lastMonthTotal) * 100 : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    context,
                    'This Month',
                    'Rs.${thisMonthTotal.toStringAsFixed(2)}',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewCard(
                    context,
                    'Last Month',
                    'Rs.${lastMonthTotal.toStringAsFixed(2)}',
                    Icons.history,
                    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: difference >= 0
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    difference >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: difference >= 0 ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${difference >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}% from last month',
                    style: TextStyle(
                      color: difference >= 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context, List expenses) {
    final categoryTotals = <String, double>{};

    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildPieChart(sortedCategories),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLegend(sortedCategories),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List<MapEntry<String, double>> sortedCategories) {
    final total = sortedCategories.fold(0.0, (sum, entry) => sum + entry.value);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sortedCategories.take(6).map((entry) {
          final category = Categories.getCategoryByName(entry.key);
          final percentage = (entry.value / total) * 100;

          return PieChartSectionData(
            color: category.color,
            value: entry.value,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend(List<MapEntry<String, double>> sortedCategories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedCategories.take(6).map((entry) {
        final category = Categories.getCategoryByName(entry.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopCategories(BuildContext context, List expenses) {
    final categoryTotals = <String, double>{};

    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalSpent =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Spending Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...sortedCategories.take(5).map((entry) {
              final category = Categories.getCategoryByName(entry.key);
              final percentage =
                  totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: category.color.withOpacity(0.2),
                      child:
                          Icon(category.icon, color: category.color, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(category.color),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs.${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingInsights(BuildContext context, List expenses) {
    if (expenses.isEmpty) return const SizedBox();

    final totalSpent =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final avgDaily = totalSpent / 30; // Assuming 30 days
    final maxExpense = expenses.fold(
        0.0, (max, expense) => expense.amount > max ? expense.amount : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInsightRow(
              context,
              'Average Daily Spending',
              'Rs.${avgDaily.toStringAsFixed(2)}',
              Icons.trending_up,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInsightRow(
              context,
              'Largest Single Expense',
              'Rs.${maxExpense.toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildInsightRow(
              context,
              'Total Transactions',
              '${expenses.length}',
              Icons.receipt_long,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
