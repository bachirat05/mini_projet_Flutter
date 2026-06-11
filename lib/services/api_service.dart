import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'data_service.dart';

class ApiService implements DataService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  @override
  Future<List<Transaction>> getTransactions(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/transactions?userId=$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  @override
  @override
  Future<Transaction> addTransaction(Transaction transaction) async {

    final url = Uri.parse('$baseUrl/transactions');

    final body = json.encode(transaction.toJson());

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Transaction.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add transaction');
    }
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/${transaction.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaction.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update transaction');
    }
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/transactions/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete transaction');
    }
  }
}
