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
        color: Colors.white,
        alignment: Alignment.center,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Accueil"),
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
    );
  }
}
