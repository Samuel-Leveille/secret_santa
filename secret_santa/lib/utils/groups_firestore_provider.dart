import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupsFirestoreProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _groupData = [];

  List<Map<String, dynamic>> get groupData => _groupData;

  Future<void> fetchGroupData() async {
    User? currentUser = _auth.currentUser;
    try {
      if (currentUser != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('groups')
            .where('participants', arrayContains: currentUser.email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          _groupData = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        } else {
          print("L'utilisateur présent ne fait partie d'aucun groupe");
        }
        notifyListeners();
      } else {
        print("Aucun utilisateur connecté");
      }
    } catch (e) {
      print("Les données du groupe n'ont pas pu être fetch : ${e.toString()}");
    }
  }
}
