import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secret_santa/firebase_auth/auth_services.dart';
import 'package:secret_santa/pages/login_page.dart';
import 'package:secret_santa/pages/transition_page.dart';
import 'package:secret_santa/providers/users_firestore_provider.dart';
import 'package:secret_santa/utils/pick_image.dart';

class UsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final AuthServices auth = AuthServices();

  Future<String> getUserId() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('Aucun utilisateur connecté');
      return "";
    }
    final userDocs = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();
    if (userDocs.docs.isEmpty) {
      print('Aucun document correspondant trouvé pour cet utilisateur');
      return "";
    } else {
      return userDocs.docs.first.id;
    }
  }

  Future<String> getUserNameByEmail(String email) async {
    final String name;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      name =
          "${(querySnapshot.docs.first.data() as Map<String, dynamic>)['firstName'] ?? ""} ${(querySnapshot.docs.first.data() as Map<String, dynamic>)['name'] ?? ""}";
    } else {
      name = "Nom inconnu";
      print("Error : name and firstname couldn't be fetch");
    }

    return name;
  }

  Future<Map<String, dynamic>?> fetchAndReturnUserData(String email) async {
    try {
      if (email.isNotEmpty) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          return userDoc.data() as Map<String, dynamic>?;
        } else {
          print("Aucune donnée obtenue");
          return null;
        }
      } else {
        print("Aucun utilisateur connecté");
        return null;
      }
    } catch (e) {
      print(
          "Erreur lors de l'obtention des données de l'utilisateur : ${e.toString()}");
      return null;
    }
  }

  Future<void> updateUserField(
      String fieldName, String fieldContent, String email) async {
    try {
      if (email.isNotEmpty) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({fieldName: fieldContent});
        }
      }
    } catch (e) {
      print(
          "La mise à jour des données de l'utilisateur a échouée : ${e.toString()}");
    }
  }

  Future<void> updateTwoUserField(String fieldName1, String fieldContent1,
      String fieldName2, String fieldContent2, String email) async {
    try {
      if (email.isNotEmpty) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({fieldName1: fieldContent1});
          await doc.reference.update({fieldName2: fieldContent2});
        }
      }
    } catch (e) {
      print(
          "La mise à jour des données de l'utilisateur a échouée : ${e.toString()}");
    }
  }

  Future<String> getUserName(String email) async {
    final String name;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      name =
          "${(querySnapshot.docs.first.data() as Map<String, dynamic>)['firstName'] ?? ""} ${(querySnapshot.docs.first.data() as Map<String, dynamic>)['name'] ?? ""}";
    } else {
      name = "Nom inconnu";
      print("Error : name and firstname couldn't be fetch");
    }

    return name;
  }

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TransitionPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur : utilisateur introuvable.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Une erreur est survenue.";
      if (e.code == 'user-not-found') {
        message = "Aucun utilisateur trouvé avec cet e-mail.";
      } else if (e.code == 'wrong-password') {
        message = "Mot de passe incorrect.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur inconnue, réessayez plus tard.")),
      );
    }
  }

  Future<void> signUp(String name, String firstName, String email,
      String password, String confirmPassword, BuildContext context) async {
    if (name.isEmpty ||
        firstName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Remplissez tous les champs du formulaire d'inscription")),
      );
      return;
    }
    // Vérification du format de l'e-mail
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern as String);
    if (!regex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrez une adresse courriel valide")),
      );
      return;
    }

    // Vérification de la complexité du mot de passe
    Pattern passwordPattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp passwordRegex = RegExp(passwordPattern as String);
    if (!passwordRegex.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Le mot de passe doit comporter au moins 8 caractères, dont une lettre majuscule, une lettre minuscule, un chiffre et un caractère spécial")),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }
    User? user = await auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      CollectionReference collRef =
          FirebaseFirestore.instance.collection('users');
      collRef.add({
        'firstName': firstName,
        'name': name,
        'email': email,
        'role': 'utilisateur',
        'profileImageUrl': '',
        'dateInscription': DateTime.now().toString(),
        'biography': '',
        'groupsId': [],
        'giftsId': [],
        'friendRequests': [],
        'friends': []
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TransitionPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur : la création de compte a échouée")),
      );
    }
  }

  Future<String> selectProfileImageFromGallery(String? _userId,
      UsersFirestoreProvider? usersFirestoreProvider, String email) async {
    String url = "";
    try {
      final pickedImage = await pickImage(ImageSource.gallery);
      if (pickedImage != null) {
        url = await uploadProfileImageAndUpdateUrl(
            pickedImage, _userId, usersFirestoreProvider, email);
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
    return url;
  }

  Future<String> selectProfileImageFromCamera(String? _userId,
      UsersFirestoreProvider? usersFirestoreProvider, String email) async {
    String url = "";
    try {
      final pickedImage = await pickImage(ImageSource.camera);
      if (pickedImage != null) {
        url = await uploadProfileImageAndUpdateUrl(
            pickedImage, _userId, usersFirestoreProvider, email);
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
    return url;
  }

  Future<String> uploadProfileImageAndUpdateUrl(Uint8List image, String? userId,
      UsersFirestoreProvider? usersFirestoreProvider, String email) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('$userId.jpg');
    await ref.putData(image);
    final url = await ref.getDownloadURL();

    await _firestore.collection('users').doc(userId).update({
      'profileImageUrl': url,
    });

    await usersFirestoreProvider?.fetchUserData(email);
    return url;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await auth.signOut();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      print("Some error occured with sign out : ${e.toString()}");
    }
  }
}
