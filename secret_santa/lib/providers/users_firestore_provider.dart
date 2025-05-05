import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UsersFirestoreProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
}
