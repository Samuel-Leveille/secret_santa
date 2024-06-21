import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/components/auth_textfield.dart';
import 'package:secret_santa/pages/profile_page.dart';
import 'package:secret_santa/utils/users_firestore_provider.dart';

class ProfileDataField extends StatefulWidget {
  final double width;
  final double height;
  final String content;
  final String label;
  final bool canModify;

  const ProfileDataField({
    super.key,
    required this.width,
    required this.height,
    required this.content,
    required this.label,
    required this.canModify,
  });

  @override
  State<ProfileDataField> createState() => _ProfileDataFieldState();
}

class _ProfileDataFieldState extends State<ProfileDataField> {
  bool isItBio = false;
  bool isItFirstName = true;

  @override
  void initState() {
    if (widget.label == "À propos de moi") {
      setState(() {
        isItBio = true;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UsersFirestoreProvider usersFirestoreProvider =
        Provider.of<UsersFirestoreProvider>(context);

    final textNameController =
        TextEditingController(text: usersFirestoreProvider.userData!['name']);
    final textFirstNameController = TextEditingController(
        text: usersFirestoreProvider.userData!['firstName']);
    final textBioController = TextEditingController(
        text: usersFirestoreProvider.userData!['biography']);

    return Container(
      width: widget.width,
      height: widget.height,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.content,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            widget.canModify == true
                ? Positioned(
                    right: -10,
                    top: -15,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.white,
                                              blurRadius: 20,
                                              offset: Offset(1, 1)),
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: isItBio == false
                                          ? Column(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    autofocus: true,
                                                    expands: true,
                                                    maxLines: null,
                                                    controller:
                                                        textFirstNameController,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      label: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 30.0),
                                                        child: Text(
                                                          isItFirstName == true
                                                              ? "Prénom"
                                                              : "Nom",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[800],
                                                              fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Divider(),
                                                Expanded(
                                                  child: TextFormField(
                                                    expands: true,
                                                    maxLines: null,
                                                    controller:
                                                        textNameController,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      label: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 30.0),
                                                        child: Text(
                                                          widget.label,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[800],
                                                              fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Divider(),
                                                Row(
                                                  children: [
                                                    TextButton(
                                                        onPressed: Navigator.of(
                                                                context)
                                                            .pop,
                                                        child: const Text(
                                                            "Annuler")),
                                                    TextButton(
                                                        onPressed: () async {
                                                          await usersFirestoreProvider
                                                              .updateTwoUserField(
                                                                  'firstName',
                                                                  textFirstNameController
                                                                      .text,
                                                                  'name',
                                                                  textNameController
                                                                      .text);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            "Confirmer"))
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    autofocus: true,
                                                    expands: true,
                                                    maxLines: null,
                                                    controller:
                                                        textBioController,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      label: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 100.0),
                                                        child: Text(
                                                          widget.label,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[800],
                                                              fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Divider(),
                                                Row(
                                                  children: [
                                                    TextButton(
                                                        onPressed: Navigator.of(
                                                                context)
                                                            .pop,
                                                        child: const Text(
                                                            "Annuler")),
                                                    TextButton(
                                                        onPressed: () async {
                                                          await usersFirestoreProvider
                                                              .updateUserField(
                                                                  'biography',
                                                                  textBioController
                                                                      .text);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            "Confirmer"))
                                                  ],
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                );
                              });
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
