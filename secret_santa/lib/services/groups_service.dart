import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupsService {
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
}
