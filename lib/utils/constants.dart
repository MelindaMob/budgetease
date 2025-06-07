import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2196F3);
  static const income = Color(0xFF4CAF50);
  static const expense = Color(0xFFF44336);
  static const background = Color(0xFFF5F5F5);
}

class AppConstants {
  static const List<String> categories = [
    'Alimentation',
    'Transport',
    'Logement',
    'Loisirs',
    'Santé',
    'Shopping',
    'Factures',
    'Autres',
  ];

  static const List<String> transactionTypes = [
    'revenu',
    'dépense',
  ];
}

class AppTextStyles {
  static const titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
}

String formatAmount(double amount) {
  return '${amount.toStringAsFixed(2)} €';
}
