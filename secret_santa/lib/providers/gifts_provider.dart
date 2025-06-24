import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GiftsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, Map<String, dynamic>> _gifts = {};
  Map<String, dynamic>? getGiftById(String giftId) => _gifts[giftId];

  Future<void> fetchGiftData(String giftId) async {
    try {
      if (giftId.isNotEmpty) {
        if (_gifts.containsKey(giftId)) return;
        DocumentSnapshot documentSnapshot =
            await _firestore.collection('gifts').doc(giftId).get();
        if (documentSnapshot.exists) {
          _gifts[giftId] = documentSnapshot.data() as Map<String, dynamic>;
        } else {
          print("Le document snapshot pour le fetch de gift n'existe pas.");
        }
        notifyListeners();
      } else {
        print(
            "Erreur lors de l'optentions des données du cadeau : La String giftId (ID du cadeau) est vide");
      }
    } catch (e) {
      print(
          "Erreur lors de l'optentions des données du cadeau : ${e.toString()}");
    }
  }
}
