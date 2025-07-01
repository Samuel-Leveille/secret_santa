import 'dart:math';

import 'package:flutter/material.dart';

class PigeService {
  Future<void> lancerPige(
      List<dynamic> participantsEmail, BuildContext context) async {
    try {
      participantsEmail.shuffle();
      List<int> nombresDejaSorti = [];
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
        for (int i = 0; i < participantsEmail.length; i++) {
          int intValue = 0;
          bool valeurUnique = false;
          while (valeurUnique != true) {
            if (participantsEmail.length - dictEmails.length == 2) {
              if (!nombresDejaSorti.contains(participantsEmail.length - 1)) {
                intValue = participantsEmail.length - 1;
                nombresDejaSorti.add(intValue);
                valeurUnique = true;
                continue;
              }
            }
            intValue = Random().nextInt(participantsEmail.length);
            if (!nombresDejaSorti.contains(intValue) && intValue != i) {
              nombresDejaSorti.add(intValue);
              valeurUnique = true;
            }
          }
          dictEmails[participantsEmail[i]] = participantsEmail[intValue];
        }
        print(dictEmails);
      } else {
        print("La liste de participants est vide");
      }
    } catch (e) {
      print("Erreur, impossible de lancer la pige : ${e.toString()}");
    }
  }
}
