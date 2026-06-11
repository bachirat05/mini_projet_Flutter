import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;
  const LoginScreen({super.key, required this.authController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  void _login() async {
    final success = await widget.authController.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userId: widget.authController.currentUser!.id!,
          authController: widget.authController,),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.authController.errorMessage ?? 'Erreur de connexion')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FocusScope(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image Widget
                Image.network(
                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance_wallet, size: 100, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Mon Portefeuille',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                
                // TextField with InputDecoration
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocus);
                  },
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 24),
                
                // SizedBox and FilledButton
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: widget.authController.isLoading ? null : _login,
                    child: widget.authController.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Se Connecter'),
                  ),
                ),
                const SizedBox(height: 16),
                
                // TextButton
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterScreen(authController: widget.authController),
                      ),
                    );
                  },
                  child: const Text('Créer un compte'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
