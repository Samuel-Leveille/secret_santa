import 'package:flutter/material.dart';
import 'package:secret_santa/firebase_auth/auth_services.dart';
import 'package:secret_santa/pages/login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthServices auth = AuthServices();

    Future<void> signOut(BuildContext context) async {
      try {
        await auth.signOut();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        print("Some error occured with sign out : ${e.toString()}");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
      ),
      body: Center(
        child: FloatingActionButton(
            onPressed: () async {
              await signOut(context);
            },
            child: const Text("Logout")),
      ),
    );
  }
}
