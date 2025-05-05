import 'package:cloud_firestore/cloud_firestore.dart';

class UsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserNameByEmail(String email) async {
    final String name;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      name =
          "${(querySnapshot.docs.first.data() as Map<String, dynamic>)['firstName'] ?? ""} ${(querySnapshot.docs.first.data() as Map<String, dynamic>)['name'] ?? ""}";
    } else {
      name = "Nom inconnu";
      print("Error : name and firstname couldn't be fetch");
    }

    return name;
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
      }
    } catch (e) {
      print(
          "La mise à jour des données de l'utilisateur a échouée : ${e.toString()}");
    }
  }

  Future<String> getUserName(String email) async {
    final String name;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      name =
          "${(querySnapshot.docs.first.data() as Map<String, dynamic>)['firstName'] ?? ""} ${(querySnapshot.docs.first.data() as Map<String, dynamic>)['name'] ?? ""}";
    } else {
      name = "Nom inconnu";
      print("Error : name and firstname couldn't be fetch");
    }

    return name;
  }
}
