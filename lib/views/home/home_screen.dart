import 'package:flutter/material.dart';

import '../../controllers/budget_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/auth_controller.dart';

import '../budget/budget_screen.dart';
import 'dashboard_screen.dart';
import '../transactions/transaction_form_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final AuthController authController;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.authController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TransactionController _transactionController;
  late BudgetController _budgetController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _transactionController = TransactionController();
    _budgetController = BudgetController();

    _transactionController.addListener(_onControllerUpdate);
    _budgetController.addListener(_onControllerUpdate);

    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();

    await _transactionController.loadTransactions(widget.userId);

    await _budgetController.loadBudget(
      widget.userId,
      now.month,
      now.year,
    );
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }


  // fonction pour logout 
  Future<void> _logout() async {
    await widget.authController.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          authController: widget.authController,
        ),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _transactionController.removeListener(_onControllerUpdate);
    _budgetController.removeListener(_onControllerUpdate);

    _transactionController.dispose();
    _budgetController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        transactionController: _transactionController,
      ),
      TransactionListScreen(
        transactionController: _transactionController,
        userId: widget.userId,
      ),
      BudgetScreen(
        userId: widget.userId,
        budgetController: _budgetController,
        transactionController: _transactionController,
      ),
    ];

    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Gestion Financière'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: _logout,
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionFormScreen(
                transactionController: _transactionController,
                userId: widget.userId,
              ),
            ),
          );

          await _transactionController.loadTransactions(widget.userId);
        },
      ),
    );
  }
}