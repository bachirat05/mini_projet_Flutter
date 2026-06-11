import '../models/transaction.dart';
import 'database_service.dart';
import 'data_service.dart';

class TransactionService implements DataService {
  final SqlDb sqlDb = SqlDb();

  Future<List<Transaction>> getTransactions(
    int userId,
  ) async {

    final data =
        await sqlDb.getAllTransactions(userId);

    return data
        .map(
          (e) => Transaction.fromJson(e),
        )
        .toList();
  }

  Future<Transaction> addTransaction(
    Transaction transaction,
  ) async {

    int id = await sqlDb.insertTransaction(
      transaction.toJson(),
    );

    return Transaction(
      id: id,
      userId: transaction.userId,
      type: transaction.type,
      montant: transaction.montant,
      categorie: transaction.categorie,
      description: transaction.description,
      date: transaction.date,
    );
  }

  Future<void> deleteTransaction(
    int id,
  ) async {
    await sqlDb.deleteTransaction(id);
  }

  Future<void> updateTransaction(
    Transaction transaction,
  ) async {
    await sqlDb.updateTransaction(
      transaction.id!,
      transaction.toJson(),
    );
  }

  // calculer les dépenses d'un mois 
  Future<double> totalDepensesMois(int userId, int annee, int mois) async {
  final transactions =
      await getTransactions(userId);
  double total = 0;
  for (var t in transactions) {
    final date =
        DateTime.parse(t.date);
    if (
      date.year == annee &&
      date.month == mois &&
      t.type == 'expense'
    ) {
      total += t.montant;
    }
  }
  return total;
}
}