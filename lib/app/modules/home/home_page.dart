import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/modules/home/components/filter_cards.dart';
import 'package:expenses/app/shared/widgets/appbar/appbar_title_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'components/card_expense_money.dart';
import 'components/card_expense_list.dart';

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({Key? key}) : super(key: key);

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  Query? collectionsInstance;
  String? documentId;
  String? transactionsCollectionReference;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userUID = user?.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('transactionsProduction')
        .where('allowedUsers', arrayContainsAny: [userUID]).get();

    if (querySnapshot.docs.isNotEmpty) {
      documentId = querySnapshot.docs.first.id;
      log(documentId!);

      collectionsInstance = FirebaseFirestore.instance
          .collection('transactionsProduction')
          .doc(documentId)
          .collection('samuel_sabrina_transactionsCollection')
          .orderBy('date', descending: true);
    } else {
      log('Usuário não tem permissão para acessar nenhum item');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: size,
          child: const CustomAppBarWidgetTitle(title: 'Despesas Pessoais')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ExpenseCardMoney(),
            FilterCarousel(
              onFilterSelected: (value) {
                if (value == 'Geral') {
                  setState(() {
                    collectionsInstance = FirebaseFirestore.instance
                        .collection('transactionsProduction')
                        .doc(documentId)
                        .collection('samuel_sabrina_transactionsCollection')
                        .orderBy('date', descending: true);
                  });
                } else if (value == 'Comida') {
                  setState(() {
                    collectionsInstance = FirebaseFirestore.instance
                        .collection('transactionsProduction')
                        .doc(documentId)
                        .collection('samuel_sabrina_transactionsCollection')
                        .where('type', isEqualTo: 'Comida')
                        .orderBy('date', descending: true);
                  });
                } else if (value == 'Roupa') {
                  setState(() {
                    collectionsInstance = FirebaseFirestore.instance
                        .collection('transactionsProduction')
                        .doc(documentId)
                        .collection('samuel_sabrina_transactionsCollection')
                        .where('type', isEqualTo: 'Roupa')
                        .orderBy('date', descending: true);
                  });
                } else if (value == 'Ganhos') {
                  setState(() {
                    collectionsInstance = FirebaseFirestore.instance
                        .collection('transactionsProduction')
                        .doc(documentId)
                        .collection('samuel_sabrina_transactionsCollection')
                        .where('type', isEqualTo: 'Ganhos')
                        .orderBy('date', descending: true);
                  });
                } else if (value == 'Outros') {
                  setState(() {
                    collectionsInstance = FirebaseFirestore.instance
                        .collection('transactionsProduction')
                        .doc(documentId)
                        .collection('samuel_sabrina_transactionsCollection')
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
        ),
      ),
    );
  }
}
