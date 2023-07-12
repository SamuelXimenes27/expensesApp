import 'package:flutter/material.dart';

class ExpenseChartBar extends StatelessWidget {
  const ExpenseChartBar({
    Key? key,
    required this.label,
    required this.percentage,
    required this.value,
  }) : super(key: key);

  final String label;
  final double value;
  final double percentage;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: <Widget>[
        FittedBox(
            child: Text(value.toStringAsFixed(2))
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 60,
          width: 10,
          child: Stack(alignment: Alignment.bottomCenter, children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                color: const Color.fromRGBO(220, 220, 220, 1),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            FractionallySizedBox(
              heightFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            )
          ]),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(label)
      ],
    );
  }
}
