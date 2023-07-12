import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/modules/hideMoney/components/card_hide_money_list.dart';
import 'package:expenses/app/modules/hideMoney/components/total_hide_money.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/appbar/appbar_title_widget.dart';

class HideMoneyPage extends StatefulWidget {
  const HideMoneyPage({super.key});

  @override
  State<HideMoneyPage> createState() => _HideMoneyPageState();
}

class _HideMoneyPageState extends State<HideMoneyPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Query<Object?>? collectionsInstance =
        FirebaseFirestore.instance.collection('hideMoneyCollection').orderBy(
              'createdAt',
              descending: false,
            );

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: size,
          child: const CustomAppBarWidgetTitle(title: 'Caixinhas')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TotalHideMoneyWidget(),
            HideMoneyListCards(hideMoneyCollection: collectionsInstance),
          ],
        ),
      ),
    );
  }
}
