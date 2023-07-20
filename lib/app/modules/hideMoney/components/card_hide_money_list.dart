import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/modules/hideMoney/details_hide_money_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }

  return text[0].toUpperCase() + text.substring(1);
}

class HideMoneyListCards extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final hideMoneyCollection;

  const HideMoneyListCards({
    super.key,
    this.hideMoneyCollection,
  });

  @override
  State<HideMoneyListCards> createState() => _HideMoneyListCardsState();
}

class _HideMoneyListCardsState extends State<HideMoneyListCards> {
  final List<Color> cardColors = [
    Colors.purple,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.indigo,
    Colors.green,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.pink,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.hideMoneyCollection.snapshots(),
      builder: (context, snapshot) {
        final size = MediaQuery.of(context).size;
        initializeDateFormatting('pt_BR', null);

        if (snapshot.hasError) {
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
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.only(top: size.height * 0.25),
            child: const Column(
              children: [
                Center(
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Carregando suas caixinhas...'),
                )
              ],
            ),
          );
        }

        final hideMoneyDocs = snapshot.data!.docs;

        if (hideMoneyDocs.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: size.height * 0.25),
            child: const Center(child: Text('Sem caixinhas no momento.')),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 5, top: 10),
              child: Text(
                'Suas Caixinhas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: hideMoneyDocs.length,
                itemBuilder: (context, index) {
                  final collectionData =
                      hideMoneyDocs[index].data() as Map<String, dynamic>;

                  final transactions =
                      collectionData['transactions'] as List<dynamic>;

                  double totalValue = 0;

                  for (final transaction in transactions) {
                    final transactionData = transaction as Map<String, dynamic>;

                    final value = transactionData['value'];
                    totalValue += value;
                  }

                  final cardColorIndex = index % cardColors.length;
                  final cardColor = cardColors[cardColorIndex];

                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsHideMoneyPage(
                            title: collectionData['title'],
                            description: collectionData['description'],
                            hideMoneyItemId: hideMoneyDocs[index].id,
                            transactions: transactions,
                            stats: collectionData['stats'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: collectionData['stats'] == 'closed'
                          ? Colors.grey[300]
                          : null,
                      child: Stack(
                        children: [
                          if (collectionData['stats'] == 'closed')
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.attach_money,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  capitalizeFirstLetter(
                                      collectionData['title']),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Valor guardado: €${totalValue.toInt().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Mais informações...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (collectionData['stats'] == 'closed')
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
