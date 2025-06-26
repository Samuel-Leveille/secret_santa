import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupsFirestoreProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _groupsData = [];
  Map<String, dynamic>? _groupData;
  List<String> _giftsIdOfAParticipant = [];

  List<Map<String, dynamic>> get groupsData => _groupsData;
  Map<String, dynamic>? get groupData => _groupData;
  List<String> get giftsIdOfAParticipant => _giftsIdOfAParticipant;

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

  Future<void> fetchGiftsIdOfAParticipant(
      String groupId, String? userEmail) async {
    try {
      if (groupId.isNotEmpty) {
        DocumentSnapshot documentSnapshot =
            await _firestore.collection('groups').doc(groupId).get();
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          final groupParticipantCadeaux =
              data['cadeauxParticipants'] as Map<String, dynamic>;
          userEmail = userEmail!.replaceAll('.', ',');
          if (groupParticipantCadeaux.isNotEmpty &&
              groupParticipantCadeaux.containsKey(userEmail)) {
            _giftsIdOfAParticipant =
                List<String>.from(groupParticipantCadeaux[userEmail]);
          } else {
            print(
                "Le participant ${userEmail} n'a pas ajouté de cadeau dans ce groupe.");
          }
        } else {
          print("Le document snapshot pour le fetch de gift n'existe pas.");
        }
        notifyListeners();
      } else {
        print(
            "Erreur lors de l'optentions des données du cadeau : La String groupId (ID du cadeau) est vide");
      }
    } catch (e) {
      print(
          "Erreur lors de l'optentions des données du cadeau : ${e.toString()}");
    }
  }

  void emptyGifts() {
    _giftsIdOfAParticipant.clear();
    notifyListeners();
  }
}
