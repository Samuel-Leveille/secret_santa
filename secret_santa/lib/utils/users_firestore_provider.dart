import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UsersFirestoreProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  UsersFirestoreProvider() {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
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

  Future<void> updateUserField(String fieldName, String fieldContent) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({fieldName: fieldContent});
        }
        await fetchUserData();
        notifyListeners();
      }
    } catch (e) {
      print(
          "La mise à jour des données de l'utilisateur a échouée : ${e.toString()}");
    }
  }

  Future<void> updateTwoUserField(String fieldName1, String fieldContent1,
      String fieldName2, String fieldContent2) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({fieldName1: fieldContent1});
          await doc.reference.update({fieldName2: fieldContent2});
        }
        await fetchUserData();
        notifyListeners();
      }
    } catch (e) {
      print(
          "La mise à jour des données de l'utilisateur a échouée : ${e.toString()}");
    }
  }
}
