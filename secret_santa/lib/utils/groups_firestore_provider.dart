
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
        QuerySnapshot querySnapshot = await _firestore
            .collection('groups')
            .where('participants', arrayContains: currentUser.email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          _groupsData = querySnapshot.docs
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

  Future<void> deleteGroup(String groupId, VoidCallback onGroupDeleted) async {
    try {
      if (groupId.isNotEmpty) {
        DocumentReference groupRef =
            FirebaseFirestore.instance.collection('groups').doc(groupId);
        DocumentSnapshot snapshot = await groupRef.get();
        List<dynamic> participants = snapshot['participants'];
        CollectionReference usersRef =
            FirebaseFirestore.instance.collection('users');

        for (String participant in participants) {
          QuerySnapshot querySnapshot =
              await usersRef.where('email', isEqualTo: participant).get();

          if (querySnapshot.docs.isNotEmpty) {
            DocumentSnapshot userDoc = querySnapshot.docs.first;
            DocumentReference userRef = userDoc.reference;
            await userRef.update({
              'groupsId': FieldValue.arrayRemove([groupId])
            });
          }
        }

        await groupRef
            .update({'participants': FieldValue.arrayRemove(participants)});
        onGroupDeleted();
      }
    } catch (e) {
      print("Le groupe n'a pas pu être supprimé : $e");
    }
  }

  Future<void> addParticipantToGroup(
      String groupId, String email, VoidCallback onParticipantAdded) async {
    try {
      if (groupId.isNotEmpty && email.isNotEmpty) {
        DocumentReference groupRef =
            FirebaseFirestore.instance.collection('groups').doc(groupId);
        await groupRef.update({
          'participants': FieldValue.arrayUnion([email])
        });

        CollectionReference usersRef =
            FirebaseFirestore.instance.collection('users');
        QuerySnapshot querySnapshot =
            await usersRef.where('email', isEqualTo: email).get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          DocumentReference userRef = userDoc.reference;
          await userRef.update({
            'groupsId': FieldValue.arrayUnion([groupId])
          });
        }

        onParticipantAdded();
      }
    } catch (e) {
      print("Failed to add participant: $e");
    }
  }

  Future<void> removeParticipantFromGroup(
      String groupId, String email, VoidCallback onParticipantRemoved) async {
    try {
      if (groupId.isNotEmpty && email.isNotEmpty) {
        DocumentReference groupRef =
            FirebaseFirestore.instance.collection('groups').doc(groupId);
        CollectionReference usersRef =
            FirebaseFirestore.instance.collection('users');
        QuerySnapshot querySnapshot =
            await usersRef.where('email', isEqualTo: email).get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          DocumentReference userRef = userDoc.reference;
          await userRef.update({
            'groupsId': FieldValue.arrayRemove([groupId])
          });
        }
        await groupRef.update({
          'participants': FieldValue.arrayRemove([email])
        });
        onParticipantRemoved();
      }
    } catch (e) {
      print("Failed to remove participant: $e");
    }
  }
}
