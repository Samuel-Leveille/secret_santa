import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/providers/gift_images_provider.dart';
import 'package:secret_santa/providers/gifts_provider.dart';
import 'package:secret_santa/providers/groups_firestore_provider.dart';
import 'package:secret_santa/services/users_service.dart';
import 'package:secret_santa/services/gifts_service.dart';
import 'package:secret_santa/providers/users_firestore_provider.dart';
import 'package:flutter/services.dart';

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
  GiftsProvider? _giftsProvider;
  GroupsFirestoreProvider? _groupsProvider;
  final _auth = FirebaseAuth.instance;
  final List<Widget> _linkFields = [];
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<TextEditingController> linksController = [];
  bool _isTitleEmpty = false;
  String? _userId;
  bool erreurNbreImage = false;
  Map<String, dynamic>? gift;
  bool isLoading = true;
  bool areGiftsLoading = true;
  late List<String> listOfGiftIds;

  GiftsService giftsService = GiftsService();

  final UsersService _usersService = UsersService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _giftsProvider = Provider.of<GiftsProvider>(context, listen: false);
      _userProvider =
          Provider.of<UsersFirestoreProvider>(context, listen: false);
      _groupsProvider =
          Provider.of<GroupsFirestoreProvider>(context, listen: false);

      final userEmail = widget.participant;
      if (userEmail!.isNotEmpty) {
        await _userProvider!.fetchUserData(userEmail);
        _loadGiftsData(userEmail);
      } else {
        print(
            "Les cadeaux n'ont pas pu être chargé, car le email de l'utilisateur est vide.");
      }
      _loadUserId();
    });
  }

  Future<void> _loadGiftsData(String userEmail) async {
    _giftsProvider!.emptyGifts();
    _groupsProvider!.emptyGifts();
    await _groupsProvider?.fetchGiftsIdOfAParticipant(
        widget.groupId, userEmail);
    listOfGiftIds = _groupsProvider!.giftsIdOfAParticipant;
    if (listOfGiftIds != [] || listOfGiftIds.isNotEmpty) {
      await Future.wait(listOfGiftIds.map(
        (giftId) => _giftsProvider!.fetchGiftDataById(giftId),
      ));
    }
    setState(() {
      isLoading = false;
      areGiftsLoading = false;
    });
  }

  Future<void> _loadUserId() async {
    String loadedUserId = await _usersService.getUserId();
    setState(() {
      _userId = loadedUserId;
    });
  }

  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1,
              maxScale: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl),
              ),
            ),
          ),
        ),
      ),
    );
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
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.white,
          leading: BackButton(
            color: Colors.black,
            onPressed: () {
              Provider.of<GiftImagesProvider>(context, listen: false)
                  .removeAllImage();
              Navigator.pop(context);
            },
          ),
          actions: [
            Consumer2<UsersFirestoreProvider, GroupsFirestoreProvider>(
              builder: (context, provider, groupsProvider, child) {
                if (widget.participant == _auth.currentUser?.email) {
                  Map<String, dynamic>? group = groupsProvider.groupData;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                    child: group?['pigeStatus'] == 'INACTIVE'
                        ? OutlinedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25.0)),
                                ),
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        child: GestureDetector(
                                          onTap: () => FocusManager
                                              .instance.primaryFocus
                                              ?.unfocus(),
                                          child: Container(
                                            height: 600,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          25.0)),
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
                                                        BorderRadius.circular(
                                                            10),
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    children: [
                                                      TextField(
                                                        controller:
                                                            titleController,
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              25),
                                                        ],
                                                        decoration:
                                                            InputDecoration(
                                                          labelText: 'Titre',
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          errorText: _isTitleEmpty
                                                              ? 'Le titre est obligatoire'
                                                              : null,
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      TextField(
                                                        controller:
                                                            descriptionController,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'À propos (facultatif)',
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                        ),
                                                        maxLines: 3,
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      ..._linkFields,
                                                      const SizedBox(
                                                          height: 10),
                                                      ElevatedButton.icon(
                                                        onPressed: () {
                                                          setState(() {
                                                            _addLinkField();
                                                          });
                                                        },
                                                        icon: const Icon(
                                                            Icons.add),
                                                        label: const Text(
                                                            'Ajouter un lien'),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Colors.blue
                                                                  .shade800,
                                                          backgroundColor:
                                                              Colors.blue
                                                                  .shade100,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      12.0),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Consumer<
                                                              GiftImagesProvider>(
                                                          builder: (context,
                                                              giftImagesProvider,
                                                              child) {
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
                                                          itemCount:
                                                              giftImagesProvider
                                                                  .giftImages
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              children: [
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        200],
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                    child: Image
                                                                        .memory(
                                                                      giftImagesProvider
                                                                              .giftImages[
                                                                          index],
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) {
                                                                        return const Center(
                                                                            child:
                                                                                Text('Erreur image'));
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 30,
                                                                  height: 30,
                                                                  decoration: const BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.only(
                                                                              bottomRight: Radius.circular(8))),
                                                                  child:
                                                                      IconButton
                                                                          .filled(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            0),
                                                                    style:
                                                                        const ButtonStyle(
                                                                      backgroundColor:
                                                                          MaterialStatePropertyAll(
                                                                        Colors
                                                                            .transparent,
                                                                      ),
                                                                    ),
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .delete),
                                                                    color: Colors
                                                                            .red[
                                                                        400],
                                                                    iconSize:
                                                                        24,
                                                                    onPressed:
                                                                        () {
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
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }),
                                                      Consumer<
                                                          GiftImagesProvider>(
                                                        builder: (context,
                                                            giftImagesProvider,
                                                            child) {
                                                          return SizedBox(
                                                              height: erreurNbreImage ||
                                                                      giftImagesProvider
                                                                          .giftImages
                                                                          .isNotEmpty
                                                                  ? 10
                                                                  : 0);
                                                        },
                                                      ),
                                                      Consumer<
                                                          GiftImagesProvider>(
                                                        builder: (context,
                                                            giftImagesProvider,
                                                            child) {
                                                          return ElevatedButton
                                                              .icon(
                                                            onPressed: giftImagesProvider
                                                                        .giftImages
                                                                        .length <
                                                                    3
                                                                ? () {
                                                                    setState(
                                                                        () {
                                                                      erreurNbreImage =
                                                                          false;
                                                                    });
                                                                    giftsService.selectImageFromGallery(
                                                                        _userId,
                                                                        context);
                                                                  }
                                                                : null,
                                                            icon: const Icon(
                                                                Icons.image),
                                                            label: const Text(
                                                                'Ajouter une image'),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              foregroundColor:
                                                                  Colors.blue
                                                                      .shade800,
                                                              backgroundColor:
                                                                  Colors.blue
                                                                      .shade100,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12.0),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      ElevatedButton.icon(
                                                        onPressed: () async {
                                                          bool trueOrFalse =
                                                              await giftsService.saveGift(
                                                                  context,
                                                                  titleController
                                                                      .text,
                                                                  descriptionController
                                                                      .text,
                                                                  linksController,
                                                                  widget
                                                                      .groupId,
                                                                  _userId,
                                                                  _userProvider);
                                                          titleController
                                                              .clear();
                                                          descriptionController
                                                              .clear();
                                                          _linkFields.clear();
                                                          linksController
                                                              .clear();
                                                          if (trueOrFalse ==
                                                              false) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }

                                                          setState(
                                                            () {
                                                              _isTitleEmpty =
                                                                  trueOrFalse;
                                                            },
                                                          );
                                                          final userEmail =
                                                              _auth.currentUser
                                                                  ?.email;
                                                          if (userEmail!
                                                              .isNotEmpty) {
                                                            _loadGiftsData(
                                                                userEmail);
                                                          } else {
                                                            print(
                                                                "Les cadeaux n'ont pas pu être chargé, car le email de l'utilisateur est vide.");
                                                          }
                                                        },
                                                        icon: const Icon(Icons
                                                            .card_giftcard),
                                                        label: const Text(
                                                          'Ajouter',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Colors.green
                                                                  .shade800,
                                                          backgroundColor:
                                                              Colors.green
                                                                  .shade100,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      12.0),
                                                        ),
                                                      ),
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 15.0),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.info,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            Text(
                                                              "  L'ajout de liens et d'images\n  est fortement recommandé",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey),
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
                            label: const Text(
                              "Ajouter un souhait",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            icon: const Icon(
                              Icons.add,
                              color: Colors.black,
                            ),
                          )
                        : Container(),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Center(
            child: Consumer<UsersFirestoreProvider>(
              builder: (context, provider, child) {
                final user = provider.userData;
                if (isLoading || areGiftsLoading) {
                  return const CircularProgressIndicator();
                }
                if (user != null &&
                    widget.participant != null &&
                    user.isNotEmpty) {
                  if (listOfGiftIds.isEmpty &&
                      widget.participant == _auth.currentUser?.email) {
                    return Text(
                      "  Ajoutez votre\npremier souhait",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    );
                  } else if (widget.participant == user['email'] &&
                      listOfGiftIds.isNotEmpty) {
                    return Consumer2<GiftsProvider, GroupsFirestoreProvider>(
                      builder: (context, provider, groupsProvider, child) {
                        Map<String, dynamic>? group = groupsProvider.groupData;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                  top: 12.0, left: 20.0, bottom: 18.0),
                              child: Text(
                                "Liste de souhaits",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2),
                                itemCount: _groupsProvider!
                                    .giftsIdOfAParticipant.length,
                                itemBuilder: (context, index) {
                                  final gift = provider.getGiftById(
                                      _groupsProvider!
                                          .giftsIdOfAParticipant[index]);
                                  final giftLinks = gift?['links'];
                                  if (gift == null) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (gift['status'] == "ACTIVE") {
                                    return GestureDetector(
                                      onTap: () {
                                        (gift['description'] == null ||
                                                    gift['description']
                                                        .isEmpty) &&
                                                gift['links'] == null &&
                                                gift['images'] == null
                                            ? ""
                                            : showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            bottom: 12.0,
                                                            left: 24.0,
                                                            right: 24.0),
                                                    titlePadding:
                                                        const EdgeInsets.only(
                                                            right: 16.0,
                                                            left: 24.0,
                                                            top: 12.0,
                                                            bottom: 6.0),
                                                    title: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 8.0),
                                                            child: Text(
                                                              gift['title'],
                                                              style: const TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                        widget.participant ==
                                                                    _auth
                                                                        .currentUser
                                                                        ?.email &&
                                                                group?['pigeStatus'] ==
                                                                    'INACTIVE'
                                                            ? IconButton.filled(
                                                                onPressed: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return AlertDialog(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(24)),
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        contentPadding: const EdgeInsets
                                                                            .fromLTRB(
                                                                            24,
                                                                            20,
                                                                            24,
                                                                            22),
                                                                        titlePadding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                22),
                                                                        title:
                                                                            const Column(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.delete_forever,
                                                                              size: 48,
                                                                              color: Colors.redAccent,
                                                                            ),
                                                                            SizedBox(height: 12),
                                                                            Text(
                                                                              'Supprimer le souhait ?',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                fontSize: 20,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        content:
                                                                            const Text(
                                                                          'Êtes-vous sûr de vouloir supprimer ce souhait ? Cette action est irréversible.',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                        ),
                                                                        actionsPadding: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                12,
                                                                            right:
                                                                                16,
                                                                            left:
                                                                                16),
                                                                        actionsAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        actions: [
                                                                          OutlinedButton(
                                                                            onPressed: () =>
                                                                                Navigator.of(context).pop(),
                                                                            style:
                                                                                OutlinedButton.styleFrom(
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                                              side: const BorderSide(color: Colors.grey),
                                                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                                            ),
                                                                            child:
                                                                                const Text(
                                                                              'Annuler',
                                                                              style: TextStyle(fontSize: 16, color: Colors.black87),
                                                                            ),
                                                                          ),
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () async {
                                                                              Navigator.of(context).pop();
                                                                              Navigator.of(context).pop();
                                                                              final userEmail = _auth.currentUser?.email;
                                                                              await giftsService.deleteGift(_groupsProvider!.giftsIdOfAParticipant[index]);
                                                                              if (userEmail != null && userEmail.isNotEmpty) {
                                                                                await _loadGiftsData(userEmail);
                                                                              }
                                                                            },
                                                                            style:
                                                                                ElevatedButton.styleFrom(
                                                                              backgroundColor: Colors.redAccent,
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                                            ),
                                                                            child:
                                                                                const Text(
                                                                              'Supprimer',
                                                                              style: TextStyle(fontSize: 16, color: Colors.black),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons.delete,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          180,
                                                                          180,
                                                                          180),
                                                                  size: 26,
                                                                ),
                                                                style: const ButtonStyle(
                                                                    backgroundColor:
                                                                        MaterialStatePropertyAll(Color.fromARGB(
                                                                            255,
                                                                            241,
                                                                            241,
                                                                            241))),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10.0),
                                                                  child: Text(
                                                                    gift['description'] !=
                                                                                null &&
                                                                            gift['description']
                                                                                .trim()
                                                                                .isNotEmpty
                                                                        ? gift[
                                                                            'description']
                                                                        : "",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          if (giftLinks != null)
                                                            ...giftLinks
                                                                .map((link) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            8),
                                                                child: InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    await Clipboard.setData(
                                                                        ClipboardData(
                                                                            text:
                                                                                link));
                                                                  },
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const Icon(
                                                                          Icons
                                                                              .link,
                                                                          size:
                                                                              18,
                                                                          color:
                                                                              Colors.blue),
                                                                      const SizedBox(
                                                                          width:
                                                                              6),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          link,
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.blue,
                                                                            decoration:
                                                                                TextDecoration.underline,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                          gift['images'] !=
                                                                      null &&
                                                                  gift['images']
                                                                      .isNotEmpty
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              12.0),
                                                                  child: GridView
                                                                      .builder(
                                                                    gridDelegate:
                                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                                      crossAxisCount:
                                                                          3,
                                                                      crossAxisSpacing:
                                                                          8,
                                                                      mainAxisSpacing:
                                                                          8,
                                                                    ),
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        const NeverScrollableScrollPhysics(),
                                                                    itemCount: gift[
                                                                            'images']
                                                                        .length
                                                                        .clamp(
                                                                            0,
                                                                            3),
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return GestureDetector(
                                                                        onTap: () => showImageDialog(
                                                                            context,
                                                                            gift['images'][index]),
                                                                        child:
                                                                            Stack(
                                                                          alignment:
                                                                              Alignment.topRight,
                                                                          children: [
                                                                            Container(
                                                                              width: double.infinity,
                                                                              height: double.infinity,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.grey[200],
                                                                                borderRadius: BorderRadius.circular(8),
                                                                              ),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8),
                                                                                child: Image.network(
                                                                                  gift['images'][index],
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) {
                                                                                    return const Center(child: Text('Erreur image'));
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)), color: Colors.white),
                                                                              child: const Icon(
                                                                                Icons.zoom_in,
                                                                                color: Color.fromARGB(255, 53, 131, 187),
                                                                                size: 28,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                )
                                                              : Container(),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              32.0),
                                                                  child:
                                                                      FilledButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    style: const ButtonStyle(
                                                                        backgroundColor: MaterialStatePropertyAll(Color.fromARGB(
                                                                            255,
                                                                            241,
                                                                            241,
                                                                            241))),
                                                                    child:
                                                                        const Padding(
                                                                      padding: EdgeInsets.only(
                                                                          top:
                                                                              12.0,
                                                                          bottom:
                                                                              12.0),
                                                                      child:
                                                                          Text(
                                                                        "Fermer",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.blueAccent),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.white,
                                                  );
                                                });
                                      },
                                      child: Card(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(22.0),
                                          ),
                                          elevation: 10,
                                          margin: index % 2 == 0
                                              ? const EdgeInsets.only(
                                                  top: 12.0,
                                                  bottom: 12.0,
                                                  left: 16.0,
                                                  right: 8.0)
                                              : const EdgeInsets.only(
                                                  top: 12.0,
                                                  bottom: 12.0,
                                                  left: 8.0,
                                                  right: 16.0),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                  flex: 7,
                                                  child: gift['images'] !=
                                                              null &&
                                                          gift['images']
                                                              .isNotEmpty
                                                      ? Container(
                                                          decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                  image: NetworkImage(
                                                                      gift['images']
                                                                          [0])),
                                                              borderRadius: const BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          22),
                                                                  topRight:
                                                                      Radius.circular(
                                                                          22))))
                                                      : Container(
                                                          decoration: const BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          22),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          22))),
                                                          child: const Icon(
                                                            Icons.card_giftcard,
                                                            size: 50,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    43,
                                                                    103,
                                                                    167),
                                                          ),
                                                        )),
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 43, 103, 167),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(22),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          22))),
                                                  child: Center(
                                                      child: Text(
                                                    gift['title'],
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Color.fromARGB(
                                                            225,
                                                            255,
                                                            255,
                                                            255)),
                                                  )),
                                                ),
                                              )
                                            ],
                                          )),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
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
    );
  }
}
