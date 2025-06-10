import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/transaction_service.dart';
import '../utils/constants.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionService = Provider.of<TransactionService>(context);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistiques'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dépenses'),
              Tab(text: 'Revenus'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<Map<String, double>>(
              stream: transactionService.getExpensesByCategory(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildExpensesChart(snapshot.data!);
              },
            ),
            StreamBuilder<Map<String, double>>(
              stream: transactionService.getIncomeByCategory(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildIncomeChart(snapshot.data!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesChart(Map<String, double> expenseData) {
    if (expenseData.isEmpty) {
      return const Center(child: Text('Aucune dépense à afficher'));
    }

    final total = expenseData.values.fold(0.0, (a, b) => a + b);
    final List<PieChartSectionData> sections = [];
    final List<Widget> indicators = [];

    // Couleurs pour les dépenses (tons de rouge)
    final colors = [
      const Color(0xFFE57373),
      const Color(0xFFEF5350),
      const Color(0xFFF44336),
      const Color(0xFFE53935),
      const Color(0xFFD32F2F),
    ];

    int colorIndex = 0;
    expenseData.forEach((category, amount) {
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
            'Répartition des dépenses',
            style: AppTextStyles.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
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
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.expense),
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
  }

  Widget _buildIncomeChart(Map<String, double> incomeData) {
    if (incomeData.isEmpty) {
      return const Center(child: Text('Aucun revenu à afficher'));
    }

    final total = incomeData.values.fold(0.0, (a, b) => a + b);
    final List<PieChartSectionData> sections = [];
    final List<Widget> indicators = [];

    // Couleurs pour les différentes catégories de gains
    final colors = [
      const Color(0xFF4CAF50), // Vert
      const Color(0xFF81C784), // Vert clair
      const Color(0xFFA5D6A7), // Vert très clair
      const Color(0xFF66BB6A), // Vert foncé
    ];

    int colorIndex = 0;
    incomeData.forEach((category, amount) {
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
            'Répartition des revenus',
            style: AppTextStyles.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
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
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.income),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total des revenus:',
                  style: AppTextStyles.bodyLarge,
                ),
                Text(
                  formatAmount(total),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}