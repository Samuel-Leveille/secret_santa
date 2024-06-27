import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 0.92,
            color: Colors.white,
            child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 60.0, top: 100),
                      child: Text(
                        "Créer un groupe",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 27,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.40,
                      child: Card(
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        color: Colors.blue[50],
                        shadowColor: Colors.black45,
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nom du groupe',
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blueGrey[700],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.text_fields,
                                    color: Colors.blueGrey[700],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                maxLines: 4,
                                maxLength: 150,
                                controller: descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blueGrey[700],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.description,
                                    color: Colors.blueGrey[700],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    FloatingActionButton.extended(
                      onPressed: _createGroup,
                      backgroundColor: Colors.teal[50],
                      extendedPadding:
                          const EdgeInsets.only(left: 120, right: 120),
                      label: const Text("Créer"),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    String groupName = nameController.text;
    String groupDescription = descriptionController.text;
    final User? user = _auth.currentUser;
    final String groupId;

    if (groupName.isEmpty || groupDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    } else if (user != null) {
      DocumentReference docRef = await _firestore.collection('groups').add({
        'name': groupName,
        'description': groupDescription,
        'admin': user.email
      });
      nameController.text = "";
      descriptionController.text = "";
      groupId = docRef.id;
      _addGroupToCurrentUser(user, groupId);
    }
  }

  Future<void> _addGroupToCurrentUser(User user, String groupId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot.docs.first.reference;
      await docRef.update({
        'groupsId': FieldValue.arrayUnion([groupId])
      });
    } else {
      print("QuerySnapshot vide.");
    }
  }
}
