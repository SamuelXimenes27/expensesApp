import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseCardMoney extends StatefulWidget {
  const ExpenseCardMoney({Key? key}) : super(key: key);

  @override
  _ExpenseCardMoneyState createState() => _ExpenseCardMoneyState();
}

class _ExpenseCardMoneyState extends State<ExpenseCardMoney> {
  late SharedPreferences _prefs;
  bool showValue = true;

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
  }

  void loadSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      showValue = _prefs.getBool('showValue') ?? true;
    });
  }

  void saveSharedPreferences(bool value) async {
    await _prefs.setBool('showValue', value);
  }

  bool isLastValueNegative(List<DocumentSnapshot> collections) {
    if (collections.isNotEmpty) {
      final lastCollection = collections.first;
      final collectionData = lastCollection.data() as Map<String, dynamic>;

      final value = collectionData['value'] as double;

      return value < 0;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactionCollection')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            elevation: 6,
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: SizedBox(
                child: Column(
                  children: [
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Carregando o seu montante...'),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        double totalValue = 0;
        bool isNegative = false;

        if (snapshot.hasData) {
          final collections = snapshot.data!.docs;
          for (final collection in collections) {
            final collectionData = collection.data() as Map<String, dynamic>;

            final value = collectionData['value'] as double;
            totalValue += value;
            isNegative = isLastValueNegative(collections);
          }
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 6,
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Spacer(),
                  const Center(
                    child: Text(
                      'Total',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      const Spacer(),
                      Text(
                        showValue
                            ? totalValue.toStringAsFixed(2) + ' €'
                            : '---',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      isNegative == true
                          ? const Icon(
                              Icons.arrow_circle_down,
                              color: Colors.red,
                            )
                          : const Icon(
                              Icons.arrow_circle_up,
                              color: Colors.green,
                            ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showValue = !showValue;
                            saveSharedPreferences(showValue);
                          });
                        },
                        icon: Icon(
                          showValue ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
