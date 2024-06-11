import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/components/profile_data_field.dart';
import 'package:secret_santa/utils/pick_image.dart';
import 'package:secret_santa/utils/users_firestore_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? _image;
  String? _imageUrl;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? _userId;
  UsersFirestoreProvider? usersFirestoreProvider;

  @override
  void initState() {
    getUserId();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    usersFirestoreProvider = Provider.of<UsersFirestoreProvider>(context);
    getProfilePicture();
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

  Future<void> selectImageFromGallery() async {
    if (_userId == null) {
      print('Aucun utilisateur connecté');
      return;
    }
    try {
      await pickImage(ImageSource.gallery, _userId!);
      await getProfilePicture();
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  Future<void> selectImageFromCamera() async {
    if (_userId == null) {
      print('Aucun utilisateur connecté');
      return;
    }
    try {
      await pickImage(ImageSource.camera, _userId!);
      await getProfilePicture();
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  Future<void> getProfilePicture() async {
    setState(() {
      _imageUrl = usersFirestoreProvider?.userData!['profileImageUrl'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: usersFirestoreProvider?.userData == null
            ? const CircularProgressIndicator()
            : Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 1,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child:
                              Text(usersFirestoreProvider?.userData!['email']),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          child: Column(
                            children: [
                              ProfileDataField(
                                width: 250,
                                height: 50,
                                content: usersFirestoreProvider
                                        ?.userData!['firstName'] +
                                    ' ' +
                                    (usersFirestoreProvider?.userData!['name']),
                                label: 'Nom',
                                canModify: true,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ProfileDataField(
                                width: 250,
                                height: 50,
                                content: usersFirestoreProvider
                                    ?.userData!['dateInscription']
                                    .substring(0, 10),
                                label: 'Date création du compte',
                                canModify: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFB2EBF2),
                            Color(0xFF80DEEA),
                            Color(0xFF4DD0E1),
                            Color(0xFF26C6DA),
                          ],
                          stops: [
                            0.3,
                            0.5,
                            0.7,
                            1.0
                          ]),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 375.0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          _imageUrl == "" || _imageUrl == null
                              ? Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 20,
                                            offset: Offset(1, 1)),
                                      ]),
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                  ),
                                )
                              : Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 20,
                                            offset: Offset(1, 1)),
                                      ]),
                                  child: GestureDetector(
                                    onTap: () => {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.4,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        _imageUrl!),
                                                    fit: BoxFit.cover),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    },
                                    child: CircleAvatar(
                                      radius: 45,
                                      backgroundImage: NetworkImage(_imageUrl!),
                                    ),
                                  ),
                                ),
                          Positioned(
                            top: 66,
                            left: 58,
                            child: SizedBox(
                              height: 32,
                              width: 32,
                              child: IconButton.filled(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.teal[100])),
                                  icon: const Icon(Icons.add_a_photo),
                                  color: Colors.black,
                                  disabledColor: Colors.black,
                                  iconSize: 15,
                                  onPressed: () => {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  "Photo de profil",
                                                  textAlign: TextAlign.center,
                                                ),
                                                content: Container(
                                                  height: 125,
                                                  child: Column(
                                                    children: [
                                                      const Divider(
                                                        color: Colors.black,
                                                        thickness: 0.5,
                                                        height: 1,
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      ElevatedButton.icon(
                                                        onPressed:
                                                            selectImageFromCamera,
                                                        label: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 40.0),
                                                          child: Text(
                                                            "Caméra",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue[300]),
                                                          ),
                                                        ),
                                                        icon: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 40.0),
                                                          child: Icon(
                                                            Icons.camera_alt,
                                                            color: Colors
                                                                .blue[300],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      ElevatedButton.icon(
                                                        onPressed:
                                                            selectImageFromGallery,
                                                        label: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 40.0),
                                                          child: Text(
                                                            "Galerie",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue[300]),
                                                          ),
                                                        ),
                                                        icon: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 40.0),
                                                          child: Icon(
                                                            Icons.image,
                                                            color: Colors
                                                                .blue[300],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      MaterialButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            "Annuler"),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              );
                                            })
                                      }),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
