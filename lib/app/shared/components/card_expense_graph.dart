import 'package:flutter/material.dart';

class ExpenseCardGraph extends StatelessWidget {
  const ExpenseCardGraph({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Container(
      child: Center(
        child: Card(
          child: Text('Grafico'),
          elevation: 5,
        ),
      ),
    );
  }
}
