import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseCardForm extends StatefulWidget {
  final void Function(String, double, DateTime) onSubmit;

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

  DateTime? _selectedDate;

  _submitForm() {
    final title = titleController.text;
    final value = double.tryParse(valueController.text) ?? 0.0;

    if (title.isEmpty || value <= 0) {
      return;
    }

    widget.onSubmit(title, value, _selectedDate!);
  }

  _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        _selectedDate = pickedDate;
      });
    });
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
            SizedBox(
              height: 70,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Nenhuma data selecionada!'
                          : 'Data Selecionada: ${DateFormat('dd/MM/y').format(_selectedDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _showDatePicker,
                    child: const Text(
                      'Selecionar Data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                OutlinedButton(
                  onPressed: _submitForm,
                  child: const Text(
                    'Nova Transaçao',
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
