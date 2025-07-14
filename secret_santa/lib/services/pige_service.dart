import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PigeService {
  final _firestore = FirebaseFirestore.instance;
  Future<void> lancerPige(List<dynamic> participantsEmail, String groupId,
      BuildContext context) async {
    try {
      participantsEmail.shuffle();
      Map<String, String> dictEmails = {};
      if (participantsEmail.length <= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Veuillez ajouter au moins un participant au groupe avant de lancer la pige")),
        );
        return;
      }
      if (participantsEmail.isNotEmpty) {
        for (int i = 0; i < participantsEmail.length - 1; i++) {
          dictEmails[participantsEmail[i]] = participantsEmail[i + 1];
        }
        dictEmails[participantsEmail[participantsEmail.length - 1]] =
            participantsEmail[0];

        await savePige(dictEmails, groupId);
      } else {
        print("La liste de participants est vide");
      }
    } catch (e) {
      print("Erreur, impossible de lancer la pige : ${e.toString()}");
    }
  }

  Future<void> savePige(Map<String, String> dictEmails, String groupId) async {
    if (groupId.isNotEmpty) {
      if (dictEmails.isNotEmpty) {
        await _firestore
            .collection('piges')
            .add({'duos': dictEmails, 'status': 'ACTIVE', 'groupId': groupId});

        QuerySnapshot querySnapshot = await _firestore
            .collection('piges')
            .where('groupId', isEqualTo: groupId)
            .where('status', isEqualTo: 'ACTIVE')
            .get();

        if (querySnapshot.docs.first.exists) {
          final pigeId = querySnapshot.docs.first.id;
          await _firestore
              .collection('groups')
              .doc(groupId)
              .update({'pigeId': pigeId});
        } else {
          print("Aucune pige contenant ce id de groupe n'existe");
        }

        await _firestore
            .collection('groups')
            .doc(groupId)
            .update({'pigeStatus': 'ACTIVE'});
      } else {
        print(
            "La pige n'a pas pu être sauvegardée : La liste des participants est vide");
      }
    } else {
      print("La pige n'a pas pu être sauvegardée : Le id de groupe est vide");
    }
  }

  Future<void> cancelPige(String groupId) async {
    if (groupId.isNotEmpty) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('piges')
          .where('groupId', isEqualTo: groupId)
          .where('status', isEqualTo: 'ACTIVE')
          .get();

      if (querySnapshot.docs.first.exists) {
        final pige = querySnapshot.docs.first.reference;
        await pige.update({'status': 'CANCELED'});
      } else {
        print("Aucune pige associé à ce id de groupe n'existe");
      }

      await _firestore
          .collection('groups')
          .doc(groupId)
          .update({'pigeStatus': 'INACTIVE'});
    } else {
      print("La pige n'a pas pu être canceled : Le id de groupe est vide");
    }
  }
}
