import 'package:expenses_tracker/models/expense_model.dart';
import 'package:intl/intl.dart';

double convertToDouble(String value) {
  double? amount = double.tryParse(value);
  return amount ?? 0.0;
}

String formatCurrency(double amount) {
  return NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2)
      .format(amount);
}



int getStartMonth(List<Expense> expenses) {
  if (expenses.isEmpty) {
    return DateTime.now().month;
  }
  expenses.sort(
    (a, b) => a.date.compareTo(b.date),
  );
  return expenses.first.date.month;
}


int getStartYear(List<Expense> expenses) {
  if (expenses.isEmpty) {
    return DateTime.now().year;
  }
  expenses.sort(
    (a, b) => a.date.compareTo(b.date),
  );
  return expenses.first.date.year;
}



int calculateMonthCount(int startYear , startMonth , currentYear , currentMonth) {
  int monthCount = (currentYear - startYear) * 12 + (currentMonth - startMonth) + 1;

  return monthCount;
}