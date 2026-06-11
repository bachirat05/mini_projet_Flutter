import 'package:flutter/material.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/transaction.dart' as model;
import '../../utils/constants.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final TransactionController transactionController;
  final int userId;

  const TransactionListScreen({
    super.key,
    required this.transactionController,
    required this.userId,
  });

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  Set<String> _selectedFilter = {'All'};

  @override
  Widget build(BuildContext context) {
    List<model.Transaction> filteredTransactions = widget.transactionController.transactions;
    if (_selectedFilter.first == 'Income') {
      filteredTransactions = filteredTransactions.where((t) => t.isIncome).toList();
    } else if (_selectedFilter.first == 'Expense') {
      filteredTransactions = filteredTransactions.where((t) => t.isExpense).toList();
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        // SegmentedButton Widget
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'All', label: Text('Tous')),
            ButtonSegment(value: 'Income', label: Text('Revenus')),
            ButtonSegment(value: 'Expense', label: Text('Dépenses')),
          ],
          selected: _selectedFilter,
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _selectedFilter = newSelection;
            });
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: widget.transactionController.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredTransactions.isEmpty
                  ? const Center(
                      child: Text('Aucune transaction trouvée.'),
                    )
                  : ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = filteredTransactions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Icon(
                              AppCategories.getIcon(tx.categorie),
                              color: AppCategories.getColor(tx.categorie),
                            ),
                            title: Text(tx.description),
                            subtitle: Text('${tx.categorie} • ${tx.date}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${tx.montant} MAD',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: tx.isIncome ? AppColors.income : AppColors.expense,
                                  ),
                                ),
                                // IconButton Widget
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.grey),
                                  onPressed: () {
                                    if (tx.id != null) {
                                      widget.transactionController.deleteTransaction(tx.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionFormScreen(
                                    transactionController: widget.transactionController,
                                    transactionToEdit: tx,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
