import 'dart:math';

import 'package:expenses/app/models/transaction.dart';
import 'package:flutter/material.dart';

import '../../models/transactions.dart';

class ExpenseCardForm extends StatefulWidget {
  final void Function(String, double) onSubmit;

  const ExpenseCardForm({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ExpenseCardForm> createState() => _ExpenseCardFormState();
}

class _ExpenseCardFormState extends State<ExpenseCardForm> {
  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final valueController = TextEditingController();

    var transactionsList = Transactions();

    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Titulo'),
              controller: titleController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Valor (R\$)'),
              controller: valueController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () {
                    final title = titleController.text;
                    final value = double.tryParse(valueController.text) ?? 0.0;
                    widget.onSubmit(title, value);
                  },
                  child: const Text(
                    'Nova Transaçao',
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
