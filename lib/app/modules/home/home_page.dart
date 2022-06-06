import 'package:expenses/app/shared/strings/all_strings.dart';
import 'package:flutter/material.dart';

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
      ),
    );
  }
}
