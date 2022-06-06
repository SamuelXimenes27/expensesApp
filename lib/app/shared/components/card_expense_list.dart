import 'package:flutter/material.dart';

import '../../models/transactions.dart';

class ExpenseCardList extends StatelessWidget {
  const ExpenseCardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    var transactionsList = Transactions();

    return Center(
        child: Column(
      children: transactionsList.transactions.map((tr) {
        return Card(
          child: Row(children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Text(
                tr.value.toString(),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  tr.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tr.date.toString(),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ],
            )
          ]),
        );
      }).toList(),
    ));
  }
}
