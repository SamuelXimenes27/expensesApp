import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/modules/home/components/filter_cards.dart';
import 'package:expenses/app/shared/widgets/appbar/appbar_title_widget.dart';
import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import 'components/card_expense_money.dart';
import 'components/card_expense_list.dart';

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({Key? key}) : super(key: key);

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final collectionRef =
        FirebaseFirestore.instance.collection('transactionCollection');

    final querySnapshot =
        await collectionRef.orderBy('createdAt', descending: true).get();

    final transactions = querySnapshot.docs.map((doc) {
      final data = doc.data();

      final id = doc.id;
      final title = data['title'] as String;
      final value = data['value'] as double;
      final createdAt = data['createdAt'] as Timestamp;

      DateTime date;
      // ignore: unnecessary_null_comparison
      if (createdAt != null) {
        date = createdAt.toDate();
      } else {
        date = DateTime.now();
      }

      return TransactionModel(
        id: id,
        title: title,
        value: value,
        date: date,
      );
    }).toList();

    transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionModel> getRecentTransactions(
      List<TransactionModel> transactions) {
    return transactions.where((tr) {
      return tr.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  Query<Object?>? collectionsInstance =
      FirebaseFirestore.instance.collection('transactionCollection').orderBy(
            'date',
            descending: true,
          );

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
                        .collection('transactionCollection')
                        .orderBy(
                          'date',
                          descending: true,
                        );
                  });
                } else if (value == 'Comida') {
                  setState(() {
                    collectionsInstance = FirebaseFirestore.instance
                        .collection('transactionCollection')
                        .where('type', isEqualTo: 'Comida')
                        .orderBy(
                          'date',
                          descending: true,
                        );
                  });
                } else if (value == 'Roupa') {
                  setState(() {
                    collectionsInstance = FirebaseFirestore.instance
                        .collection('transactionCollection')
                        .orderBy(
                          'date',
                          descending: true,
                        )
                        .where('type', isEqualTo: 'Roupa');
                  });
                } else if (value == 'Ganhos') {
                  setState(() {
                    collectionsInstance = FirebaseFirestore.instance
                        .collection('transactionCollection')
                        .orderBy(
                          'date',
                          descending: true,
                        )
                        .where('type', isEqualTo: 'Ganhos');
                  });
                } else if (value == 'Outros') {
                  setState(() {
                    collectionsInstance = FirebaseFirestore.instance
                        .collection('transactionCollection')
                        .orderBy(
                          'date',
                          descending: true,
                        )
                        .where('type', isEqualTo: 'Outros');
                  });
                }
              },
            ),
            ExpenseCardList(
              expenseCollection: collectionsInstance!,
            ),
          ],
        ),
      ),
    );
  }
}
