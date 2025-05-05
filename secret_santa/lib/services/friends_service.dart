import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<String>> fetchCurrentUserFriendRequests() async {
    User? user = _auth.currentUser;
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user?.email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return List<String>.from((querySnapshot.docs.first.data()
              as Map<String, dynamic>)['friendRequests'] ??
          []);
    }
    return [];
  }

  Future<List<String>> fetchReceiverFriendRequests(String email) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return List<String>.from((querySnapshot.docs.first.data()
              as Map<String, dynamic>)['friendRequests'] ??
          []);
    }
    return [];
  }

  Future<List<String>> fetchUserFriends() async {
    User? user = _auth.currentUser;
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user?.email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return List<String>.from((querySnapshot.docs.first.data()
              as Map<String, dynamic>)['friends'] ??
          []);
    }
    return [];
  }

  Future<void> acceptFriendRequest(String email, VoidCallback onHandled) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser!.email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot.docs.first.reference;
      docRef.update({
        'friends': FieldValue.arrayUnion([email])
      });
      docRef.update({
        'friendRequests': FieldValue.arrayRemove([email])
      });
      onHandled();
    } else {
      print("Aucun utilisateur connecté");
    }

    QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot2.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot2.docs.first.reference;
      docRef.update({
        'friends': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      print(
          "Erreur en lien avec l'utilisateur qui a envoyé la demande d'ami (il n'existe pas apparamment)");
    }
  }

  Future<void> refuseFriendRequest(String email, VoidCallback onHandled) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser!.email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot.docs.first.reference;
      docRef.update({
        'friendRequests': FieldValue.arrayRemove([email])
      });
      onHandled();
    } else {
      print("Aucun utilisateur connecté");
    }
  }
}
