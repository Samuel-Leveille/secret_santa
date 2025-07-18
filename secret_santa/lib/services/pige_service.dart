import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/providers/pige_provider.dart';
import 'package:secret_santa/services/users_service.dart';

class PigeService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _usersService = UsersService();

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

  Future<String> getMyDuo(BuildContext context, String groupId) async {
    String userEmail = _auth.currentUser?.email as String;
    if (userEmail.isNotEmpty) {
      final pigeProvider = Provider.of<PigeProvider>(context, listen: false);
      await pigeProvider.fetchPigeData(groupId);
      String duoEmail = pigeProvider.pige['duos'][userEmail] ?? "Aucune pige";
      if (duoEmail.isNotEmpty) {
        return _usersService.getUserName(duoEmail);
      } else {
        return "Aucune pige";
      }
    } else {
      print("Aucun utilisateur connecté");
    }
    return "Aucune pige";
  }
}
