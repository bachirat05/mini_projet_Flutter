import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';

//  Camembert dépenses par catégorie 
class ExpensePieChart extends StatefulWidget {
  final Map<String, double> data; // catégorie → montant

  const ExpensePieChart({super.key, required this.data});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Aucune dépense ce mois-ci',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final total   = widget.data.values.fold(0.0, (a, b) => a + b);
    final entries = widget.data.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response?.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        response!.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: List.generate(entries.length, (i) {
                final isTouched = i == _touchedIndex;
                final color     = AppCategories.getColor(entries[i].key);
                final pct       = entries[i].value / total * 100;
                return PieChartSectionData(
                  color:  color,
                  value:  entries[i].value,
                  title:  '${pct.toStringAsFixed(0)}%',
                  radius: isTouched ? 72 : 58,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
              sectionsSpace:     3,
              centerSpaceRadius: 34,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Légende
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: entries.map((e) {
            final color = AppCategories.getColor(e.key);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10, height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  '${e.key} (${e.value.toStringAsFixed(0)} MAD)',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

//  Barres revenus vs dépenses 
class IncomeExpenseBarChart extends StatelessWidget {
  final double income;
  final double expense;

  const IncomeExpenseBarChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = (income > expense ? income : expense) * 1.25;

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 100 : maxY,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(
                toY:    income,
                color:  AppColors.income,
                width:  44,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                toY:    expense,
                color:  AppColors.expense,
                width:  44,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ]),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final labels = ['Revenus', 'Dépenses'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),
            leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData:   const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}