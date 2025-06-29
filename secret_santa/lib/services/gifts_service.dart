import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/providers/gift_images_provider.dart';
import 'package:secret_santa/providers/users_firestore_provider.dart';
import 'package:secret_santa/services/users_service.dart';
import 'package:secret_santa/utils/pick_image.dart';

class GiftsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final UsersService _usersService = UsersService();

  Future<void> selectImageFromGallery(
      String? _userId, BuildContext context) async {
    if (_userId == null) {
      print('Aucun utilisateur connecté');
      return;
    }
    try {
      final pickedImage = await pickImage(ImageSource.gallery);
      if (pickedImage != null) {
        Provider.of<GiftImagesProvider>(context, listen: false)
            .addImage(pickedImage);
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  Future<void> uploadImageAndUpdateUrl(Uint8List image, String giftId,
      int index, UsersFirestoreProvider? _userProvider) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('gift_image')
        .child('$giftId$index.jpg');
    await ref.putData(image);
    final url = await ref.getDownloadURL();

    await _firestore.collection('gifts').doc(giftId).update({
      'images': FieldValue.arrayUnion([url])
    });

    await _userProvider?.fetchUserData(_auth.currentUser!.email ?? '');
  }

  Future<bool> saveGift(
      BuildContext context,
      String title,
      String description,
      List<TextEditingController> linksController,
      String groupId,
      String? _userId,
      UsersFirestoreProvider? _userProvider) async {
    List<String> links = [];
    for (int i = 0; i < linksController.length; i++) {
      if (linksController[i].text.isNotEmpty) {
        links.add(linksController[i].text);
      }
    }
    if (title.isNotEmpty) {
      if (links.isNotEmpty) {
        await _firestore.collection('gifts').add({
          'title': title,
          'description': description,
          'links': links,
          'userEmail': _auth.currentUser!.email,
          'groupId': groupId,
          'status': "ACTIVE"
        });
      } else {
        await _firestore.collection('gifts').add({
          'title': title,
          'description': description,
          'userEmail': _auth.currentUser!.email,
          'groupId': groupId,
          'status': "ACTIVE"
        });
      }

      links.clear();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .where('userEmail', isEqualTo: _auth.currentUser!.email)
          .where('groupId', isEqualTo: groupId)
          .get();

      List<String> documentIds =
          querySnapshot.docs.map((doc) => doc.id).toList();

      final userEmail = _auth.currentUser!.email!.replaceAll('.', ',');

      if (documentIds.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .update({'giftsId': FieldValue.arrayUnion(documentIds)});
        await _firestore.collection('groups').doc(groupId).update({
          "cadeauxParticipants.$userEmail": FieldValue.arrayUnion(documentIds)
        });
      }

      await uploadGiftImages(context, _userProvider);
      return false;
    } else {
      return true;
    }
  }

  Future<void> uploadGiftImages(
      BuildContext context, UsersFirestoreProvider? _userProvider) async {
    List<dynamic>? _gift_ids = [];
    final giftImageProvider =
        Provider.of<GiftImagesProvider>(context, listen: false);
    final user_data = await _usersService
        .fetchAndReturnUserData(_auth.currentUser!.email ?? '');
    if (user_data != null) {
      _gift_ids = user_data['giftsId'];

      if (_gift_ids!.isNotEmpty) {
        for (int i = 0; i < giftImageProvider.giftImages.length; i++) {
          await uploadImageAndUpdateUrl(giftImageProvider.giftImages[i],
              _gift_ids[_gift_ids.length - 1], i, _userProvider);
        }
        giftImageProvider.removeAllImage();
      } else {
        print("L'utilisateur n'a aucun cadeau à sa liste de souhait");
      }
    } else {
      print("Données utilisateur non trouvées");
    }
  }

  Future<void> deleteGift(String giftId) async {
    if (giftId.isNotEmpty) {
      await _firestore
          .collection('gifts')
          .doc(giftId)
          .update({'status': "DELETE"});
    } else {
      print("Le cadeau n'a pas pu être supprimé : giftId est vide.");
    }
  }
}
