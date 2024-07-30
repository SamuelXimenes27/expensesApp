import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TotalHideMoneyWidget extends StatefulWidget {
  const TotalHideMoneyWidget({
    super.key,
  });

  @override
  State<TotalHideMoneyWidget> createState() => _TotalHideMoneyWidgetState();
}

class _TotalHideMoneyWidgetState extends State<TotalHideMoneyWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hideMoneyCollection')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Acumulado'),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 50),
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            );
          }

          // ignore: unused_local_variable
          double totalValue = 0;

          if (snapshot.hasData) {
            final collections = snapshot.data!.docs;
            for (final collection in collections) {
              final collectionData = collection.data() as Map<String, dynamic>;
              final stats = collectionData['stats'] as String;

              if (stats != 'closed') {
                final transactions =
                    collectionData['transactions'] as List<dynamic>;

                for (final transaction in transactions) {
                  final transactionData = transaction as Map<String, dynamic>;

                  final value = transactionData['value'];
                  totalValue += value;
                }
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Acumulado'),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    '${totalValue.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
