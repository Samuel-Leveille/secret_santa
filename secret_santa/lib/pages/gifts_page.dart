import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/providers/gift_images_provider.dart';
import 'package:secret_santa/services/users_service.dart';
import 'package:secret_santa/utils/pick_image.dart';
import 'package:secret_santa/providers/users_firestore_provider.dart';

class GiftsPage extends StatefulWidget {
  final dynamic participant;
  final String groupId;
  const GiftsPage(
      {super.key, required this.participant, required this.groupId});

  @override
  State<GiftsPage> createState() => _GiftsPageState();
}

class _GiftsPageState extends State<GiftsPage> {
  UsersFirestoreProvider? _userProvider;
  final _auth = FirebaseAuth.instance;
  final List<Widget> _linkFields = [];
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<TextEditingController> linksController = [];
  final _firestore = FirebaseFirestore.instance;
  bool _isTitleEmpty = false;
  String? _userId;
  List<dynamic>? _gift_ids = [];
  List<Uint8List> _gift_images = [];
  bool erreurNbreImage = false;

  final UsersService _usersService = UsersService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userProvider =
          Provider.of<UsersFirestoreProvider>(context, listen: false);
      final userEmail = _auth.currentUser?.email;
      if (userEmail!.isNotEmpty) {
        _userProvider!.fetchUserData(userEmail);
      }
      getUserId();
    });
  }

  Future<void> getUserId() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('Aucun utilisateur connecté');
      return;
    }
    final userDocs = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();
    if (userDocs.docs.isEmpty) {
      print('Aucun document correspondant trouvé pour cet utilisateur');
      return;
    }
    setState(() {
      _userId = userDocs.docs.first.id;
    });
  }

  void _addLinkField() {
    TextEditingController controller = TextEditingController();
    linksController.add(controller);
    _linkFields.add(Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Lien',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ));
  }

  Future<void> selectImageFromGallery() async {
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

  Future<void> uploadImageAndUpdateUrl(
      Uint8List image, String giftId, int index) async {
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

  @override
  void dispose() {
    for (var controller in linksController) {
      controller.dispose();
    }
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveGift(StateSetter setState, BuildContext context) async {
    String title = titleController.text;
    String description = descriptionController.text;
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
          'groupId': widget.groupId
        });
      } else {
        await _firestore.collection('gifts').add({
          'title': title,
          'description': description,
          'userEmail': _auth.currentUser!.email,
          'groupId': widget.groupId
        });
      }
      Navigator.of(context).pop();
      titleController.clear();
      descriptionController.clear();
      links.clear();
      _linkFields.clear();
      linksController.clear();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .where('userEmail', isEqualTo: _auth.currentUser!.email)
          .where('groupId', isEqualTo: widget.groupId)
          .get();

      List<String> documentIds =
          querySnapshot.docs.map((doc) => doc.id).toList();

      final userEmail = _auth.currentUser!.email;

      if (documentIds.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .update({'giftsId': FieldValue.arrayUnion(documentIds)});
        await _firestore.collection('groups').doc(widget.groupId).update({
          "cadeauxParticipants.$userEmail": FieldValue.arrayUnion(documentIds)
        });
      }

      uploadGiftImages(context);
    } else {
      setState(() {
        _isTitleEmpty = title.isEmpty;
      });
    }
  }

  Future<void> uploadGiftImages(BuildContext context) async {
    final giftImageProvider =
        Provider.of<GiftImagesProvider>(context, listen: false);
    final user_data = await _usersService
        .fetchAndReturnUserData(_auth.currentUser!.email ?? '');
    if (user_data != null) {
      setState(() {
        _gift_ids = user_data['giftsId'];
      });
      if (_gift_ids!.isNotEmpty) {
        for (int i = 0; i < giftImageProvider.giftImages.length; i++) {
          await uploadImageAndUpdateUrl(giftImageProvider.giftImages[i],
              _gift_ids![_gift_ids!.length - 1], i);
        }
        _gift_images.clear();
        giftImageProvider.removeAllImage();
      } else {
        print("L'utilisateur n'a aucun cadeau à sa liste de souhait");
      }
    } else {
      print("Données utilisateur non trouvées");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: BackButton(
            color: Colors.black,
            onPressed: () {
              Provider.of<GiftImagesProvider>(context, listen: false)
                  .removeAllImage();
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Center(
              child: Consumer<UsersFirestoreProvider>(
                builder: (context, provider, child) {
                  final user = provider.userData;
                  if (user!.isNotEmpty) {
                    if (user['giftsId'].isEmpty &&
                        widget.participant == user['email']) {
                      return Text(
                        "  Ajoutez votre\npremier souhait",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                        ),
                      );
                    } else {
                      return Text(
                        "Aucun souhait ajouté\n    pour le moment",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                        ),
                      );
                    }
                  }
                  return const Text("L'utilisateur possède des cadeaux");
                },
              ),
            ),
          ),
        ),
        floatingActionButton: Consumer<UsersFirestoreProvider>(
          builder: (context, provider, child) {
            final user = provider.userData;
            if (widget.participant == user?['email']) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25.0)),
                      ),
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: GestureDetector(
                                onTap: () => FocusManager.instance.primaryFocus
                                    ?.unfocus(),
                                child: Container(
                                  height: 600,
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25.0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10.0,
                                        spreadRadius: 0.0,
                                        offset: Offset(0.0, 10.0),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        height: 8,
                                        width: 75,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      const Text(
                                        "Ajouter un souhait",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      Expanded(
                                        child: ListView(
                                          padding: const EdgeInsets.all(16.0),
                                          children: [
                                            TextField(
                                              controller: titleController,
                                              decoration: InputDecoration(
                                                labelText: 'Titre',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                errorText: _isTitleEmpty
                                                    ? 'Le titre est obligatoire'
                                                    : null,
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: descriptionController,
                                              decoration: InputDecoration(
                                                labelText:
                                                    'À propos (facultatif)',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              maxLines: 3,
                                            ),
                                            const SizedBox(height: 10),
                                            ..._linkFields,
                                            const SizedBox(height: 10),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  _addLinkField();
                                                });
                                              },
                                              icon: const Icon(Icons.add),
                                              label:
                                                  const Text('Ajouter un lien'),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor:
                                                    Colors.blue.shade800,
                                                backgroundColor:
                                                    Colors.blue.shade100,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12.0),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Consumer<GiftImagesProvider>(
                                                builder: (context,
                                                    giftImagesProvider, child) {
                                              return GridView.builder(
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  crossAxisSpacing: 8,
                                                  mainAxisSpacing: 8,
                                                ),
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: giftImagesProvider
                                                    .giftImages.length,
                                                itemBuilder: (context, index) {
                                                  return Stack(
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child: Image.memory(
                                                            giftImagesProvider
                                                                    .giftImages[
                                                                index],
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return const Center(
                                                                  child: Text(
                                                                      'Erreur image'));
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: -6,
                                                        left: -6,
                                                        child: SizedBox(
                                                          height: 32,
                                                          width: 32,
                                                          child:
                                                              IconButton.filled(
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStatePropertyAll(
                                                                Colors.red[400],
                                                              ),
                                                            ),
                                                            icon: const Icon(
                                                                Icons.delete),
                                                            color: Colors.black,
                                                            iconSize: 18,
                                                            onPressed: () {
                                                              setState(
                                                                () {
                                                                  erreurNbreImage =
                                                                      false;
                                                                },
                                                              );

                                                              giftImagesProvider
                                                                  .removeImage(
                                                                      index);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }),
                                            Consumer<GiftImagesProvider>(
                                              builder: (context,
                                                  giftImagesProvider, child) {
                                                return SizedBox(
                                                    height: erreurNbreImage ||
                                                            giftImagesProvider
                                                                .giftImages
                                                                .isNotEmpty
                                                        ? 10
                                                        : 0);
                                              },
                                            ),
                                            Consumer<GiftImagesProvider>(
                                              builder: (context,
                                                  giftImagesProvider, child) {
                                                return ElevatedButton.icon(
                                                  onPressed: giftImagesProvider
                                                              .giftImages
                                                              .length <
                                                          3
                                                      ? () {
                                                          setState(() {
                                                            erreurNbreImage =
                                                                false;
                                                          });
                                                          selectImageFromGallery();
                                                        }
                                                      : null,
                                                  icon: const Icon(Icons.image),
                                                  label: const Text(
                                                      'Ajouter une image'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.blue.shade800,
                                                    backgroundColor:
                                                        Colors.blue.shade100,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12.0),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                saveGift(setState, context);
                                              },
                                              icon: const Icon(
                                                  Icons.card_giftcard),
                                              label: const Text(
                                                'Ajouter',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor:
                                                    Colors.green.shade800,
                                                backgroundColor:
                                                    Colors.green.shade100,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12.0),
                                              ),
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(top: 15.0),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.info,
                                                    color: Colors.grey,
                                                  ),
                                                  Text(
                                                    "  L'ajout de liens et d'images\n  est fortement recommandé",
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  backgroundColor: Colors.blue.shade100,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
