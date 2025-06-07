import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/savings_goal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavingsGoalService {
  final CollectionReference _goalsCollection =
      FirebaseFirestore.instance.collection('savings_goals');

  // Créer un nouvel objectif
  Future<void> createGoal(SavingsGoalModel goal) async {
    try {
      await _goalsCollection.add(goal.toMap());
    } catch (e) {
      print('Erreur lors de la création de l\'objectif: $e');
      throw e;
    }
  }

  // Obtenir tous les objectifs de l'utilisateur connecté
  Stream<List<SavingsGoalModel>> getGoals() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _goalsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SavingsGoalModel.fromFirestore(doc))
          .toList();
    });
  }

  // Mettre à jour le montant actuel
  Future<void> updateCurrentAmount(String goalId, double newAmount) async {
    try {
      await _goalsCollection.doc(goalId).update({
        'currentAmount': newAmount,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du montant: $e');
      throw e;
    }
  }

  // Ajouter de l'épargne
  Future<void> addSavings(String goalId, double amount) async {
    try {
      print("ID utilisé pour l'ajout d'épargne : $goalId");
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docRef = _goalsCollection.doc(goalId);
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          throw Exception('L\'objectif n\'existe pas');
        }
        
        final data = snapshot.data() as Map<String, dynamic>;
        final raw = data['currentAmount'];
        final currentAmount = (raw is int)
            ? raw.toDouble()
            : (raw is double ? raw : 0.0);
        transaction.update(docRef, {
          'currentAmount': currentAmount + amount,
        });
      });
    } catch (e) {
      print('Erreur lors de l\'ajout d\'épargne: $e');
      throw e;
    }
  }

  // Retirer de l'épargne
  Future<void> withdrawSavings(String goalId, double amount) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docRef = _goalsCollection.doc(goalId);
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          throw Exception('L\'objectif n\'existe pas');
        }
        
        final data = snapshot.data() as Map<String, dynamic>;
        final raw = data['currentAmount'];
        final currentAmount = (raw is int)
            ? raw.toDouble()
            : (raw is double ? raw : 0.0);
        if (currentAmount < amount) {
          throw Exception('Montant insuffisant');
        }
        
        transaction.update(docRef, {
          'currentAmount': currentAmount - amount,
        });
      });
    } catch (e) {
      print('Erreur lors du retrait d\'épargne: $e');
      throw e;
    }
  }

  // Supprimer un objectif
  Future<void> deleteGoal(String goalId) async {
    try {
      await _goalsCollection.doc(goalId).delete();
    } catch (e) {
      print('Erreur lors de la suppression de l\'objectif: $e');
      throw e;
    }
  }
} 