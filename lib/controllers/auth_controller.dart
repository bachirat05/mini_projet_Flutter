import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email: email, password: password);
    isLoading = false;
    
    if (result.success) {
      currentUser = result.user;
      notifyListeners();
      return true;
    } else {
      errorMessage = result.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _authService.register(name: name, email: email, password: password);
    isLoading = false;
    
    if (result.success) {
      currentUser = result.user;
      notifyListeners();
      return true;
    } else {
      errorMessage = result.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    currentUser = null;
    notifyListeners();
  }

  Future<void> checkSession() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final id = await _authService.getCurrentUserId();
      final name = await _authService.getCurrentUserName();
      if (id != null && name != null) {
        currentUser = User(id: id, name: name, email: '');
      }
    }
    notifyListeners();
  }
}
