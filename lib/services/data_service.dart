import '../models/transaction.dart';

abstract class DataService {
  Future<List<Transaction>> getTransactions(int userId);
  Future<Transaction> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(int id);
}
