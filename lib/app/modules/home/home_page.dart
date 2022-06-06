import 'dart:math';

import 'package:expenses/app/shared/components/card_expense_form.dart';
import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import '../../shared/components/card_expense_graph.dart';
import '../../shared/components/card_expense_list.dart';
import '../../shared/strings/all_strings.dart';

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

  final _transactions = [
    Transaction(
      id: 't1',
      title: "Conta de Luz",
      value: 289.60,
      date: DateTime(2022, 4, 5),
    ),
    Transaction(
      id: 't2',
      title: "Conta de Agua",
      value: 80.00,
      date: DateTime(2022, 3, 7),
    ),
    Transaction(
      id: 't3',
      title: "Fatura Itau",
      value: 1793.13,
      date: DateTime(2022, 5, 25),
    ),
    Transaction(
      id: 't4',
      title: "Fatura Nubank",
      value: 4326.89,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't4',
      title: "Fatura Nubank",
      value: 4326.89,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't4',
      title: "Fatura Nubank",
      value: 4326.89,
      date: DateTime.now(),
    ),
  ];

  _addTransaction(String title, double value) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: DateTime.now(),
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(StringConst.appBarTitle),
        actions: [
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
            const ExpenseCardGraph(),
            ExpenseCardList(transactions: _transactions),
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
