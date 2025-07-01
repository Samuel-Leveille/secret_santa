import 'package:flutter/material.dart';

class PigeService {
  Future<void> lancerPige(
      List<dynamic> participantsEmail, BuildContext context) async {
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
        print(dictEmails);
      } else {
        print("La liste de participants est vide");
      }
    } catch (e) {
      print("Erreur, impossible de lancer la pige : ${e.toString()}");
    }
  }
}
