import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../theme/theme_provider.dart';
import '../services/pdf_service.dart';
import '../widgets/pie_chart_widget.dart';

import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';
import 'statistics_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> filteredExpenses = [];

  double totalBalance = 0;
  Map<String, double> categoryTotals = {};

  final TextEditingController searchController = TextEditingController();

  String selectedFilter = "All";
  String selectedSort = "Newest";

  double monthlyBudget = 50000;

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final data = await DatabaseHelper.instance.getExpenses();

    double total = 0;
    Map<String, double> map = {};

    for (var e in data) {
      final amount = (e['amount'] as num).toDouble();
      total += amount;

      map[e['category']] = (map[e['category']] ?? 0) + amount;
    }

    if (!mounted) return;

    setState(() {
      expenses = data;
      filteredExpenses = data;
      totalBalance = total;
      categoryTotals = map;
    });

    sortExpenses(selectedSort);
  }

  void searchExpense(String keyword) {
    List<Map<String, dynamic>> list = List.from(expenses);

    list = list
        .where((e) => e['title']
            .toString()
            .toLowerCase()
            .contains(keyword.toLowerCase()))
        .toList();

    setState(() {
      filteredExpenses = list;
    });

    sortExpenses(selectedSort);
  }

  void sortExpenses(String type) {
    selectedSort = type;

    List<Map<String, dynamic>> list = List.from(filteredExpenses);

    if (type == "Newest") {
      list.sort((a, b) => b['id'].compareTo(a['id']));
    } else if (type == "Oldest") {
      list.sort((a, b) => a['id'].compareTo(b['id']));
    } else if (type == "Highest") {
      list.sort((a, b) =>
          (b['amount'] as num).compareTo(a['amount'] as num));
    } else if (type == "Lowest") {
      list.sort((a, b) =>
          (a['amount'] as num).compareTo(b['amount'] as num));
    }

    setState(() {
      filteredExpenses = list;
    });
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),

        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StatisticsScreen(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              PdfService.generateExpenseReport(expenses);
            },
          ),

          Consumer<ThemeProvider>(
            builder: (context, theme, child) {
              return IconButton(
                icon: Icon(
                  theme.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: theme.toggleTheme,
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          );
          loadExpenses();
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Total: Rs. ${totalBalance.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(height: 20),                if (categoryTotals.isNotEmpty)
                  ExpensePieChart(
                    categoryTotals: categoryTotals,
                  ),

                const SizedBox(height: 20),                TextField(
                  controller: searchController,
                  onChanged: searchExpense,
                  decoration: const InputDecoration(
                    hintText: "Search Expense",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),                DropdownButton<String>(
                  value: selectedSort,
                  items: const [
                    DropdownMenuItem(
                        value: "Newest", child: Text("Newest")),
                    DropdownMenuItem(
                        value: "Oldest", child: Text("Oldest")),
                    DropdownMenuItem(
                        value: "Highest", child: Text("Highest")),
                    DropdownMenuItem(
                        value: "Lowest", child: Text("Lowest")),
                  ],
                  onChanged: (v) {
                    if (v != null) sortExpenses(v);
                  },
                ),

                const SizedBox(height: 20),                const Text(
                  "Recent Expenses",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final e = filteredExpenses[index];

                    return Card(
                      child: ListTile(
                        title: Text(e['title']),
                        subtitle: Text(e['category']),
                        trailing: Text("Rs. ${e['amount']}"),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditExpenseScreen(expense: e),
                            ),
                          );
                          loadExpenses();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}