import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/transaction_service.dart';
import '../utils/constants.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionService = Provider.of<TransactionService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: StreamBuilder<Map<String, double>>(
        stream: transactionService.getExpensesByCategory(),
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

          final expensesByCategory = snapshot.data!;
          
          if (expensesByCategory.isEmpty) {
            return const Center(
              child: Text('Aucune dépense à afficher'),
            );
          }

          final total = expensesByCategory.values.fold(0.0, (a, b) => a + b);
          final List<PieChartSectionData> sections = [];
          final List<Widget> indicators = [];

          // Couleurs pour les différentes catégories
          final colors = [
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.teal,
            Colors.pink,
            Colors.amber,
          ];

          int colorIndex = 0;
          expensesByCategory.forEach((category, amount) {
            final percentage = (amount / total * 100).toStringAsFixed(1);
            final color = colors[colorIndex % colors.length];

            sections.add(
              PieChartSectionData(
                color: color,
                value: amount,
                title: '$percentage%',
                radius: 150,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );

            indicators.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category,
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                    Text(
                      formatAmount(amount),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );

            colorIndex++;
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Répartition des dépenses par catégorie',
                  style: AppTextStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Légende',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 16),
                ...indicators,
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total des dépenses:',
                        style: AppTextStyles.bodyLarge,
                      ),
                      Text(
                        formatAmount(total),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 