import 'package:flutter/material.dart';

import '../../shared/components/card_expense_graph.dart';
import '../../shared/components/card_expense_list.dart';
import '../../shared/strings/all_strings.dart';

class ExpenseHomePage extends StatelessWidget {
  const ExpenseHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(StringConst.appBarTitle),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpenseCardGraph(),
            ExpenseCardList(),
          ],
        ),
      ),
    );
  }
}
