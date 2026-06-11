import 'package:flutter/material.dart';
import '../../controllers/transaction_controller.dart';
import '../../utils/constants.dart';

class DashboardScreen extends StatelessWidget {
  final TransactionController transactionController;

  const DashboardScreen({
    super.key,
    required this.transactionController,
  });

  @override
  Widget build(BuildContext context) {
    if (transactionController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in transactionController.transactions) {
      if (t.isIncome) {
        totalIncome += t.montant;
      } else {
        totalExpense += t.montant;
      }
    }

    final balance = totalIncome - totalExpense;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'Solde Total',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${balance.toStringAsFixed(2)} MAD',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Revenus',
                  amount: totalIncome,
                  color: AppColors.income,
                  icon: Icons.arrow_upward,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Dépenses',
                  amount: totalExpense,
                  color: AppColors.expense,
                  icon: Icons.arrow_downward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Aperçu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (totalIncome > 0 || totalExpense > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  if (totalIncome > 0)
                    Expanded(
                      flex: (totalIncome * 100).toInt(),
                      child: Container(height: 20, color: AppColors.income),
                    ),
                  if (totalExpense > 0)
                    Expanded(
                      flex: (totalExpense * 100).toInt(),
                      child: Container(height: 20, color: AppColors.expense),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Revenus: ${(totalIncome / (totalIncome + totalExpense == 0 ? 1 : totalIncome + totalExpense) * 100).toStringAsFixed(1)}%'),
              Text('Dépenses: ${(totalExpense / (totalIncome + totalExpense == 0 ? 1 : totalIncome + totalExpense) * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              '${amount.toStringAsFixed(2)} MAD',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
