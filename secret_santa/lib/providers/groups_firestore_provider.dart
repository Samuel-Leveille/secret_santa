import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupsFirestoreProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _groupsData = [];
  Map<String, dynamic>? _groupData;

  List<Map<String, dynamic>> get groupsData => _groupsData;
  Map<String, dynamic>? get groupData => _groupData;

  Future<void> fetchGroupsData() async {
    User? currentUser = _auth.currentUser;
    try {
      if (currentUser != null) {
        final email = currentUser.email;
        if (email == null) {
          print("Email du current user est null");
          return;
        }
        final groupsRef = _firestore.collection('groups');
        final snapshot =
            await groupsRef.where('participants', arrayContains: email).get();
        if (snapshot.docs.isNotEmpty) {
          _groupsData = snapshot.docs
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

  Future<void> fetchGroupData(String groupId) async {
    User? currentUser = _auth.currentUser;
    try {
      if (currentUser != null && groupId.isNotEmpty) {
        DocumentSnapshot documentSnapshot =
            await _firestore.collection('groups').doc(groupId).get();
        if (documentSnapshot.exists) {
          _groupData = documentSnapshot.data() as Map<String, dynamic>;
        } else {
          print("Aucun groupe ne possède ce ID");
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
