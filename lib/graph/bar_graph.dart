import 'package:expenses_tracker/graph/single_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlyExpenses;
  final int startMonth;

  const MyBarGraph(
      {super.key, required this.monthlyExpenses, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<SingleBar> barData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd());
  }

  void initializeBarData() {
    barData = List.generate(
        widget.monthlyExpenses.length,
        (index) =>
            SingleBar(xValue: index, yValue: widget.monthlyExpenses[index]));
  }

  double calculateMax() {
    double max = 500;
    widget.monthlyExpenses.sort();

    max = widget.monthlyExpenses.last * 1.05;

    if (max < 500) {
      return 500;
    } else {
      return max;
    }
  }

  final ScrollController _scrollController = ScrollController();

  void scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    double barWidth = 15;
    double spacing = 25;
    initializeBarData();

    // Set the maxY to be slightly higher than the highest value to give some space above the bars

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: SizedBox(
          width: barWidth * barData.length + spacing * (barData.length - 1),
          child: BarChart(
            BarChartData(
                minY: 0,
                maxY: calculateMax(), // Use dynamic maxY
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  show: true,
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        reservedSize: 24,
                        showTitles: true,
                        getTitlesWidget: getBottomTitle),
                  ),
                ),
                barGroups: barData
                    .map(
                      (data) => BarChartGroupData(
                        x: data.xValue,
                        barRods: [
                          BarChartRodData(
                            toY: data.yValue,
                            width: barWidth,
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey.shade800,
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: calculateMax(),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                alignment: BarChartAlignment.end,
                groupsSpace: spacing),
          ),
        ),
      ),
    );
  }
}

Widget getBottomTitle(double value, TitleMeta meta) {
  const textStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  String text;
  switch (value.toInt() % 12) {
    case 0:
      text = 'J'; // January
      break;
    case 1:
      text = 'F'; // February
      break;
    case 2:
      text = 'M'; // March
      break;
    case 3:
      text = 'A'; // April
      break;
    case 4:
      text = 'M'; // May
      break;
    case 5:
      text = 'J'; // June
      break;
    case 6:
      text = 'J'; // July
      break;
    case 7:
      text = 'A'; // August
      break;
    case 8:
      text = 'S'; // September
      break;
    case 9:
      text = 'O'; // October
      break;
    case 10:
      text = 'N'; // November
      break;
    case 11:
      text = 'D'; // December
      break;
    default:
      text = '';
      break;
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(text, style: textStyle),
  );
}
