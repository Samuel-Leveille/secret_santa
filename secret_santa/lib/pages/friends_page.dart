import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secret_santa/pages/profile_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  PageController? _pageController;
  final friendEmailController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<String> _friendRequests = [];
  List<String> _friends = [];
  List<String> _receiverFriendRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController(initialPage: 0);

    _tabController?.addListener(() {
      if (_tabController!.indexIsChanging) {
        _pageController?.animateToPage(
          _tabController!.index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });

    fetchUserFriends();
    fetchCurrentUserFriendRequests();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void refreshFriendRequests() {
    fetchCurrentUserFriendRequests();
    fetchUserFriends();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 25.0, top: 70, bottom: 20),
                      child: Text(
                        "Requêtes",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder(
                    valueListenable: friendEmailController,
                    builder: (context, TextEditingValue value, child) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                        child: TextFormField(
                          controller: friendEmailController,
                          decoration: InputDecoration(
                              labelText: "Courriel",
                              suffixIcon: IconButton(
                                  onPressed: sendRequest,
                                  icon: value.text.isEmpty
                                      ? Icon(
                                          Icons.send,
                                          color: Colors.grey[600],
                                        )
                                      : const Icon(
                                          Icons.send,
                                          color: Colors.blueAccent,
                                        ))),
                        ),
                      );
                    }),
                TabBar(
                  labelColor: const Color.fromARGB(255, 134, 198, 250),
                  indicatorColor: const Color.fromARGB(255, 134, 198, 250),
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text('Amis'),
                        ],
                      ),
                    ),
                    Tab(
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text('Requêtes'),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      _tabController?.animateTo(index);
                    },
                    children: [
                      Friends(friends: _friends),
                      Requests(
                        items: _friendRequests,
                        onRequestHandled: refreshFriendRequests,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchCurrentUserFriendRequests() async {
    User? user = _auth.currentUser;
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user?.email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final List<String> friendRequests = List<String>.from(
          (querySnapshot.docs.first.data()
                  as Map<String, dynamic>)['friendRequests'] ??
              []);
      setState(() {
        _friendRequests = friendRequests;
      });
    }
  }

  Future<void> fetchReceiverFriendRequests(String email) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final List<String> friendRequests = List<String>.from(
          (querySnapshot.docs.first.data()
                  as Map<String, dynamic>)['friendRequests'] ??
              []);
      setState(() {
        _receiverFriendRequests = friendRequests;
      });
    }
  }

  Future<void> fetchUserFriends() async {
    User? user = _auth.currentUser;
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user?.email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final List<String> friends = List<String>.from((querySnapshot.docs.first
              .data() as Map<String, dynamic>)['friends'] ??
          []);
      setState(() {
        _friends = friends;
      });
    }
  }

  Future<void> sendRequest() async {
    final String friendEmail = friendEmailController.text.trim();
    User? currentUser = _auth.currentUser;
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: friendEmail)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot.docs.first.reference;

      fetchUserFriends();
      fetchReceiverFriendRequests(friendEmail);

      if (!_friends.contains(friendEmail)) {
        if (!_receiverFriendRequests.contains(currentUser?.email)) {
          docRef.update({
            'friendRequests': FieldValue.arrayUnion([currentUser!.email])
          });
          friendEmailController.text = "";
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Demande d'ami envoyée"),
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 15),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 15),
              content: Text(
                  "Vous ne pouvez pas envoyer plusieurs requêtes à la même personne"),
            ),
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 15),
            content: Text(
                "Cet utilisateur se trouve déjà dans votre répertoire d'amis"),
          ),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 15),
          content: Text("Veuillez entrer un courriel valide"),
        ),
      );
      return;
    }
  }
}

class Friends extends StatelessWidget {
  final List<String> friends;
  const Friends({super.key, required this.friends});

  @override
  Widget build(BuildContext context) {
    return friends.isNotEmpty
        ? ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(email: friends[index])),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: FutureBuilder<String>(
                        future: getUserName(friends[index]),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ));
                          } else if (snapshot.hasError) {
                            return const CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Icon(Icons.error, color: Colors.white),
                            );
                          } else {
                            return CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                snapshot.data![0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }
                        },
                      ),
                      title: FutureBuilder<String>(
                        future: getUserName(friends[index]),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Chargement...',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500));
                          } else if (snapshot.hasError) {
                            return const Text('Erreur',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500));
                          } else {
                            return Text(snapshot.data!,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500));
                          }
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.message),
                        color: Colors.grey[600],
                        onPressed: () {
                          // Logique de message ici
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : const Center(
            child: Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: Text(
              "Aucun ami",
              style: TextStyle(fontSize: 24),
            ),
          ));
  }
}

class Requests extends StatelessWidget {
  final List<String> items;
  final VoidCallback onRequestHandled;

  const Requests(
      {super.key, required this.items, required this.onRequestHandled});

  @override
  Widget build(BuildContext context) {
    return items.isNotEmpty
        ? ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: FutureBuilder<String>(
                      future: getUserName(items[index]),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: Colors.blue[300],
                          ));
                        } else if (snapshot.hasError) {
                          return const Text('Erreur',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500));
                        } else {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(snapshot.data!,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    trailing: SizedBox(
                      width: 70,
                      child: Row(
                        children: [
                          Expanded(
                              child: IconButton(
                            onPressed: () {
                              acceptFriendRequest(items[index]);
                            },
                            icon: const Icon(Icons.check),
                            iconSize: 30,
                            color: const Color.fromARGB(255, 90, 206, 93),
                          )),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: IconButton(
                            onPressed: () {
                              refuseFriendRequest(items[index]);
                            },
                            icon: const Icon(Icons.close),
                            iconSize: 30,
                            color: Colors.redAccent,
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : const Center(
            child: Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: Text(
              "Aucune demande d'ami",
              style: TextStyle(fontSize: 24),
            ),
          ));
  }

  Future<void> acceptFriendRequest(String email) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser!.email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot.docs.first.reference;
      docRef.update({
        'friends': FieldValue.arrayUnion([email])
      });
      docRef.update({
        'friendRequests': FieldValue.arrayRemove([email])
      });
      onRequestHandled();
    } else {
      print("Aucun utilisateur connecté");
    }

    QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot2.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot2.docs.first.reference;
      docRef.update({
        'friends': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      print(
          "Erreur en lien avec l'utilisateur qui a envoyé la demande d'ami (il n'existe pas apparamment)");
    }
  }

  Future<void> refuseFriendRequest(String email) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser!.email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot.docs.first.reference;
      docRef.update({
        'friendRequests': FieldValue.arrayRemove([email])
      });
      onRequestHandled();
    } else {
      print("Aucun utilisateur connecté");
    }
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
