import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const ExpensePieChart({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    int index = 0;

    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          sections: categoryTotals.entries.map((entry) {
            final section = PieChartSectionData(
              value: entry.value,
              title: entry.key,
              radius: 70,
              color: colors[index % colors.length],
            );
            index++;
            return section;
          }).toList(),
        ),
      ),
    );
  }
}