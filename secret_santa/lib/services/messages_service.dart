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
              'message': message
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
}
