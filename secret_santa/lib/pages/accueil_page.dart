import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secret_santa/firebase_auth/auth_services.dart';
import 'package:secret_santa/pages/login_page.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final AuthServices _auth = AuthServices();
  int _currentIndex = 0;

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      print("Some error occured with sign out : ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Bienvenue sur la page d'accueil"),
                const SizedBox(
                  height: 20,
                ),
                FloatingActionButton(
                    onPressed: () async {
                      await signOut(context);
                    },
                    child: const Text("Logout")),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: "Accueil",
            backgroundColor: Colors.blue[300],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: "Profil",
            backgroundColor: Colors.blue[300],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: "Amis",
            backgroundColor: Colors.blue[300],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: "Clavardage",
            backgroundColor: Colors.blue[300],
          )
        ],
      ),
    );
  }
}
