import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/savings_goal_service.dart';
import '../models/savings_goal_model.dart';
import '../utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savingsGoalService = Provider.of<SavingsGoalService>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Objectifs d\'Épargne'),
      ),
      body: StreamBuilder<List<SavingsGoalModel>>(
        stream: savingsGoalService.getGoals(),
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

          final goals = snapshot.data!;

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Aucun objectif d\'épargne',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddGoalDialog(context, user),
                    child: const Text('Créer un objectif'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            'ID: ${goal.id}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'Objectif: ${formatAmount(goal.targetAmount)}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      trailing: Text(
                        '${goal.progressPercentage.toStringAsFixed(1)}%',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: goal.progressPercentage / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatAmount(goal.currentAmount),
                                style: AppTextStyles.bodyMedium,
                              ),
                              Text(
                                formatAmount(goal.targetAmount),
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ButtonBar(
                      children: [
                        TextButton(
                          onPressed: () => _showAddSavingsDialog(
                            context,
                            goal,
                            savingsGoalService,
                          ),
                          child: const Text('Ajouter'),
                        ),
                        TextButton(
                          onPressed: () => _showWithdrawSavingsDialog(
                            context,
                            goal,
                            savingsGoalService,
                          ),
                          child: const Text('Retirer'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context, user),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, User? user) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvel objectif d\'épargne'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant objectif',
                  border: OutlineInputBorder(),
                  prefixText: '€ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate() && user != null) {
                final goal = SavingsGoalModel(
                  userId: user.uid,
                  title: titleController.text,
                  targetAmount: double.parse(amountController.text),
                  currentAmount: 0,
                  createdAt: DateTime.now(),
                );

                final service = Provider.of<SavingsGoalService>(
                  context,
                  listen: false,
                );

                service.createGoal(goal).then((_) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Objectif créé avec succès'),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showAddSavingsDialog(
    BuildContext context,
    SavingsGoalModel goal,
    SavingsGoalService service,
  ) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter de l\'épargne'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Montant',
              border: OutlineInputBorder(),
              prefixText: '€ ',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un montant';
              }
              if (double.tryParse(value) == null) {
                return 'Veuillez entrer un nombre valide';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                service
                    .addSavings(
                  goal.id!,
                  double.parse(amountController.text),
                )
                    .then((_) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Épargne ajoutée avec succès'),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawSavingsDialog(
    BuildContext context,
    SavingsGoalModel goal,
    SavingsGoalService service,
  ) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer de l\'épargne'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Montant',
              border: OutlineInputBorder(),
              prefixText: '€ ',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un montant';
              }
              if (double.tryParse(value) == null) {
                return 'Veuillez entrer un nombre valide';
              }
              final amount = double.parse(value);
              if (amount > goal.currentAmount) {
                return 'Montant supérieur à l\'épargne disponible';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                service
                    .withdrawSavings(
                  goal.id!,
                  double.parse(amountController.text),
                )
                    .then((_) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Retrait effectué avec succès'),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }
} 