import 'package:expenses/app/modules/home/home_page.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expanse App',
      debugShowCheckedModeBanner: false,
      home: const ExpenseHomePage(),
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 20,
            ),
          ),
          fontFamily: 'OpenSans',
          colorScheme:
              ColorScheme.fromSwatch(primarySwatch: Colors.cyan).copyWith(
            secondary: Colors.amber,
          )),
    );
  }
}
