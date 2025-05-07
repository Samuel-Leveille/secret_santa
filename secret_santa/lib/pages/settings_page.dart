import 'package:flutter/material.dart';
import 'package:secret_santa/services/users_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UsersService usersService = UsersService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
      ),
      body: Center(
        child: FloatingActionButton(
            onPressed: () async {
              await usersService.signOut(context);
            },
            child: const Text("Logout")),
      ),
    );
  }
}
