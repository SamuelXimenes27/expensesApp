import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/bloc/transaction_bloc.dart';
import 'package:expenses/app/modules/home/components/filter_cards.dart';
import 'package:expenses/app/shared/widgets/appbar/appbar_title_widget.dart';
import 'package:flutter/material.dart';

import '../../bloc/user_authentication_bloc.dart';
import '../../bloc/utils_bloc.dart';
import 'components/card_expense_money.dart';
import 'components/card_expense_list.dart';

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({Key? key}) : super(key: key);

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final transactionBloc = TransactionBloC();
  final authBloc = AuthenticationBloC();
  final utils = Utils();

  Query? collectionsInstance;
  String? documentId = '';
  String? userNameCollection = '';
  Future<UserData>? userData;

  @override
  void initState() {
    super.initState();
    userData = transactionBloc.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: size,
          child: const CustomAppBarWidgetTitle(title: 'Despesas Pessoais')),
      body: SingleChildScrollView(
        child: FutureBuilder<UserData>(
          future: userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: EdgeInsets.only(top: size.height * 0.4),
                child: const Column(
                  children: [
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(top: size.height * 0.25),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      Text('Erro ao carregar os dados'),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              UserData data = snapshot.data!;

              return Column(
                children: [
                  const ExpenseCardMoney(),
                  FilterCarousel(
                    onFilterSelected: (value) {
                      if (value == 'Geral') {
                        log(data.collectionName!);
                        log(data.transactionsCollectionName!);
                        data.collectionsInstance;
                      } else if (value == 'Comida') {
                        setState(() {
                          collectionsInstance = FirebaseFirestore.instance
                              .collection('transactionsProduction')
                              .doc(data.collectionName)
                              .collection(data.transactionsCollectionName!)
                              .where('type', isEqualTo: 'Comida')
                              .orderBy('date', descending: true);
                        });
                      } else if (value == 'Roupa') {
                        setState(() {
                          collectionsInstance = FirebaseFirestore.instance
                              .collection('transactionsProduction')
                              .doc(data.collectionName)
                              .collection(data.transactionsCollectionName!)
                              .where('type', isEqualTo: 'Roupa')
                              .orderBy('date', descending: true);
                        });
                      } else if (value == 'Ganhos') {
                        setState(() {
                          collectionsInstance = FirebaseFirestore.instance
                              .collection('transactionsProduction')
                              .doc(data.collectionName)
                              .collection(data.transactionsCollectionName!)
                              .where('type', isEqualTo: 'Ganhos')
                              .orderBy('date', descending: true);
                        });
                      } else if (value == 'Outros') {
                        setState(() {
                          collectionsInstance = FirebaseFirestore.instance
                              .collection('transactionsProduction')
                              .doc(data.collectionName)
                              .collection(data.transactionsCollectionName!)
                              .where('type', isEqualTo: 'Outros')
                              .orderBy('date', descending: true);
                        });
                      }
                    },
                  ),
                  if (collectionsInstance != null) ...[
                    ExpenseCardList(
                      expenseCollection: collectionsInstance!,
                    ),
                  ],
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
