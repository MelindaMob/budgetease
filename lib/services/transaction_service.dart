import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final CollectionReference _transactionsCollection =
      FirebaseFirestore.instance.collection('transactions');

  // Ajouter une nouvelle transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _transactionsCollection.add(transaction.toMap());
    } catch (e) {
      print('Erreur lors de l\'ajout de la transaction: $e');
      throw e;
    }
  }

  // Obtenir toutes les transactions
  Stream<List<TransactionModel>> getTransactions() {
    return _transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Supprimer une transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsCollection.doc(id).delete();
    } catch (e) {
      print('Erreur lors de la suppression de la transaction: $e');
      throw e;
    }
  }

  // Mettre à jour une transaction
  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    try {
      await _transactionsCollection.doc(id).update(transaction.toMap());
    } catch (e) {
      print('Erreur lors de la mise à jour de la transaction: $e');
      throw e;
    }
  }

  // Calculer le solde total
  Stream<double> getTotalBalance() {
    return getTransactions().map((transactions) {
      return transactions.fold(0.0, (total, transaction) {
        if (transaction.type == 'revenu') {
          return total + transaction.amount;
        } else {
          return total - transaction.amount;
        }
      });
    });
  }

  // Obtenir le total des revenus
  Stream<double> getTotalIncome() {
    return getTransactions().map((transactions) {
      return transactions
          .where((transaction) => transaction.type == 'revenu')
          .fold(0.0, (total, transaction) => total + transaction.amount);
    });
  }

  // Obtenir le total des dépenses
  Stream<double> getTotalExpenses() {
    return getTransactions().map((transactions) {
      return transactions
          .where((transaction) => transaction.type == 'dépense')
          .fold(0.0, (total, transaction) => total + transaction.amount);
    });
  }

  // Obtenir les dépenses par catégorie
  Stream<Map<String, double>> getExpensesByCategory() {
    return getTransactions().map((transactions) {
      Map<String, double> categoryTotals = {};
      for (var transaction in transactions) {
        if (transaction.type == 'dépense') {
          categoryTotals[transaction.category] =
              (categoryTotals[transaction.category] ?? 0) + transaction.amount;
        }
      }
      return categoryTotals;
    });
  }
} 