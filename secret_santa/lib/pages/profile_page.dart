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
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 150,
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
                  padding: const EdgeInsets.only(top: 105.0),
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
                          size: 60,
                        ),
                      ),
                      Positioned(
                        top: 70,
                        left: 62,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.blue[200],
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            size: 15,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
