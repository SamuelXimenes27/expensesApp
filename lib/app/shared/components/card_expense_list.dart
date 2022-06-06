import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/transaction.dart';

class ExpenseCardList extends StatelessWidget {
  final List<Transaction> transactions;
  final void Function(String)? onRemove;
  const ExpenseCardList({Key? key, required this.transactions, this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return SizedBox(
      height: _size.height * 0.65,
      child: transactions.isEmpty
          ? Column(
              children: [
                Text(
                  'Nenhuma Transaçao Cadastrada!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(
                  height: _size.height * 0.1,
                ),
                SizedBox(
                  height: _size.height * 0.26,
                  child: Image.asset(
                    'assets/images/waiting.png',
                    fit: BoxFit.cover,
                  ),
                )
              ],
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tr = transactions[index];
                return Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: FittedBox(
                          child: Text(
                            ('R\$${tr.value}'),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      tr.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(
                      DateFormat('d MMM y').format(tr.date),
                    ),
                    trailing: IconButton(
                        onPressed: () => onRemove!(tr.id),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        )),
                  ),
                );
              },
            ),
    );
  }
}
