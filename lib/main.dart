import 'package:flutter/material.dart';
import 'controllers/auth_controller.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthController _authController = AuthController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  void _initAuth() async {
    await _authController.checkSession();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion Financière',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: _authController.currentUser != null
          ? HomeScreen(userId: _authController.currentUser!.id!,
              authController: _authController,
            )
          : LoginScreen(authController: _authController,),
    );
  }
}
