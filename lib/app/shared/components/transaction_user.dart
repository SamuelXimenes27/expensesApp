import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import 'card_expense_form.dart';
import 'card_expense_list.dart';

class TransactionUser extends StatefulWidget {
  const TransactionUser({Key? key}) : super(key: key);

  @override
  State<TransactionUser> createState() => _TransactionUserState();
}

class _TransactionUserState extends State<TransactionUser> {
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
    )
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ExpenseCardList(transactions: _transactions),
        ExpenseCardForm(onSubmit: _addTransaction),
      ],
    );
  }
}
