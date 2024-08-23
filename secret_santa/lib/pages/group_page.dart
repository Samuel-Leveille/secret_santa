import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/pages/gifts_page.dart';
import 'package:secret_santa/utils/groups_firestore_provider.dart';
import 'package:secret_santa/utils/users_firestore_provider.dart';

class GroupPage extends StatefulWidget {
  final String groupId;
  const GroupPage({super.key, required this.groupId});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  GroupsFirestoreProvider? _groupProvider;
  UsersFirestoreProvider? _userProvider;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupProvider =
          Provider.of<GroupsFirestoreProvider>(context, listen: false);
      _groupProvider?.fetchGroupData(widget.groupId);

      _userProvider =
          Provider.of<UsersFirestoreProvider>(context, listen: false);
      final userEmail = _auth.currentUser?.email;
      if (userEmail != null) {
        _userProvider?.fetchUserData(userEmail);
      } else {
        Center(
            child: CircularProgressIndicator(
          color: Colors.blue[300],
        ));
        print("Erreur : Aucun utilisateur connecté ou email non disponible.");
      }
    });
  }

  Future<String> getUserName(String email) async {
    String name = "Nom inconnu";
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      name =
          "${(querySnapshot.docs.first.data() as Map<String, dynamic>)['firstName'] ?? ""} ${(querySnapshot.docs.first.data() as Map<String, dynamic>)['name'] ?? ""}";
    } else {
      print("Error : name and firstname couldn't be fetched");
    }

    if (email == _groupProvider?.groupData?['admin']) {
      name = "$name (Admin)";
    }
    return name;
  }

  Future<List<dynamic>> getAdminFriends(BuildContext context) async {
    String adminEmail = _auth.currentUser?.email as String;
    final userProvider =
        Provider.of<UsersFirestoreProvider>(context, listen: false);
    await userProvider.fetchUserData(adminEmail);
    return userProvider.userData?['friends'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Consumer<GroupsFirestoreProvider>(
            builder: (context, provider, child) {
              final group = provider.groupData;
              List<dynamic> participants = [];
              if (group == null) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.blue[300],
                ));
              }
              participants = group['participants'];
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BackButton(
                          color: Colors.black,
                        ),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.30,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 10,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: const Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 14.0, bottom: 8.0),
                                                child: Text(
                                                  "Paramètre du groupe",
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              Divider(),
                                            ],
                                          ),
                                        ));
                                  });
                            },
                            icon: const Icon(Icons.more_horiz))
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 15, bottom: 10, left: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          group['name'],
                          style: const TextStyle(
                              fontSize: 28.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40.0, right: 30),
                          child: Text(
                            group['description'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 40.0),
                        child: Icon(
                          Icons.monetization_on,
                          color: Color.fromARGB(255, 83, 154, 86),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Montant",
                      ),
                      const Text(
                        " MAX",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(" par personne : "),
                      Text(
                        "${group['moneyMax']}\$",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 40.0),
                        child: Icon(
                          Icons.calendar_today,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("Lancement de la pige : "),
                      Text(
                        group['pigeDate'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text(
                          "Participants",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                  group['admin'] == _auth.currentUser?.email
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return FutureBuilder<List<dynamic>>(
                                    future: getAdminFriends(context),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.blue[300],
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return const Text('Erreur',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500));
                                      } else {
                                        List<dynamic> adminFriends =
                                            snapshot.data ?? [];
                                        List<dynamic> participants =
                                            group['participants'];
                                        List<dynamic> nonParticipants =
                                            adminFriends
                                                .where((friend) => !participants
                                                    .contains(friend))
                                                .toList();

                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.85,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.6,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 10,
                                                      offset: Offset(0, 5),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 10.0),
                                                        child: Center(
                                                          child: Text(
                                                            "Ajouter des participants",
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      nonParticipants.isEmpty
                                                          ? Center(
                                                              child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              130.0),
                                                                  child: Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.6,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                152.4),
                                                                        child:
                                                                            RichText(
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          text:
                                                                              const TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: "Aucun participant\n",
                                                                                style: TextStyle(
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Colors.grey,
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: "à ajouter",
                                                                                style: TextStyle(
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Colors.grey,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )),
                                                            )
                                                          : Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                itemCount:
                                                                    nonParticipants
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return FutureBuilder(
                                                                    future: getUserName(
                                                                        nonParticipants[
                                                                            index]),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .waiting) {
                                                                        return Center(
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            color:
                                                                                Colors.blue[300],
                                                                          ),
                                                                        );
                                                                      } else if (snapshot
                                                                          .hasError) {
                                                                        return const Text(
                                                                            'Erreur',
                                                                            style:
                                                                                TextStyle(fontSize: 18, fontWeight: FontWeight.w500));
                                                                      } else {
                                                                        return Column(
                                                                          children: [
                                                                            ListTile(
                                                                              contentPadding: const EdgeInsets.all(
                                                                                10.0,
                                                                              ),
                                                                              title: Text(
                                                                                snapshot.data as String,
                                                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                                                              ),
                                                                              trailing: ElevatedButton(
                                                                                onPressed: () {
                                                                                  provider.addParticipantToGroup(
                                                                                    group['id'],
                                                                                    nonParticipants[index],
                                                                                    () {
                                                                                      setState(() {
                                                                                        provider.fetchGroupData(widget.groupId);
                                                                                        nonParticipants.remove(nonParticipants[index]);
                                                                                      });
                                                                                      provider.fetchGroupData(group['id']);
                                                                                    },
                                                                                  );
                                                                                },
                                                                                style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.cyan[100],
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(15.0),
                                                                                    )),
                                                                                child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
                                                                              ),
                                                                            ),
                                                                            const Divider(
                                                                              thickness: 0.5,
                                                                            )
                                                                          ],
                                                                        );
                                                                      }
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                      ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStateProperty
                                                                  .all<Color>(Colors
                                                                      .teal
                                                                      .shade100),
                                                          foregroundColor:
                                                              WidgetStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .white),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            "Terminer"),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.cyan[100],
                            ),
                            child: const Text(
                              "Ajouter des participants",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<dynamic>(
                            future: getUserName(participants[index]),
                            builder:
                                (context, AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.blue[300],
                                ));
                              } else if (snapshot.hasError) {
                                return const Text('Erreur',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500));
                              } else {
                                return Column(
                                  children: [
                                    index == 0
                                        ? Divider(
                                            color: Colors.grey[300],
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 75,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _auth.currentUser?.email ==
                                                  participants[index]
                                              ? Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Icon(
                                                        Icons.person,
                                                        color:
                                                            Colors.green[700],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5.0),
                                                      child: Text(
                                                        snapshot.data,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .green[500],
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5.0),
                                                      child: Text(
                                                        snapshot.data,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[500],
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          Row(
                                            children: [
                                              participants[index] !=
                                                          group['admin'] &&
                                                      _auth.currentUser
                                                              ?.email ==
                                                          group['admin']
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return Dialog(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20.0),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.25,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.30,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.0),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black12,
                                                                        blurRadius:
                                                                            10,
                                                                        offset: Offset(
                                                                            0,
                                                                            5),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                12.0,
                                                                            right:
                                                                                12.0,
                                                                            bottom:
                                                                                20.0),
                                                                        child:
                                                                            Text(
                                                                          "Retirer cet utilisateur\n        du groupe ?",
                                                                          style: TextStyle(
                                                                              fontSize: 22,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                45,
                                                                            child:
                                                                                FittedBox(
                                                                              child: FloatingActionButton.extended(
                                                                                  extendedPadding: const EdgeInsets.only(left: 35.0, right: 35.0),
                                                                                  backgroundColor: Colors.red[100],
                                                                                  foregroundColor: Colors.black,
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  label: const Text(
                                                                                    'Annuler',
                                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                45,
                                                                            child:
                                                                                FittedBox(
                                                                              child: FloatingActionButton.extended(
                                                                                  extendedPadding: const EdgeInsets.only(left: 35.0, right: 35.0),
                                                                                  backgroundColor: Colors.teal[100],
                                                                                  foregroundColor: Colors.black,
                                                                                  onPressed: () {
                                                                                    try {
                                                                                      String deletedUser = participants[index];
                                                                                      provider.removeParticipantFromGroup(group['id'], deletedUser, () {
                                                                                        setState(() {
                                                                                          provider.fetchGroupData(group['id']);
                                                                                        });
                                                                                      });
                                                                                      Navigator.of(context).pop();
                                                                                    } catch (e) {
                                                                                      print("L'utilisateur n'a pas pu être retiré du groupe : $e");
                                                                                    }
                                                                                  },
                                                                                  label: const Text(
                                                                                    'Retirer',
                                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                                                  )),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .white,
                                                                boxShadow: [
                                                              BoxShadow(
                                                                  color: Colors
                                                                      .grey,
                                                                  blurRadius: 6,
                                                                  offset:
                                                                      Offset(
                                                                          0, 3),
                                                                  spreadRadius:
                                                                      0)
                                                            ]),
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 30,
                                                          color:
                                                              Colors.red[300],
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 20.0, left: 15.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    GiftsPage(
                                                                      participant:
                                                                          participants[
                                                                              index],
                                                                    )));
                                                  },
                                                  child: Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.blue[200],
                                                        boxShadow: const [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              blurRadius: 6,
                                                              offset:
                                                                  Offset(0, 3),
                                                              spreadRadius: 0)
                                                        ]),
                                                    child: const Icon(
                                                        Icons.card_giftcard),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey[300],
                                    ),
                                  ],
                                );
                              }
                            },
                          );
                        }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
