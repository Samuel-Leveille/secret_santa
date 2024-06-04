import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 1,
            color: Colors.white,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFB2EBF2),
                    Color(0xFF80DEEA),
                    Color(0xFF4DD0E1),
                    Color(0xFF26C6DA),
                  ],
                  stops: [
                    0.3,
                    0.5,
                    0.7,
                    1.0
                  ]),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 375.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 20,
                              offset: Offset(1, 1)),
                        ]),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                    ),
                  ),
                  Positioned(
                    top: 66,
                    left: 58,
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: IconButton.filled(
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.teal[100])),
                          icon: const Icon(Icons.add_a_photo),
                          color: Colors.black,
                          disabledColor: Colors.black,
                          iconSize: 15,
                          onPressed: () => {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Photo de profil"),
                                        content: const Text("lolololol"),
                                        actions: [
                                          MaterialButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Annuler"),
                                          ),
                                          MaterialButton(
                                            onPressed: () {},
                                            child: const Text("Confirmer"),
                                          )
                                        ],
                                      );
                                    })
                              }),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
