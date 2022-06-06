import 'dart:math';

import 'package:expenses/app/shared/components/card_expense_form.dart';
import 'package:expenses/app/shared/components/chart.dart';
import 'package:country_icons/country_icons.dart';
import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import '../../shared/components/card_expense_graph.dart';
import '../../shared/components/card_expense_list.dart';
import '../../shared/strings/all_strings.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({Key? key}) : super(key: key);

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  @override
  void initState() {
    super.initState();
  }

  final List<Transaction> _transactions = [
    Transaction(
      id: 't0',
      title: "Conta Vencida",
      value: 400.60,
      date: DateTime.now().subtract(const Duration(days: 33)),
    ),
    Transaction(
      id: 't1',
      title: "Conta de Luz",
      value: 289.60,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't2',
      title: "Conta de Agua",
      value: 80.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: 't3',
      title: "Fatura Itau",
      value: 793.13,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Transaction(
      id: 't4',
      title: "Fatura Nubank",
      value: 32.89,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: 't4',
      title: "Fatura C6",
      value: 65.89,
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Transaction(
      id: 't4',
      title: "Fatura BB",
      value: 324.89,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<Transaction> get _recentTransaction {
    return _transactions.where((tr) {
      return tr.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return ExpenseCardForm(onSubmit: _addTransaction);
        });
  }

  @override
  Widget build(BuildContext context) {
    // bool languageApp = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text(StringConst.appBarTitle),
        actions: [
          // IconButton(
          //   icon:
          //       Image.asset('icons/flags/png/us.png', package: 'country_icons'),
          //   onPressed: () {
          //     setState(() {
          //       if (languageApp == true) {
          //         languageApp = true;
          //         Intl.defaultLocale = 'pt_BR';
          //         initializeDateFormatting('pt_BR', null);
          //         Image.asset('icons/flags/png/br.png',
          //             package: 'country_icons');
          //         debugPrint(languageApp.toString());
          //       } else if (languageApp == true) {
          //         languageApp = false;
          //         // Intl.defaultLocale = 'us';
          //         // initializeDateFormatting('us', null);
          //       }
          //     });
          //   },
          // ),
          IconButton(
            onPressed: () => _openTransactionFormModal(context),
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpanseChart(recentTransactions: _recentTransaction),
            ExpenseCardList(
                transactions: _transactions, onRemove: _removeTransaction),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _openTransactionFormModal(context),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
