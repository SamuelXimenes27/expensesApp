import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_alert_dialog.dart';

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }

  return text[0].toUpperCase() + text.substring(1);
}

class ExpenseCardList extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final expenseCollection;

  const ExpenseCardList({Key? key, required this.expenseCollection})
      : super(key: key);

  @override
  State<ExpenseCardList> createState() => _ExpenseCardListState();
}

class _ExpenseCardListState extends State<ExpenseCardList> {
  bool removeConfirm = false;
  bool usePhoto = false;
  File? userImage;
  String? userName;
  Map<String, Color> userColors = {};

  @override
  void initState() {
    super.initState();
    loadUsePhotoValue();
    loadUserData();
    fetchUserColors();
  }

  String initialLetters(String name) {
    List<String> parts = name.split(' ');
    String initials = '';

    for (String part in parts) {
      initials += part[0];
    }

    return initials.toUpperCase();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? '';
        userImage = user.photoURL != null ? File(user.photoURL!) : null;
      });
    }
  }

  void removeConfirmAction() {
    setState(() {
      removeConfirm = true;
    });
  }

  Future<void> loadUsePhotoValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      usePhoto = prefs.getBool('usePhoto') ?? false;
    });
  }

  Future<void> deleteCollection(String collectionId) async {
    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('transactionCollection')
          .doc(collectionId);

      await collectionRef.delete();
      debugPrint('Sucesso ao excluir a coleção');
    } catch (e) {
      debugPrint('Erro ao excluir a coleção: $e');
    }
  }

  Future<void> fetchUserColors() async {
    Map<String, Color> colors = await assignUserColors();
    setState(() {
      userColors = colors;
    });
  }

  Future<Map<String, Color>> assignUserColors() async {
    Map<String, Color> userColors = {};

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transactionCollection')
        .orderBy('createdAt')
        .get();

    List<QueryDocumentSnapshot> documents = snapshot.docs;

    for (int i = 0; i < documents.length; i++) {
      Map<String, dynamic> data = documents[i].data() as Map<String, dynamic>;
      String? userName = data['user'] as String?;

      if (userName != null && !userColors.containsKey(userName)) {
        if (i % 2 == 0) {
          userColors[userName] = const Color(0xffF95738);
        } else {
          userColors[userName] = const Color(0xffF4D35E);
        }
      }
    }

    return userColors;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.expenseCollection.snapshots(),
      builder: (context, snapshot) {
        final size = MediaQuery.of(context).size;
        initializeDateFormatting('pt_BR', null);

        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.only(top: size.height * 0.2),
            child: const Column(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                Text('Erro ao carregar os dados'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.only(top: size.height * 0.2),
            child: const Column(
              children: [
                Center(
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Carregando transações...'),
                )
              ],
            ),
          );
        }

        final expenseDocs = snapshot.data!.docs;

        if (expenseDocs.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: size.height * 0.2),
            child: const Text('Nenhuma transação encontrada.'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 5, top: 10),
              child: Text(
                'Histórico de Transações',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: size.height * expenseDocs.length / 5,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: expenseDocs.length,
                itemBuilder: (context, index) {
                  final collectionData =
                      expenseDocs[index].data() as Map<String, dynamic>;

                  final collectionId = expenseDocs[index].id;

                  final dateTimestamp = collectionData['date'] as Timestamp;
                  final date = dateTimestamp.toDate();

                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return RemoveAlertDialog(
                            collectionId: collectionId,
                            collectionData: collectionData,
                          );
                        },
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 25,
                                  child: CircleAvatar(
                                    child: Text(
                                      initialLetters(collectionData['user']),
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    backgroundColor:
                                        userColors[collectionData['user']] ??
                                            Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  capitalizeFirstLetter(
                                      collectionData['title']),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    DateFormat('d MMM y', 'pt_BR').format(date),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '€ ${collectionData['value'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: collectionData['value'] > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            collectionData['type'] != ''
                                ? Text(
                                    collectionData['type']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  )
                                : const Text('Não definido '),
                          ],
                        ),
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
