import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/components/profile_data_field.dart';
import 'package:secret_santa/pages/settings_page.dart';
import 'package:secret_santa/services/users_service.dart';
import 'package:secret_santa/providers/users_firestore_provider.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  const ProfilePage({super.key, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _imageUrl;
  final _auth = FirebaseAuth.instance;
  String? _userId;
  UsersFirestoreProvider? usersFirestoreProvider;

  final UsersService _usersService = UsersService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      usersFirestoreProvider =
          Provider.of<UsersFirestoreProvider>(context, listen: false);
      usersFirestoreProvider?.fetchUserData(widget.email);
      _loadUserId();
    });
  }

  Future<void> _loadUserId() async {
    String loadedUserId = await _usersService.getUserId();
    setState(() {
      _userId = loadedUserId;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getProfilePicture();
  }

  Future<void> getProfilePicture() async {
    final provider =
        Provider.of<UsersFirestoreProvider>(context, listen: false);
    setState(() {
      _imageUrl = provider.userData?['profileImageUrl'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UsersFirestoreProvider>(
          builder: (context, usersFirestoreProvider, child) {
        return SingleChildScrollView(
          child: Center(
            child: usersFirestoreProvider.userData == null
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, right: 5.0),
                                    child:
                                        widget.email == _auth.currentUser?.email
                                            ? IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const SettingsPage()),
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.settings,
                                                  size: 30,
                                                ))
                                            : null),
                              ],
                            ),
                            widget.email == _auth.currentUser?.email
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 20.0, top: 20),
                                    child: Text(usersFirestoreProvider
                                        .userData!['email']),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 20.0, top: 60),
                                    child: Text(usersFirestoreProvider
                                        .userData!['email']),
                                  ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 50.0),
                              child: Column(
                                children: [
                                  ProfileDataField(
                                    width: 260,
                                    height: 50,
                                    content: usersFirestoreProvider
                                            .userData!['firstName'] +
                                        ' ' +
                                        (usersFirestoreProvider
                                            .userData!['name']),
                                    label: 'Nom',
                                    canModify: true,
                                    email: widget.email,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ProfileDataField(
                                    width: 260,
                                    height: 125,
                                    content: usersFirestoreProvider
                                        .userData!['biography'],
                                    label: 'À propos de moi',
                                    canModify: true,
                                    email: widget.email,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ProfileDataField(
                                    width: 260,
                                    height: 50,
                                    content: usersFirestoreProvider
                                        .userData!['dateInscription']
                                        .substring(0, 10),
                                    label: 'Date création du compte',
                                    canModify: false,
                                    email: widget.email,
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
                        child: _auth.currentUser?.email != widget.email
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Material(
                                      borderRadius: BorderRadius.circular(40),
                                      elevation: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF26C6DA),
                                            borderRadius:
                                                BorderRadius.circular(40)),
                                        child: IconButton(
                                          icon: const Icon(Icons.arrow_back),
                                          color: Colors.blue[50],
                                          iconSize: 24.0,
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              _imageUrl == "" || _imageUrl == null
                                  ? Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
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
                                          borderRadius:
                                              BorderRadius.circular(50),
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
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        },
                                        child: CircleAvatar(
                                          radius: 45,
                                          backgroundImage:
                                              NetworkImage(_imageUrl!),
                                        ),
                                      ),
                                    ),
                              Positioned(
                                top: 66,
                                left: 58,
                                child: SizedBox(
                                    height: 32,
                                    width: 32,
                                    child:
                                        widget.email == _auth.currentUser?.email
                                            ? IconButton.filled(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStatePropertyAll(
                                                            Colors.teal[100])),
                                                icon: const Icon(
                                                    Icons.add_a_photo),
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
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              content: SizedBox(
                                                                height: 125,
                                                                child: Column(
                                                                  children: [
                                                                    const Divider(
                                                                      color: Colors
                                                                          .black,
                                                                      thickness:
                                                                          0.5,
                                                                      height: 1,
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    ElevatedButton
                                                                        .icon(
                                                                      onPressed:
                                                                          () async {
                                                                        if (_userId ==
                                                                            null) {
                                                                          print(
                                                                              'Aucun utilisateur connecté');
                                                                          return;
                                                                        } else {
                                                                          String url = await _usersService.selectProfileImageFromCamera(
                                                                              _userId,
                                                                              usersFirestoreProvider,
                                                                              widget.email);
                                                                          setState(
                                                                              () {
                                                                            _imageUrl =
                                                                                url;
                                                                          });
                                                                        }
                                                                      },
                                                                      label:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                40.0),
                                                                        child:
                                                                            Text(
                                                                          "Caméra",
                                                                          style:
                                                                              TextStyle(color: Colors.blue[300]),
                                                                        ),
                                                                      ),
                                                                      icon:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                40.0),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .camera_alt,
                                                                          color:
                                                                              Colors.blue[300],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10.0,
                                                                    ),
                                                                    ElevatedButton
                                                                        .icon(
                                                                      onPressed:
                                                                          () async {
                                                                        if (_userId ==
                                                                            null) {
                                                                          print(
                                                                              'Aucun utilisateur connecté');
                                                                          return;
                                                                        } else {
                                                                          String url = await _usersService.selectProfileImageFromGallery(
                                                                              _userId,
                                                                              usersFirestoreProvider,
                                                                              widget.email);
                                                                          setState(
                                                                              () {
                                                                            _imageUrl =
                                                                                url;
                                                                          });
                                                                        }
                                                                      },
                                                                      label:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                40.0),
                                                                        child:
                                                                            Text(
                                                                          "Galerie",
                                                                          style:
                                                                              TextStyle(color: Colors.blue[300]),
                                                                        ),
                                                                      ),
                                                                      icon:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                40.0),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .image,
                                                                          color:
                                                                              Colors.blue[300],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              actions: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    MaterialButton(
                                                                      onPressed:
                                                                          () {
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
                                                    })
                                            : null),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      }),
    );
  }
}
