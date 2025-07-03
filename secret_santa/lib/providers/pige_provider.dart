import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PigeProvider extends ChangeNotifier {
  Map<String, dynamic> _pige = {};
  Map<String, dynamic> get pige => _pige;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchPigeData(String groupId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('piges')
        .where('groupId', isEqualTo: groupId)
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
}
