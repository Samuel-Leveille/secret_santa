import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UsersFirestoreProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  Future<void> fetchUserData(String email) async {
    try {
      if (email.isNotEmpty) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          _userData = userDoc.data() as Map<String, dynamic>?;
        } else {
          print("Aucune donnée obtenue");
        }
        notifyListeners();
      } else {
        print("Aucun utilisateur connecté");
      }
    } catch (e) {
      print(
          "Erreur lors de l'optentions des données de l'utilisateur : ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>?> fetchAndReturnUserData(String email) async {
    try {
      if (email.isNotEmpty) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          return userDoc.data() as Map<String, dynamic>?;
        } else {
          print("Aucune donnée obtenue");
          return null;
        }
      } else {
        print("Aucun utilisateur connecté");
        return null;
      }
    } catch (e) {
      print(
          "Erreur lors de l'obtention des données de l'utilisateur : ${e.toString()}");
      return null;
    }
  }

  Future<void> updateUserField(
      String fieldName, String fieldContent, String email) async {
    try {
      if (email.isNotEmpty) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({fieldName: fieldContent});
        }
        await fetchUserData(email);
        notifyListeners();
      }
    } catch (e) {
      print(
          "La mise à jour des données de l'utilisateur a échouée : ${e.toString()}");
    }
  }

  Future<void> updateTwoUserField(String fieldName1, String fieldContent1,
      String fieldName2, String fieldContent2, String email) async {
    try {
      if (email.isNotEmpty) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({fieldName1: fieldContent1});
          await doc.reference.update({fieldName2: fieldContent2});
        }
        await fetchUserData(email);
        notifyListeners();
      }
    } catch (e) {
      print(
          "La mise à jour des données de l'utilisateur a échouée : ${e.toString()}");
    }
  }
}
