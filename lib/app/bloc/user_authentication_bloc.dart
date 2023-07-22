import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/bloc/utils_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../shared/constants/routes.dart';

class AuthenticationBloC {
  final utils = Utils();

  signIn({
    String? userEmail,
    String? userPassword,
    bool? noUserFoundError,
    bool? wrongPasswordError,
    BuildContext? context,
    Function()? saveEmailFunction,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail!,
        password: userPassword!,
      );

      if (credential.user != null) {
        saveEmailFunction!;
      }

      Navigator.pushReplacementNamed(context!, RoutesConst.home);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
        noUserFoundError = true;
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
        wrongPasswordError = true;
      }
    }
  }

  Future<void> createNewUserItemInTransactionsProduction(
      String userId, String formattedUserName) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('transactionsProduction')
          .doc(formattedUserName + '_collection');

      await userRef.set({
        'allowedUsers': [userId],
        'transactionsCollectionReference':
            'collection/' + formattedUserName + '_transactionsCollection',
      });

      final userCollectionRef =
          userRef.collection(formattedUserName + '_transactionsCollection');
      await userCollectionRef.add({});

      debugPrint(
          'New user item in transactionsProduction created successfully.');
    } catch (e) {
      debugPrint('Error creating new user item in transactionsProduction: $e');
    }
  }

  signUp({
    String? userName,
    String? userEmail,
    String? userPassword,
    bool? weakPasswordError,
    bool? emailAlreadyUserError,
    BuildContext? context,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userEmail!,
        password: userPassword!,
      );

      String formattedUserName = utils.formatUserNameForCollection(userName!);

      await createNewUserItemInTransactionsProduction(
        userCredential.user!.uid,
        formattedUserName,
      );

      await userCredential.user!.updateDisplayName(userName);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
        weakPasswordError = true;
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
        emailAlreadyUserError = true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
