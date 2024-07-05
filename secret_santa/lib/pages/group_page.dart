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
      print("Error : name and firstname couldn't be fetch");
    }

    if (email == _groupProvider?.groupData?['admin']) {
      name = "$name (Admin)";
    }

    return name;
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
              if (group == null) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.blue[300],
                ));
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5, left: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BackButton(
                          color: Colors.black,
                        ),
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
                              fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                  group['admin'] == _auth.currentUser?.email
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: ElevatedButton(
                            onPressed: () {},
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
                  Consumer<UsersFirestoreProvider>(
                      builder: (context, provider, child) {
                    List<dynamic> participants = [];
                    participants = group['participants'];

                    return Expanded(
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
                                            Row(
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
                                                        color: Colors.grey[500],
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 25.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const GiftsPage()));
                                                },
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.blue[200],
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color: Colors.grey,
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
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
