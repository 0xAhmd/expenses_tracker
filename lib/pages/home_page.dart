import 'package:expenses_tracker/components/my_list_tile.dart';
import 'package:expenses_tracker/db/expenses_database.dart';
import 'package:expenses_tracker/graph/bar_graph.dart';
import 'package:expenses_tracker/helper/helpers.dart';
import 'package:expenses_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  Future<Map<int, double>>? _monthlyTotalsFuture;

  @override
  void initState() {
    Provider.of<ExpensesDatabase>(context, listen: false).getAllExpenses();
    refreshBarGraph();
    super.initState();
  }

  void refreshBarGraph() {
    _monthlyTotalsFuture = Provider.of<ExpensesDatabase>(context, listen: false)
        .calculateMonthlyExpenses(
            Provider.of<ExpensesDatabase>(context, listen: false));
  }

  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'New Expense',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _createNewExpenseButton(context),
        ],
      ),
    );
  }

  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Expense',
        ),
        actions: [
          _cancelButton(),
          _deleteExpenseButton(context, expense),
        ],
      ),
    );
  }

  void openEditBox(Expense expense) {
    String existingTitle = expense.name.toString();
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Expense',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: existingTitle),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: amountController,
              decoration: InputDecoration(labelText: existingAmount),
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _editExpenseButton(context, expense),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpensesDatabase>(
      builder: (context, db, child) {
        int startMonth = getStartMonth(db.getAllExpenses());
        int startYear = getStartYear(db.getAllExpenses());
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        int monthCount = calculateMonthCount(
            startYear, startMonth, currentYear, currentMonth);
        final expenses = db.getAllExpenses();
        return Scaffold(
          backgroundColor: Colors.grey.shade300,
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final monthlyTotals = snapshot.data!;
                        List<double> monthlySummary = List.generate(
                            monthCount,
                            (index) =>
                                monthlyTotals[startMonth + index] ?? 0.0);
                        return MyBarGraph(
                            monthlyExpenses: monthlySummary,
                            startMonth: startMonth);
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final singleExpense = expenses[index];
                      return MyListTile(
                        onDeletePressed: (context) => openDeleteBox(
                            singleExpense), // Pass the function as a callback
                        onEditPressed: (context) => openEditBox(
                            singleExpense), // Pass the function as a callback
                        title: singleExpense.name,
                        trailing: singleExpense.amount.toString(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);
        titleController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  Widget _createNewExpenseButton(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        if (amountController.text.isNotEmpty &&
            titleController.text.isNotEmpty) {
          Navigator.pop(context);
          final db = Provider.of<ExpensesDatabase>(context, listen: false);
          db.addExpense(
            titleController.text,
            convertToDouble(amountController.text),
            DateTime.now(),
          );
          refreshBarGraph();

          titleController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  Widget _editExpenseButton(BuildContext context, Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (amountController.text.isNotEmpty &&
            titleController.text.isNotEmpty) {
          Navigator.pop(context);

          final db = Provider.of<ExpensesDatabase>(context, listen: false);
          Expense updatedExpense = Expense(
            name: titleController.text,
            amount: convertToDouble(amountController.text),
            date: DateTime.now(),
          );

          int index = db.getAllExpenses().indexOf(expense);
          if (index != -1) {
            db.updateExpense(index, updatedExpense);
          }
          refreshBarGraph();

          titleController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  Widget _deleteExpenseButton(BuildContext context, Expense expense) {
    return MaterialButton(
      onPressed: () async {
        final db = Provider.of<ExpensesDatabase>(context, listen: false);
        int index = db.getAllExpenses().indexOf(expense);
        if (index != -1) {
          db.deleteExpense(index); // Delete the expense from the database
        }
        Navigator.pop(context);
        refreshBarGraph();
// Close the dialog after deletion
      },
      child: const Text('Delete'),
    );
  }
}
