import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import 'package:intl/intl.dart';

import 'chart_bar.dart';

class ExpanseChart extends StatelessWidget {
  const ExpanseChart({Key? key, required this.recentTransactions})
      : super(key: key);

  final List<Transaction> recentTransactions;

  List<Map<String, Object>> get groupedTransactions {
    return List.generate(
      7,
      (index) {
        final weekDay = DateTime.now().subtract(
          Duration(days: index),
        );

        double totalSum = 0.0;

        for (var i = 0; i < recentTransactions.length; i++) {
          bool sameDay = recentTransactions[i].date.day == weekDay.day;
          bool sameMonth = recentTransactions[i].date.month == weekDay.month;
          bool sameYear = recentTransactions[i].date.year == weekDay.year;

          if (sameDay && sameMonth && sameYear) {
            totalSum += recentTransactions[i].value;
          }
        }

        // debugPrint(DateFormat.E().format(weekDay)[0]);
        // debugPrint(totalSum.toString());

        return {
          'day': DateFormat.E().format(weekDay).toUpperCase()[0],
          'value': totalSum,
        };
      },
    ).reversed.toList();
  }

  double get _weekTotalValue {
    return groupedTransactions.fold(0.0, (sum, tr) {
      return sum + (tr['value'] as double);
    });
  }

  @override
  Widget build(BuildContext context) {
    groupedTransactions;
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: groupedTransactions.map(
            (tr) {
              return Flexible(
                fit: FlexFit.tight,
                child: ExpanseChartBar(
                  label: tr['day'] as String,
                  value: tr['value'] as double,
                  percentage: recentTransactions.isEmpty
                      ? 0
                      : (tr['value'] as double) / _weekTotalValue,
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
