import 'package:expenses_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ExpensesDatabase extends ChangeNotifier {
  ExpensesDatabase() {
    _initialize();
  }

  Box<Expense>? _expenseBox;  // Store the Hive box reference for reuse

  Future<void> _initialize() async {
    _expenseBox = await Hive.openBox<Expense>('expenses');
    notifyListeners(); // Notify listeners when initialization is complete
  }

  void addExpense(String title, double amount, DateTime date) async {
    final expense = Expense(name: title, amount: amount, date: date);
    await _expenseBox?.add(expense);  // Add expense to the Hive box

    notifyListeners(); // Notify listeners to update UI
  }

  List<Expense> getAllExpenses() {
    return _expenseBox?.values.toList().cast<Expense>() ?? [];
  }

  void updateExpense(int index, Expense updatedExpense) async {
    await _expenseBox?.putAt(index, updatedExpense);  // Update the expense
    notifyListeners(); // Notify listeners to update UI
  }

  void deleteExpense(int index) async {
    await _expenseBox?.deleteAt(index);  // Delete the expense
    notifyListeners(); // Notify listeners to update UI
  }


  Future<Map<int, double>> calculateMonthlyExpenses(ExpensesDatabase db) async {
  Map<int, double> monthlyTotals = {};

  // Retrieve expenses using the ExpensesDatabase instance
  List<Expense> expenses =  db.getAllExpenses();

  for (var expense in expenses) {
    int month = expense.date.month;

    if (!monthlyTotals.containsKey(month)) {
      monthlyTotals[month] = 0;
    }

    monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
  }

  return monthlyTotals;
}

  @override
  void dispose() {
    _expenseBox?.close();
    super.dispose();
  }
}
