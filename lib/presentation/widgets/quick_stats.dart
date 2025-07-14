import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/expense/expense_bloc.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        double totalExpenses = 0;
        double monthlyExpenses = 0;
        int transactionCount = 0;

        if (state is ExpenseLoaded) {
          totalExpenses =
              state.expenses.fold(0, (sum, expense) => sum + expense.amount);

          final now = DateTime.now();
          final thisMonth = state.expenses.where((expense) =>
              expense.date.year == now.year && expense.date.month == now.month);

          monthlyExpenses =
              thisMonth.fold(0, (sum, expense) => sum + expense.amount);
          transactionCount = state.expenses.length;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Financial Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Total Spent',
                        value: 'Rs.${totalExpenses.toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'This Month',
                        value: 'Rs.${monthlyExpenses.toStringAsFixed(2)}',
                        icon: Icons.calendar_month,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  context,
                  title: 'Total Transactions',
                  value: transactionCount.toString(),
                  icon: Icons.receipt_long,
                  color: Colors.green,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isFullWidth
          ? Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
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
}
