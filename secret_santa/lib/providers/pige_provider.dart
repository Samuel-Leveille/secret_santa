import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secret_santa/providers/groups_firestore_provider.dart';

class PigeProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic> _pige = {};
  Map<String, dynamic> get pige => _pige;
  Map<String, dynamic> _pigeDuoMap = {};
  Map<String, dynamic> get pigeDuoMap => _pigeDuoMap;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchPigeData(String groupId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('piges')
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'ACTIVE')
        .get();
    final pigeDoc = querySnapshot.docs.first;
    if (pigeDoc.exists) {
      _pige = pigeDoc.data() as Map<String, dynamic>;
    } else {
      print(
          "Les données de la pige n'ont pas pu être obtenu : Aucune pige contenant ce id de groupe n'existe");
    }
    notifyListeners();
  }

  Future<void> fetchAllPigeDuos() async {
    User? currentUser = _auth.currentUser;
    GroupsFirestoreProvider groupsProvider = GroupsFirestoreProvider();
    try {
      if (currentUser != null) {
        await groupsProvider.fetchGroupsData();
        List<Map<String, dynamic>> groups = groupsProvider.groupsData;
        if (groups.isNotEmpty) {
          for (int i = 0; i < groups.length; i++) {
            if (groups[i]['pigeStatus'] == 'ACTIVE') {
              await fetchPigeData(groups[i]['id']);
              if (pige['duos'] is Map &&
                  pige['duos'].containsKey(currentUser.email)) {
                _pigeDuoMap[pige['duos'][currentUser.email]] = groups[i]['id'];
              }
            }
          }
          notifyListeners();
        }
      } else {
        print(
            "Erreur: Les duos de pige de l'utilisateur n'ont pas pu être récupérés : Aucun utilisateur connecté.");
      }
    } catch (e) {
      print(
          "Erreur: Les duos de pige de l'utilisateur n'ont pas pu être récupérés : ${e.toString()}");
    }
  }
}
