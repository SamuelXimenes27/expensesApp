import 'package:expenses/app/modules/hideMoney/hide_money_page.dart';
import 'package:expenses/app/modules/selectUser/login_page.dart';
import 'package:expenses/app/shared/constants/colors.dart';
import 'package:expenses/app/shared/constants/routes.dart';
import 'package:expenses/app/shared/widgets/form/bottom_sheet_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'modules/home/home_page.dart';

extension ToMaterialColor on Color {
  MaterialColor get asMaterialColor {
    Map<int, Color> shades = [
      50,
      100,
      200,
      300,
      400,
      500,
      600,
      700,
      800,
      900
    ].asMap().map(
        (key, value) => MapEntry(value, withOpacity(1 - (1 - (key + 1) / 10))));

    return MaterialColor(value, shades);
  }
}

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  _AppWidgetState createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  String? selectedUser;
  bool? isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 20,
          ),
        ),
        fontFamily: 'Lexend',
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: ColorsConst.primary.asMaterialColor,
        ).copyWith(
          primary: ColorsConst.primary,
          secondary: ColorsConst.secondary,
          tertiary: ColorsConst.tertiary,
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final User? user = snapshot.data;
            isAuthenticated = user != null;
          }

          return isAuthenticated == true ? AppPage() : const LoginUserPage();
        },
      ),
      onGenerateRoute: RoutesConst.generateRoute,
    );
  }
}

// ignore: must_be_immutable
class AppPage extends StatefulWidget {
  int? selectedIndex;
  AppPage({
    Key? key,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  bool isHideMoneyPage = false;

  static final List<Widget> _widgetOptions = <Widget>[
    const ExpenseHomePage(),
    const HideMoneyPage(),
  ];

  _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        widget.selectedIndex = index;
        isHideMoneyPage = index == 1;
      });
    }
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        context: context,
        builder: (ctx) {
          return const CustomBottomSheetForm(
            isTransaction: true,
          );
        });
  }

  _openLittleBoxFormModal(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        context: context,
        builder: (ctx) {
          return const CustomBottomSheetForm(
            isHideMoney: true,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(widget.selectedIndex!),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.home,
                color: widget.selectedIndex == 0
                    ? Theme.of(context).colorScheme.secondary
                    : null,
              ),
              onPressed: () {
                if (mounted) {
                  _onItemTapped(0);
                }
              },
            ),
            const SizedBox(width: 48.0),
            IconButton(
              icon: Icon(
                color: widget.selectedIndex == 1
                    ? Theme.of(context).colorScheme.secondary
                    : null,
                Icons.monetization_on,
              ),
              onPressed: () {
                if (mounted) {
                  _onItemTapped(1);
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => widget.selectedIndex == 0
            ? _openTransactionFormModal(context)
            : _openLittleBoxFormModal(context),
      ),
    );
  }
}
