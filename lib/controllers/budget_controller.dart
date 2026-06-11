import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';

class BudgetController extends ChangeNotifier {
  final BudgetService _budgetService = BudgetService();

  Budget? budgetActuel;
  bool isLoading = false;
  String? errorMessage;

  //  Charger le budget d'un mois/année 
  Future<void> loadBudget(int userId, int mois, int annee) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      budgetActuel = await _budgetService.getBudget(userId, mois, annee);
    } catch (e) {
      errorMessage = 'Erreur lors du chargement du budget : $e';
    }

    isLoading = false;
    notifyListeners();
  }

  //  Définir ou mettre à jour le budget du mois 
  // Si un budget existe déjà pour ce mois → update, sinon → insert
  Future<bool> saveBudget({
    required int userId,
    required double montantMax,
    required int mois,
    required int annee,
  }) async {
    if (montantMax <= 0) {
      errorMessage = 'Le montant doit être supérieur à 0';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final existing = await _budgetService.getBudget(userId, mois, annee);

      if (existing != null) {
        // Mettre à jour le budget existant
        final updated = Budget(
          id: existing.id,
          userId: userId,
          montantMax: montantMax,
          mois: mois,
          annee: annee,
        );
        await _budgetService.updateBudget(updated);
        budgetActuel = updated;
      } else {
        // Créer un nouveau budget
        final nouveau = Budget(
          userId: userId,
          montantMax: montantMax,
          mois: mois,
          annee: annee,
        );
        await _budgetService.addBudget(nouveau);
        // Recharger pour récupérer l'id assigné par SQLite
        budgetActuel = await _budgetService.getBudget(userId, mois, annee);
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Erreur lors de la sauvegarde : $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //  Supprimer le budget du mois
  Future<void> deleteBudget() async {
    if (budgetActuel?.id == null) return;

    isLoading = true;
    notifyListeners();

    try {
      await _budgetService.deleteBudget(budgetActuel!.id!);
      budgetActuel = null;
    } catch (e) {
      errorMessage = 'Erreur suppression : $e';
    }

    isLoading = false;
    notifyListeners();
  }

  //  Calcul du pourcentage utilisé
  // dépensé / montantMax, clampé entre 0 et 1
  double progressRatio(double depenses) {
    if (budgetActuel == null || budgetActuel!.montantMax <= 0) return 0;
    return (depenses / budgetActuel!.montantMax).clamp(0.0, 1.0);
  }

  //  Vérifie si le budget est dépassé 
  bool isOver(double depenses) {
    if (budgetActuel == null) return false;
    return depenses > budgetActuel!.montantMax;
  }

  //  Reste disponible 
  double reste(double depenses) {
    if (budgetActuel == null) return 0;
    return budgetActuel!.montantMax - depenses;
  }
}