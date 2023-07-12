import 'package:flutter/material.dart';

class ExpenseCardGraph extends StatelessWidget {
  const ExpenseCardGraph({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      child: Center(
        child: Card(
          elevation: 5,
          child: Text('Grafico'),
        ),
      ),
    );
  }
}
