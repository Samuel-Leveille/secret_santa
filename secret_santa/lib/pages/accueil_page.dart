import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/pages/group_page.dart';
import 'package:secret_santa/utils/groups_firestore_provider.dart';
import 'package:secret_santa/utils/users_firestore_provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  GroupsFirestoreProvider? _groupsFirestoreProvider;
  UsersFirestoreProvider? _usersFirestoreProvider;
  List<Map<String, dynamic>>? groupsData;
  final _auth = FirebaseAuth.instance;
  final _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupsFirestoreProvider =
          Provider.of<GroupsFirestoreProvider>(context, listen: false);
      _groupsFirestoreProvider?.fetchGroupsData();
      _usersFirestoreProvider =
          Provider.of<UsersFirestoreProvider>(context, listen: false);
      _usersFirestoreProvider
          ?.fetchUserData(_auth.currentUser!.email as String);
    });
  }

  Color generateSoftColor() {
    int red = 200 + Random().nextInt(56);
    int green = 200 + Random().nextInt(56);
    int blue = 200 + Random().nextInt(56);
    return Color.fromARGB(255, red, green, blue);
  }

  String getGroupId(Map<String, dynamic> group) {
    return group['id'];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Consumer2<GroupsFirestoreProvider, UsersFirestoreProvider>(
            builder: (context, groupsProvider, userProvider, child) {
              final groupsData = groupsProvider.groupsData;
              final userData = userProvider.userData;
              if (userData?['groupsId'].isEmpty) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: 30.0, top: 50.0, bottom: 36.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Mes Groupes",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 180.0),
                        child: Text(
                          'Vous n\'avez aucun groupe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 30.0, top: 50.0, bottom: 40.0),
                      child: Text(
                        "Mes Groupes",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 275,
                        width: 325,
                        child: PageView.builder(
                          itemCount: groupsData.length,
                          controller: _pageController,
                          itemBuilder: (context, index) {
                            final group = groupsData[index];
                            return FutureBuilder(
                              future: getUserName(group['admin']),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return const Center(
                                    child: Text(
                                      'Erreur',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          String theGroupId = getGroupId(group);
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      GroupPage(
                                                        groupId: theGroupId,
                                                      )));
                                        },
                                        child: Card(
                                          color: generateSoftColor(),
                                          elevation: 8,
                                          shadowColor:
                                              Colors.grey.withOpacity(0.6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0,
                                                right: 10.0,
                                                bottom: 10.0,
                                                top: 5.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {
                                                          String
                                                              groupAdminEmail =
                                                              group['admin'];
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return Dialog(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.0),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.25,
                                                                    width: MediaQuery.of(context)
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
                                                                          color:
                                                                              Colors.black12,
                                                                          blurRadius:
                                                                              10,
                                                                          offset: Offset(
                                                                              0,
                                                                              5),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 12.0,
                                                                              right: 12.0,
                                                                              bottom: 20.0),
                                                                          child: groupAdminEmail == _auth.currentUser!.email
                                                                              ? const Text(
                                                                                  "Supprimer le groupe ?",
                                                                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                                                                )
                                                                              : const Text(
                                                                                  "Quitter le groupe ?",
                                                                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                                                                ),
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            SizedBox(
                                                                              height: 45,
                                                                              child: FittedBox(
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
                                                                              height: 45,
                                                                              child: FittedBox(
                                                                                child: FloatingActionButton.extended(
                                                                                    extendedPadding: const EdgeInsets.only(left: 35.0, right: 35.0),
                                                                                    backgroundColor: Colors.teal[100],
                                                                                    foregroundColor: Colors.black,
                                                                                    onPressed: () {
                                                                                      print(groupAdminEmail);
                                                                                      if (groupAdminEmail == _auth.currentUser!.email) {
                                                                                        try {
                                                                                          String deletedGroupId = getGroupId(group);
                                                                                          groupsProvider.deleteGroup(deletedGroupId, () {
                                                                                            setState(() {
                                                                                              groupsProvider.fetchGroupsData();
                                                                                            });
                                                                                          });
                                                                                          Navigator.of(context).pop();
                                                                                        } catch (e) {
                                                                                          print("Le groupe n'a pas pu être supprimé : $e");
                                                                                        }
                                                                                      } else {
                                                                                        try {
                                                                                          String groupId = getGroupId(group);
                                                                                          String userWhoLeaveTheGroup = _auth.currentUser!.email as String;
                                                                                          groupsProvider.removeParticipantFromGroup(groupId, userWhoLeaveTheGroup, () {
                                                                                            setState(() {
                                                                                              groupsProvider.fetchGroupsData();
                                                                                            });
                                                                                          });
                                                                                          Navigator.of(context).pop();
                                                                                        } catch (e) {
                                                                                          print("La tentative de quitter le groupe a échouée : $e");
                                                                                        }
                                                                                      }
                                                                                    },
                                                                                    label: const Text(
                                                                                      'Confirmer',
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
                                                        icon: const Icon(
                                                          Icons.more_horiz,
                                                          size: 32,
                                                          color: Colors.black,
                                                        ))
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 6.0),
                                                  child: Text(
                                                    group['name'] ??
                                                        "Groupe de ${group['admin']}",
                                                    style: const TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.person,
                                                      color: Colors.black54,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      "Créé par ${snapshot.data}",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 80,
                                                ),
                                                Text(
                                                  "Créé le ${group['dateCreation'].substring(0, 10)}",
                                                  style: const TextStyle(
                                                      color: Colors.grey),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: groupsData.length,
                        effect: WormEffect(
                          dotHeight: 10,
                          dotWidth: 10,
                          activeDotColor: Colors.blueAccent,
                          dotColor: Colors.grey.withOpacity(0.3),
                        ),
                        onDotClicked: (index) {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
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
