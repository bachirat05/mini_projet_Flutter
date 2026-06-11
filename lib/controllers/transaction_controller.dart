import 'package:flutter/material.dart';
import 'package:mini_projet/services/api_service.dart';
import 'package:mini_projet/services/data_service.dart';
import '../models/transaction.dart';
//import '../services/transaction_service.dart';

class TransactionController extends ChangeNotifier {
  // DataService est une interface abstraite (data_service.dart).
  // Il suffit de changer cette ligne pour basculer entre SQLite et API :
    //   SQLite  → final DataService _service = TransactionService();
    //   API     → final DataService _service = ApiService(baseUrl: 'http://10.0.2.2:3000');
  // Le reste du controller (et toutes les vues) ne changent PAS.

  // PARTIE 1 : SQFLite : 
    //final TransactionService _service = TransactionService();

  // Utilisation d'API : 
  final DataService _service = ApiService(baseUrl: 'http://10.0.2.2:3000',);
    // caci me permettra d'accéder : 
      // Émulateur Android  => 10.0.2.2:3000
      // Appareil physique  => <IP_du_PC>:3000
      // iOS / Web          => localhost:3000

  List<Transaction> transactions = [];
  bool isLoading = false;
  String? errorMessage;

  //  Filtres actifs 
  // null = pas de filtre
  String? filtreType;       // 'income' | 'expense' | null
  String? filtreCategorie;  // nom de catégorie | null

  //  Charger toutes les transactions d'un utilisateur 
  Future<void> loadTransactions(int userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      transactions = await _service.getTransactions(userId);
    } catch (e) {
      errorMessage = 'Erreur chargement : $e';
    }

    isLoading = false;
    notifyListeners();
  }

  //  Liste filtrée (calculée à partir de transactions) 
  List<Transaction> get transactionsFiltrees {
    return transactions.where((t) {
      final typeOk = filtreType == null || t.type == filtreType;
      final catOk  = filtreCategorie == null || t.categorie == filtreCategorie;
      return typeOk && catOk;
    }).toList();
  }

  //  Appliquer / réinitialiser les filtres 
  void setFiltreType(String? type) {
    filtreType = type;
    notifyListeners();
  }

  void setFiltreCategorie(String? cat) {
    filtreCategorie = cat;
    notifyListeners();
  }

  void clearFiltres() {
    filtreType = null;
    filtreCategorie = null;
    notifyListeners();
  }

  //  Ajouter 
  Future<bool> addTransaction(Transaction transaction) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final created = await _service.addTransaction(transaction);
      // Insérer en tête de liste (déjà triée par date DESC)
      transactions.insert(0, created);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Erreur ajout : $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //  Modifier 
  Future<bool> updateTransaction(Transaction transaction) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.updateTransaction(transaction);
      // Remplacer dans la liste locale
      final index = transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) transactions[index] = transaction;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Erreur modification : $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //  Supprimer 
  Future<bool> deleteTransaction(int id) async {
    try {
      await _service.deleteTransaction(id);
      transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Erreur suppression : $e';
      notifyListeners();
      return false;
    }
  }

  //  Calculs dashboard

  // Total revenus du mois courant
  double totalRevenusduMois(int annee, int mois) {
    return transactions
        .where((t) {
          final d = DateTime.parse(t.date);
          return t.isIncome && d.year == annee && d.month == mois;
        })
        .fold(0.0, (sum, t) => sum + t.montant);
  }

  // Total dépenses du mois courant
  double totalDepensesduMois(int annee, int mois) {
    return transactions
        .where((t) {
          final d = DateTime.parse(t.date);
          return t.isExpense && d.year == annee && d.month == mois;
        })
        .fold(0.0, (sum, t) => sum + t.montant);
  }

  // Dépenses groupées par catégorie pour le mois (camembert)
  Map<String, double> depensesParCategorie(int annee, int mois) {
    final Map<String, double> result = {};
    for (final t in transactions) {
      final d = DateTime.parse(t.date);
      if (t.isExpense && d.year == annee && d.month == mois) {
        result[t.categorie] = (result[t.categorie] ?? 0) + t.montant;
      }
    }
    return result;
  }

  // 5 dernières transactions (pour le dashboard)
  List<Transaction> get dernieresCinq => transactions.take(5).toList();
}