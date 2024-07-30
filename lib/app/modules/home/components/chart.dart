import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../models/transaction.dart';
import 'chart_bar.dart';

class ExpanseChart extends StatefulWidget {
  const ExpanseChart({Key? key, required this.recentTransactions})
      : super(key: key);

  final List<TransactionModel> recentTransactions;

  @override
  _ExpanseChartState createState() => _ExpanseChartState();
}

class _ExpanseChartState extends State<ExpanseChart> {
  List<Map<String, Object>> _groupedTransactions = [];

  @override
  void initState() {
    super.initState();
    _updateGroupedTransactions();
  }

  @override
  void didUpdateWidget(covariant ExpanseChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateGroupedTransactions();
  }

  void _updateGroupedTransactions() {
    initializeDateFormatting('pt_BR');

    final groupedTransactions = List.generate(
      7,
      (index) {
        final weekDay = DateTime.now().subtract(
          Duration(days: index),
        );

        double totalSum = 0.0;

        for (var i = 0; i < widget.recentTransactions.length; i++) {
          bool sameDay = widget.recentTransactions[i].date.day == weekDay.day;
          bool sameMonth =
              widget.recentTransactions[i].date.month == weekDay.month;
          bool sameYear =
              widget.recentTransactions[i].date.year == weekDay.year;

          if (sameDay && sameMonth && sameYear) {
            totalSum += widget.recentTransactions[i].value;
          }
        }

        return {
          'day': DateFormat.E('pt_BR').format(weekDay).toUpperCase()[0],
          'value': totalSum,
        };
      },
    ).reversed.toList();

    setState(() {
      _groupedTransactions = groupedTransactions;
    });
  }

  double get _weekTotalValue {
    return _groupedTransactions.fold(0.0, (sum, tr) {
      return sum + (tr['value'] as double);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _groupedTransactions.map(
            (tr) {
              return Flexible(
                fit: FlexFit.tight,
                child: ExpenseChartBar(
                  label: tr['day'] as String,
                  value: tr['value'] as double,
                  percentage: widget.recentTransactions.isEmpty
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
