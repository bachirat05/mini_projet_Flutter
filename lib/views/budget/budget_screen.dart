import 'package:flutter/material.dart';

import '../../controllers/budget_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../utils/constants.dart';

class BudgetScreen extends StatefulWidget {
  final int userId;
  final BudgetController budgetController;
  final TransactionController transactionController;

  const BudgetScreen({
    super.key,
    required this.userId,
    required this.budgetController,
    required this.transactionController,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double _sliderValue = 5000;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    widget.budgetController.addListener(_onBudgetUpdate);
    widget.transactionController.addListener(_onTransactionUpdate);

    _initSlider();
  }

  void _initSlider() {
    final budget = widget.budgetController.budgetActuel;

    if (budget != null) {
      _sliderValue = budget.montantMax;
    }
  }

  void _onBudgetUpdate() {
    if (!mounted) return;

    setState(() {
      _initSlider();
    });
  }

  void _onTransactionUpdate() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    widget.budgetController.removeListener(_onBudgetUpdate);
    widget.transactionController.removeListener(_onTransactionUpdate);
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final now = DateTime.now();

    final success =
        await widget.budgetController.saveBudget(
      userId: widget.userId,
      montantMax: _sliderValue,
      mois: now.month,
      annee: now.year,
    );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.budgetController.isLoading ||
        widget.transactionController.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final budget = widget.budgetController.budgetActuel;

    final montantMax = budget?.montantMax ?? 0.0;

    final now = DateTime.now();

    final totalExpense =
        widget.transactionController.totalDepensesduMois(
      now.year,
      now.month,
    );

    final progress =
        montantMax > 0 ? (totalExpense / montantMax).clamp(0.0, 1.0) : 0.0;

    final isOverBudget = totalExpense > montantMax;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Budget du mois',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${montantMax.toStringAsFixed(2)} MAD',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing) ...[
                    Slider(
                      value: _sliderValue,
                      min: 0,
                      max: 20000,
                      divisions: 40,
                      label: _sliderValue.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: _saveBudget,
                      child: const Text('Sauvegarder'),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      child: const Text(
                        'Modifier le budget',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Dépenses actuelles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey.shade300,
            color: isOverBudget
                ? Colors.red
                : AppColors.primary,
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${totalExpense.toStringAsFixed(2)} MAD',
                style: TextStyle(
                  color: isOverBudget
                      ? Colors.red
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${montantMax.toStringAsFixed(2)} MAD',
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (isOverBudget)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Attention: Vous avez dépassé votre budget mensuel !',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}