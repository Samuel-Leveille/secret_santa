import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/providers/gift_images_provider.dart';
import 'package:secret_santa/services/users_service.dart';
import 'package:secret_santa/services/gifts_service.dart';
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
  bool _isTitleEmpty = false;
  String? _userId;
  bool erreurNbreImage = false;

  GiftsService giftsService = GiftsService();

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
      _loadUserId();
    });
  }

  Future<void> _loadUserId() async {
    String loadedUserId = await _usersService.getUserId();
    setState(() {
      _userId = loadedUserId;
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

  @override
  void dispose() {
    for (var controller in linksController) {
      controller.dispose();
    }
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
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
                                                          giftsService
                                                              .selectImageFromGallery(
                                                                  _userId,
                                                                  context);
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
                                              onPressed: () async {
                                                bool trueOrFalse =
                                                    await giftsService.saveGift(
                                                        context,
                                                        titleController.text,
                                                        descriptionController
                                                            .text,
                                                        linksController,
                                                        widget.groupId,
                                                        _userId,
                                                        _userProvider);
                                                titleController.clear();
                                                descriptionController.clear();
                                                _linkFields.clear();
                                                linksController.clear();
                                                if (trueOrFalse == false) {
                                                  Navigator.of(context).pop();
                                                }

                                                setState(
                                                  () {
                                                    _isTitleEmpty = trueOrFalse;
                                                  },
                                                );
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
