import 'package:flutter/material.dart';

class GiftsPage extends StatefulWidget {
  const GiftsPage({super.key});

  @override
  State<GiftsPage> createState() => _GiftsPageState();
}

class _GiftsPageState extends State<GiftsPage> {
  List<Widget> _linkFields = [];

  void _addLinkField() {
    _linkFields.add(Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Lien',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Cadeaux',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          leading: const BackButton(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "Liste des cadeaux",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25.0)),
                ),
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: GestureDetector(
                          onTap: () =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          child: Container(
                            height: 600,
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(16.0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(0.0, 10.0),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 8,
                                  width: 75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                const Text(
                                  "Ajouter un cadeau",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Expanded(
                                  child: ListView(
                                    padding: const EdgeInsets.all(16.0),
                                    children: [
                                      TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Titre',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        decoration: InputDecoration(
                                          labelText: 'À propos',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        maxLines: 3,
                                      ),
                                      const SizedBox(height: 10),
                                      ..._linkFields,
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _addLinkField();
                                          });
                                        },
                                        icon: const Icon(Icons.add),
                                        label: const Text('Ajouter un lien'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.blue.shade800,
                                          backgroundColor: Colors.blue.shade100,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // Logique pour ajouter une image
                                        },
                                        icon: const Icon(Icons.image),
                                        label: const Text('Ajouter une image'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.blue.shade800,
                                          backgroundColor: Colors.blue.shade100,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // Logique pour sauvegarder les données
                                        },
                                        icon: const Icon(Icons.save),
                                        label: const Text('Sauvegarder'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor:
                                              Colors.green.shade800,
                                          backgroundColor:
                                              Colors.green.shade100,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            backgroundColor: Colors.blue.shade100,
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
