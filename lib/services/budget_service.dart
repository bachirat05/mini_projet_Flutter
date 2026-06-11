import '../models/budget.dart';
import 'database_service.dart';

class BudgetService {

  final SqlDb sqlDb = SqlDb();

  /// Récupère le budget pour un userId, un mois et une année précis.
  Future<Budget?> getBudget(int userId, int mois, int annee) async {
    final data = await sqlDb.getBudget(userId, mois, annee);
    if (data.isEmpty) return null;
    return Budget.fromJson(data.first);
  }

  Future<void> addBudget(Budget budget) async {
    await sqlDb.insertBudget(budget.toJson());
  }

  Future<void> updateBudget(Budget budget) async {
     print("UPDATE BUDGET");
     print("id = ${budget.id}");
     print(budget.toJson());
    await sqlDb.updateBudget(budget.id!, budget.toJson());
    await sqlDb.debugBudgets();
  }

  Future<void> deleteBudget(int id) async {
    await sqlDb.deleteBudget(id);
  }
}