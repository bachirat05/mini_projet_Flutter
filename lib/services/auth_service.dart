// pour stockage local simple
import 'package:shared_preferences/shared_preferences.dart';
// pour hasher le mot de passe (sécurité)
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/user.dart';
import '../utils/constants.dart';
import 'database_service.dart';

// RESULT MODEL
class AuthResult {
  final bool success;
  final String? message;
  final User? user;

  AuthResult({
    required this.success,
    this.message,
    this.user,
  });
}

// AUTH SERVICE
class AuthService {
  final SqlDb _dbService = SqlDb();

  //  HASH PASSWORD 
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  //  REGISTER 
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return AuthResult(
          success: false,
          message: "Tous les champs sont obligatoires",
        );
      }

      final db = await _dbService.db;

      // Vérifier email existant
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existing.isNotEmpty) {
        return AuthResult(
          success: false,
          message: "Cet email est déjà utilisé",
        );
      }

      final hashedPassword = _hashPassword(password);

      // Insérer user
      final id = await db.insert('users', {
        'name': name,
        'email': email,
        'password': hashedPassword,
      });

      final user = User(
        id: id,
        name: name,
        email: email,
      );

      await _saveSession(user);

      return AuthResult(
        success: true,
        user: user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: "Erreur lors de l'inscription : $e",
      );
    }
  }

  //  LOGIN 
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return AuthResult(
          success: false,
          message: "Email et mot de passe requis",
        );
      }

      final db = await _dbService.db;

      final hashedPassword = _hashPassword(password);

      final rows = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
      );

      if (rows.isEmpty) {
        return AuthResult(
          success: false,
          message: "Email ou mot de passe incorrect",
        );
      }

      final user = User.fromJson(
        Map<String, dynamic>.from(rows.first),
      );

      await _saveSession(user);

      return AuthResult(
        success: true,
        user: user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: "Erreur lors de la connexion : $e",
      );
    }
  }

  //  LOGOUT 
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  //  SESSION CHECK 
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(PrefKeys.userId);
  }

  //  GET CURRENT USER ID 
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PrefKeys.userId);
  }

  //  GET CURRENT USER NAME 
  Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKeys.userName);
  }

  //  SAVE SESSION 
  Future<void> _saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(PrefKeys.userId, user.id!);
    await prefs.setString(PrefKeys.userEmail, user.email);
    await prefs.setString(PrefKeys.userName, user.name);
  }
}