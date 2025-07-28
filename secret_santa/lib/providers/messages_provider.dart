import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessagesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => _messages;

  Future<void> getAllMessagesByGroupId(String groupId) async {
    try {
      if (groupId.isEmpty) {
        print("Le id du groupe est vide");
        return;
      } else {
        QuerySnapshot querySnapshot = await _firestore
            .collection('messages')
            .where('groupId', isEqualTo: groupId)
            .orderBy('date', descending: true)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          _messages = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        }
        notifyListeners();
      }
    } catch (e) {
      print(
          "Erreur, les messages de ce groupe n'ont pas pu être chargés : ${e}");
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
