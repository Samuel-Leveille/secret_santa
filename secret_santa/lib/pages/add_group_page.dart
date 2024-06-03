import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: const Center(
          child: Text("Créer un groupe"),
        ),
      ),
    );
  }
}
