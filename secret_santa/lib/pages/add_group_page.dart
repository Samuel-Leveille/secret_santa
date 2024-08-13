import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secret_santa/pages/group_page.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final moneyController = TextEditingController();
  final datePigeController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        datePigeController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Créer un Groupe",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Colors.teal[300],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Nom du groupe',
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.teal[700],
                                ),
                                prefixIcon: Icon(
                                  Icons.group,
                                  color: Colors.teal[700],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: moneyController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: "Montant max / personne",
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.teal[700],
                                ),
                                prefixIcon: Icon(
                                  Icons.attach_money_outlined,
                                  color: Colors.teal[700],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: datePigeController,
                                  decoration: InputDecoration(
                                    labelText: "Lancement de la pige",
                                    labelStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.teal[700],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.date_range,
                                      color: Colors.teal[700],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: descriptionController,
                              maxLines: 3,
                              maxLength: 150,
                              decoration: InputDecoration(
                                labelText: 'À propos du groupe',
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.teal[700],
                                ),
                                prefixIcon: Icon(
                                  Icons.description,
                                  color: Colors.teal[700],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 128, 203, 196),
                            Color.fromARGB(255, 38, 166, 154),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _createGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          "Créer",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    String groupName = nameController.text.trim();
    String groupDescription = descriptionController.text.trim();
    String moneyMax = moneyController.text;
    String pigeDate = datePigeController.text;
    final User? user = _auth.currentUser;

    if (groupName.isEmpty ||
        moneyMax.isEmpty ||
        pigeDate.isEmpty ||
        groupDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    } else if (user != null) {
      DocumentReference docRef = await _firestore.collection('groups').add({
        'name': groupName,
        'description': groupDescription,
        'admin': user.email,
        'participants': [user.email],
        'dateCreation': DateTime.now().toString(),
        'moneyMax': moneyMax,
        'pigeDate': pigeDate
      });

      await docRef.update({'id': docRef.id});
      nameController.clear();
      descriptionController.clear();
      moneyController.clear();
      datePigeController.clear();
      _addGroupToCurrentUser(user, docRef.id);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GroupPage(groupId: docRef.id),
        ),
      );
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
