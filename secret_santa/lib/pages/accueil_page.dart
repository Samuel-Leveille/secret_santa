import 'dart:async';

import 'package:flutter/material.dart';
import 'package:secret_santa/firebase_auth/auth_services.dart';
import 'package:secret_santa/pages/login_page.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: const SafeArea(
          child: Center(
            child: Text("Accueil"),
          ),
        ),
      ),
    );
  }
}
