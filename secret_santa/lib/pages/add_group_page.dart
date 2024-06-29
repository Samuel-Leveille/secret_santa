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
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Créer un groupe",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nom du groupe',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.teal[800],
                            ),
                            prefixIcon: Icon(
                              Icons.group,
                              color: Colors.teal[800],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          maxLength: 150,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.teal[800],
                            ),
                            prefixIcon: Icon(
                              Icons.description,
                              color: Colors.teal[800],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Créer",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    String groupName = nameController.text;
    String groupDescription = descriptionController.text;
    final User? user = _auth.currentUser;

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
      nameController.clear();
      descriptionController.clear();
      _addGroupToCurrentUser(user, docRef.id);
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
