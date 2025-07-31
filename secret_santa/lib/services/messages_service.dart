import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> sendMessage(
      String message, String groupId, String? senderEmail) async {
    try {
      if (senderEmail!.isNotEmpty) {
        if (groupId.isNotEmpty) {
          if (message.isNotEmpty) {
            await _firestore.collection('messages').add({
              'groupId': groupId,
              'senderEmail': senderEmail,
              'message': message,
              'date': DateTime.now()
            });
          } else {
            print(
                "Erreur, le message n'a pas pu être envoyé : Le message est vide");
          }
        } else {
          print(
              "Erreur, le message n'a pas pu être envoyé : Le id du groupe est vide");
        }
      } else {
        print(
            "Erreur, le message n'a pas pu être envoyé : L'utilisateur ayant envoyé le message ne semble pas connecté.");
      }
    } catch (e) {
      print("Erreur, le message n'a pas pu être envoyé : ${e.toString()}");
    }
  }

  Future<void> editMessage(String message, String messageId) async {
    try {
      if (message.isNotEmpty) {
        if (messageId.isNotEmpty) {
          await _firestore
              .collection('messages')
              .doc(messageId)
              .update({'message': message, 'status': 'EDITED'});
        } else {
          print(
              "Le message n'a pas pu être modifié : le id du message est vide");
        }
      } else {
        print("Le message n'a pas pu être modifié : Aucun message envoyé");
      }
    } catch (e) {
      print("Erreur, le message n'a pas pu être modifié : ${e.toString()}");
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      if (messageId.isNotEmpty) {
        await _firestore
            .collection('messages')
            .doc(messageId)
            .update({'status': 'DELETED'});
      } else {
        print(
            "Le message n'a pas pu être supprimé : Le id du message est vide");
      }
    } catch (e) {
      print("Erreur, le message n'a pas pu être supprimé : ${e.toString()}");
    }
  }
}
