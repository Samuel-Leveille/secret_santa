import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/pages/group_page.dart';
import 'package:secret_santa/providers/groups_firestore_provider.dart';
import 'package:secret_santa/providers/users_firestore_provider.dart';

class GroupsService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String getGroupId(Map<String, dynamic>? group) {
    return group?['id'];
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

  Future<void> createGroup(
      String groupName,
      String groupDescription,
      String moneyMax,
      String pigeDate,
      User? user,
      BuildContext context) async {
    Map<String, List<String>> mapCadeauxParticipants = {};

    if (groupName.isEmpty ||
        moneyMax.isEmpty ||
        pigeDate.isEmpty ||
        groupDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    } else if (user != null) {
      DocumentReference docRef = await _firestore.collection('groups').add({
        'name': groupName,
        'description': groupDescription,
        'admin': user.email,
        'participants': [user.email],
        'dateCreation': DateTime.now().toString(),
        'moneyMax': moneyMax,
        'pigeDate': pigeDate,
        'cadeauxParticipants': mapCadeauxParticipants
      });

      await docRef.update({'id': docRef.id});
      addGroupToCurrentUser(user, docRef.id);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GroupPage(groupId: docRef.id),
        ),
      );
    }
  }

  Future<void> addGroupToCurrentUser(User user, String groupId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot.docs.first.reference;
      await docRef.update({
        'groupsId': FieldValue.arrayUnion([groupId])
      });
    } else {
      print("QuerySnapshot vide.");
    }
  }

  Future<String> getUserName(
      String email, GroupsFirestoreProvider? _groupProvider) async {
    String name = "Nom inconnu";
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      name =
          "${(querySnapshot.docs.first.data() as Map<String, dynamic>)['firstName'] ?? ""} ${(querySnapshot.docs.first.data() as Map<String, dynamic>)['name'] ?? ""}";
    } else {
      print("Error : name and firstname couldn't be fetched");
    }

    if (email == _groupProvider?.groupData?['admin']) {
      name = "$name (Admin)";
    }
    return name;
  }

  Future<List<dynamic>> getAdminFriends(BuildContext context) async {
    String adminEmail = _auth.currentUser?.email as String;
    final userProvider =
        Provider.of<UsersFirestoreProvider>(context, listen: false);
    await userProvider.fetchUserData(adminEmail);
    return userProvider.userData?['friends'] ?? [];
  }

  Future<void> updateGroupForm(String formContent, String controllerName,
      User? user, String? groupId, BuildContext context) async {
    if (formContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez remplir le champ avant d'enregistrer")),
      );
      return;
    } else if (user != null && groupId != null) {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .update({controllerName: formContent});
    }
  }
}
