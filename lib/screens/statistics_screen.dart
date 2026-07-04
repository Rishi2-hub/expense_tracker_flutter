import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/pie_chart_widget.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() =>
      _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Map<String, dynamic>> expenses = [];

  double total = 0;
  double highestExpense = 0;
  double lowestExpense = 0;
  double averageExpense = 0;

  Map<String, double> categoryTotals = {};

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    final data = await DatabaseHelper.instance.getExpenses();

    double sum = 0;
    double highest = 0;
    double lowest = 0;

    Map<String, double> categories = {};

    if (data.isNotEmpty) {
      lowest = (data.first['amount'] as num).toDouble();
    }

    for (var expense in data) {
      double amount = (expense['amount'] as num).toDouble();

      sum += amount;

      if (amount > highest) {
        highest = amount;
      }

      if (amount < lowest) {
        lowest = amount;
      }

      String category = expense['category'];

      categories[category] =
          (categories[category] ?? 0) + amount;
    }

    if (!mounted) return;

    setState(() {
      expenses = data;
      total = sum;
      highestExpense = highest;
      lowestExpense = lowest;
      averageExpense =
          data.isEmpty ? 0 : sum / data.length;
      categoryTotals = categories;
    });
  }

  Widget infoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Statistics"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            infoCard(
              "Total Expenses",
              "Rs. ${total.toStringAsFixed(2)}",
              Icons.account_balance_wallet,
              Colors.blue,
            ),

            infoCard(
              "Highest Expense",
              "Rs. ${highestExpense.toStringAsFixed(2)}",
              Icons.trending_up,
              Colors.red,
            ),

            infoCard(
              "Lowest Expense",
              "Rs. ${lowestExpense.toStringAsFixed(2)}",
              Icons.trending_down,
              Colors.orange,
            ),

            infoCard(
              "Average Expense",
              "Rs. ${averageExpense.toStringAsFixed(2)}",
              Icons.bar_chart,
              Colors.green,
            ),

            infoCard(
              "Total Entries",
              expenses.length.toString(),
              Icons.receipt_long,
              Colors.purple,
            ),

            const SizedBox(height: 25),

            if (categoryTotals.isNotEmpty) ...[

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Category Distribution",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              ExpensePieChart(
                categoryTotals: categoryTotals,
              ),

              const SizedBox(height: 25),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Category Totals",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              ...categoryTotals.entries.map(
                (entry) => Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.category),
                    ),
                    title: Text(entry.key),
                    trailing: Text(
                      "Rs. ${entry.value.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text(
                  "No Expense Data Available",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}