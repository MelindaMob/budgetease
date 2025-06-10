import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_service.dart';
import '../utils/constants.dart';
import 'add_transaction_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    print('Mon UID Firebase : ${user?.uid}');
    final transactionService = Provider.of<TransactionService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BudgetEase'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Mon UID : ${user.uid}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            // Solde actuel
            StreamBuilder<double>(
              stream: transactionService.getTotalBalance(),
              builder: (context, snapshot) {
                final balance = snapshot.data ?? 0.0;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Solde actuel',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatAmount(balance),
                          style: AppTextStyles.titleLarge.copyWith(
                            color: balance >= 0 ? AppColors.income : AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Revenus et dépenses
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<double>(
                    stream: transactionService.getTotalIncome(),
                    builder: (context, snapshot) {
                      final income = snapshot.data ?? 0.0;
                      return _buildSummaryCard(
                        'Revenus',
                        income,
                        AppColors.income,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<double>(
                    stream: transactionService.getTotalExpenses(),
                    builder: (context, snapshot) {
                      final expenses = snapshot.data ?? 0.0;
                      return _buildSummaryCard(
                        'Dépenses',
                        expenses,
                        AppColors.expense,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Boutons de navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
                _buildNavigationButton(
                  context,
                  'Statistiques',
                  Icons.pie_chart,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsScreen(),
                    ),
                  ),
                ),
              ],
            ),
            // Historique des transactions
            const SizedBox(height: 32),
            Expanded(
              child: StreamBuilder<List<TransactionModel>>(
                stream: transactionService.getTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erreur: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final transactions = snapshot.data!;

                  if (transactions.isEmpty) {
                    return const Center(
                      child: Text('Aucune transaction'),
                    );
                  }

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.type == 'revenu'
                                ? AppColors.income
                                : AppColors.expense,
                            child: Icon(
                              transaction.type == 'revenu'
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            transaction.title,
                            style: AppTextStyles.bodyLarge,
                          ),
                          subtitle: Text(
                            '${transaction.category} • ${transaction.date}',
                            style: AppTextStyles.bodyMedium,
                          ),
                          trailing: Text(
                            formatAmount(transaction.amount),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: transaction.type == 'revenu'
                                  ? AppColors.income
                                  : AppColors.expense,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction ajoutée avec succès'),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              formatAmount(amount),
              style: AppTextStyles.titleMedium.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    );
  }
}