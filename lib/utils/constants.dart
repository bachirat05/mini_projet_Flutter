import 'package:flutter/material.dart';

//  Catégories de dépenses 
// Chaque catégorie a un nom, une icône et une couleur.
// On utilise des constantes pour éviter les fautes de frappe partout dans l'app.

class AppCategories {
  static const List<Map<String, dynamic>> depenses = [
    {'name': 'Alimentation',  'icon': Icons.restaurant,      'color': Color(0xFFE53935)},
    {'name': 'Transport',     'icon': Icons.directions_car,  'color': Color(0xFF8E24AA)},
    {'name': 'Logement',      'icon': Icons.home,            'color': Color(0xFF1E88E5)},
    {'name': 'Santé',         'icon': Icons.local_hospital,  'color': Color(0xFF00ACC1)},
    {'name': 'Loisirs',       'icon': Icons.sports_esports,  'color': Color(0xFFFB8C00)},
    {'name': 'Éducation',     'icon': Icons.school,          'color': Color(0xFF43A047)},
    {'name': 'Vêtements',     'icon': Icons.checkroom,       'color': Color(0xFFD81B60)},
    {'name': 'Autre',         'icon': Icons.category,        'color': Color(0xFF757575)},
  ];

  static const List<Map<String, dynamic>> revenus = [
    {'name': 'Salaire',       'icon': Icons.work,            'color': Color(0xFF43A047)},
    {'name': 'Freelance',     'icon': Icons.laptop,          'color': Color(0xFF00ACC1)},
    {'name': 'Investissement','icon': Icons.trending_up,     'color': Color(0xFF1E88E5)},
    {'name': 'Cadeau',        'icon': Icons.card_giftcard,   'color': Color(0xFFD81B60)},
    {'name': 'Autre',         'icon': Icons.category,        'color': Color(0xFF757575)},
  ];

  // Retourne la couleur d'une catégorie par son nom
  static Color getColor(String name) {
    final all = [...depenses, ...revenus];
    final found = all.firstWhere(
      (c) => c['name'] == name,
      orElse: () => {'color': const Color(0xFF757575)},
    );
    return found['color'] as Color;
  }

  // Retourne l'icône d'une catégorie par son nom
  static IconData getIcon(String name) {
    final all = [...depenses, ...revenus];
    final found = all.firstWhere(
      (c) => c['name'] == name,
      orElse: () => {'icon': Icons.category},
    );
    return found['icon'] as IconData;
  }
}

//  Clés SharedPreferences
class PrefKeys {
  static const String userId    = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName  = 'user_name';
  static const String isDarkMode = 'is_dark_mode';
  // Budget mensuel par catégorie, stocké sous forme "budget_Alimentation" etc.
  static String budgetKey(String category) => 'budget_$category';
}

//  Couleurs de l'app 
class AppColors {
  static const Color income  = Color(0xFF43A047); // vert pour les revenus
  static const Color expense = Color(0xFFE53935); // rouge pour les dépenses
  static const Color primary = Color(0xFF5C6BC0); // indigo principal
}