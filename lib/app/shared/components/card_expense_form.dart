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
  final titleController = TextEditingController();

  final valueController = TextEditingController();

  var transactionsList = Transactions();

  _submitForm() {
    final title = titleController.text;
    final value = double.tryParse(valueController.text) ?? 0.0;

    if (title.isEmpty || value <= 0) {
      return;
    }

    widget.onSubmit(title, value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Titulo'),
              controller: titleController,
              onSubmitted: (_) => _submitForm(),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Valor (R\$)'),
              controller: valueController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _submitForm(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                OutlinedButton(
                  onPressed: _submitForm,
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
