import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/bloc/utils_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserData {
  String? collectionName;
  String? transactionsCollectionName;
  Query? collectionsInstance;
  // String? userName;
  // String? userEmail;
  // String? userUrlPhoto;

  UserData({
    // this.userName,
    // this.userEmail,
    // this.userUrlPhoto,
    this.collectionName,
    this.transactionsCollectionName,
    this.collectionsInstance,
  });
}

class TransactionBloC {
  final utils = Utils();

  Future<UserData>? fetchTransactions() async {
    UserData? userTransactionsData;
    User? user = FirebaseAuth.instance.currentUser;
    String? userUID = user?.uid;
    String userCollectionName =
        utils.formatUserNameForCollection(user!.displayName!) +
            "_transactions_collection";

    final querySnapshot = await FirebaseFirestore.instance
        .collection('transactionsProduction')
        .where('allowedUsers', arrayContainsAny: [userUID]).get();

    if (querySnapshot.docs.isNotEmpty) {
      log(querySnapshot.docs.first.id);
      log(userCollectionName);

      UserData userTransactionsData = UserData(
          collectionName: querySnapshot.docs.first.id,
          transactionsCollectionName: userCollectionName,
          collectionsInstance: FirebaseFirestore.instance
              .collection('transactionsProduction')
              .doc(querySnapshot.docs.first.id)
              .collection(userCollectionName)
              .orderBy('date', descending: true));

      return userTransactionsData;
    } else {
      debugPrint('Usuário não tem permissão para acessar nenhum item');

      return userTransactionsData!;
    }
  }
}
