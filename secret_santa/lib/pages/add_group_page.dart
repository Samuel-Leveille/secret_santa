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
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          color: Colors.white,
          child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 60.0, top: 100),
                    child: Text(
                      "Créer un groupe",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Card(
                      elevation: 15,
                      color: Colors.blue[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextFormField(
                            controller: nameController,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            controller: descriptionController,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {},
                    backgroundColor: Colors.teal[100],
                    extendedPadding:
                        const EdgeInsets.only(left: 120, right: 120),
                    label: const Text("Créer"),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
