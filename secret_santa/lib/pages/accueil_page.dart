import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/pages/group_page.dart';
import 'package:secret_santa/providers/groups_firestore_provider.dart';
import 'package:secret_santa/providers/users_firestore_provider.dart';
import 'package:secret_santa/services/users_service.dart';
import 'package:secret_santa/services/groups_service.dart';
import 'package:secret_santa/utils/generate_color.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  GroupsFirestoreProvider? _groupsFirestoreProvider;
  UsersFirestoreProvider? _usersFirestoreProvider;
  final _auth = FirebaseAuth.instance;
  final _pageController = PageController(initialPage: 0);
  bool isLoading = true;

  final UsersService _usersService = UsersService();
  final GroupsService _groupsService = GroupsService();
  final GenerateColor _generateColor = GenerateColor();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroupsData();
      _loadUserData();
      isLoading = false;
    });
  }

  void _loadGroupsData() async {
    _groupsFirestoreProvider =
        Provider.of<GroupsFirestoreProvider>(context, listen: false);
    await _groupsFirestoreProvider?.fetchGroupsData();
  }

  void _loadUserData() async {
    _usersFirestoreProvider =
        Provider.of<UsersFirestoreProvider>(context, listen: false);
    await _usersFirestoreProvider
        ?.fetchUserData(_auth.currentUser!.email as String);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Consumer2<GroupsFirestoreProvider?, UsersFirestoreProvider?>(
            builder: (context, groupsProvider, userProvider, child) {
              final groupsData = groupsProvider?.groupsData;
              final userData = userProvider?.userData;
              if ((userData?['groupsId'] ?? []).isEmpty) {
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
                return isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                                left: 30.0, top: 50.0, bottom: 40.0),
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
                                itemCount: groupsData?.length,
                                controller: _pageController,
                                itemBuilder: (context, index) {
                                  final group = groupsData?[index];
                                  return FutureBuilder(
                                    future: _usersService
                                        .getUserNameByEmail(group?['admin']),
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
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                String theGroupId =
                                                    _groupsService
                                                        .getGroupId(group);
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            GroupPage(
                                                              groupId:
                                                                  theGroupId,
                                                            )));
                                              },
                                              child: Card(
                                                color: _generateColor
                                                    .generateSoftColor(),
                                                elevation: 8,
                                                shadowColor: Colors.grey
                                                    .withOpacity(0.6),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16.0,
                                                          right: 10.0,
                                                          bottom: 10.0,
                                                          top: 5.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          IconButton(
                                                              onPressed: () {
                                                                String
                                                                    groupAdminEmail =
                                                                    group?[
                                                                        'admin'];
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(24.0),
                                                                      ),
                                                                      contentPadding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          24,
                                                                          20,
                                                                          24,
                                                                          8),
                                                                      titlePadding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              16),
                                                                      title:
                                                                          Column(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.warning_rounded,
                                                                            size:
                                                                                48,
                                                                            color:
                                                                                Colors.redAccent,
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 12),
                                                                          groupAdminEmail == _auth.currentUser!.email
                                                                              ? const Text(
                                                                                  "Supprimer le groupe ?",
                                                                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                                                                )
                                                                              : const Text(
                                                                                  "Quitter le groupe ?",
                                                                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                                                                ),
                                                                        ],
                                                                      ),
                                                                      content: groupAdminEmail ==
                                                                              _auth.currentUser!.email
                                                                          ? const Text(
                                                                              'Êtes-vous sûr de vouloir supprimer ce groupe ? Cette action est irréversible.',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                fontSize: 16,
                                                                                color: Colors.black87,
                                                                              ),
                                                                            )
                                                                          : const Text(
                                                                              'Êtes-vous sûr de vouloir quitter ce groupe ?',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                fontSize: 16,
                                                                                color: Colors.black87,
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
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      actions: [
                                                                        OutlinedButton(
                                                                          onPressed: () =>
                                                                              Navigator.of(context).pop(),
                                                                          style:
                                                                              OutlinedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                                            side:
                                                                                const BorderSide(color: Colors.grey),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                                          ),
                                                                          child:
                                                                              const Text(
                                                                            'Annuler',
                                                                            style:
                                                                                TextStyle(fontSize: 16, color: Colors.black87),
                                                                          ),
                                                                        ),
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            if (groupAdminEmail ==
                                                                                _auth.currentUser!.email) {
                                                                              try {
                                                                                String deletedGroupId = _groupsService.getGroupId(group);
                                                                                _groupsService.deleteGroup(deletedGroupId, () {
                                                                                  setState(() {
                                                                                    groupsProvider?.fetchGroupsData();
                                                                                  });
                                                                                });
                                                                                Navigator.of(context).pop();
                                                                              } catch (e) {
                                                                                print("Le groupe n'a pas pu être supprimé : $e");
                                                                              }
                                                                            } else {
                                                                              try {
                                                                                String groupId = _groupsService.getGroupId(group);
                                                                                String userWhoLeaveTheGroup = _auth.currentUser!.email as String;
                                                                                _groupsService.removeParticipantFromGroup(groupId, userWhoLeaveTheGroup, () {
                                                                                  setState(() {
                                                                                    groupsProvider?.fetchGroupsData();
                                                                                  });
                                                                                });
                                                                                Navigator.of(context).pop();
                                                                              } catch (e) {
                                                                                print("La tentative de quitter le groupe a échouée : $e");
                                                                              }
                                                                            }
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                Colors.redAccent,
                                                                            shape:
                                                                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                                          ),
                                                                          child:
                                                                              const Text(
                                                                            'Supprimer',
                                                                            style:
                                                                                TextStyle(fontSize: 16, color: Colors.black),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .more_horiz,
                                                                size: 32,
                                                                color: Colors
                                                                    .black,
                                                              ))
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 6.0),
                                                        child: Text(
                                                          group?['name'] ??
                                                              "Groupe de ${group?['admin']}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 26,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 16),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.person,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            "Créé par ${snapshot.data}",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 80,
                                                      ),
                                                      Text(
                                                        "Créé le ${group?['dateCreation'].substring(0, 10)}",
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
                              count: groupsData?.length == null
                                  ? 0
                                  : groupsData!.length,
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
