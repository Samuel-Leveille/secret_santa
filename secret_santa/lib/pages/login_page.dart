import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secret_santa/components/auth_password_textfield.dart';
import 'package:secret_santa/components/auth_textfield.dart';
import 'package:secret_santa/firebase_auth/auth_services.dart';
import 'package:secret_santa/pages/accueil_page.dart';
import 'package:secret_santa/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthServices _auth = AuthServices();

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFB2EBF2),
                Color(0xFF80DEEA),
                Color(0xFF4DD0E1),
                Color(0xFF26C6DA),
              ],
              stops: [
                0.1,
                0.4,
                0.7,
                0.9
              ]),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 150),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text("Connexion",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800])),
                          const SizedBox(height: 50),

                          // Email TextField
                          AuthTextfield(
                              controller: emailController,
                              icon: const Icon(Icons.email),
                              label: "Courriel"),
                          const SizedBox(height: 25),

                          // Password TextField
                          AuthPasswordTextfield(
                              controller: passwordController,
                              label: "Mot de passe"),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  child: const Text(
                                    "Mot de passe oublié ?",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () => {},
                                ),
                              ]),
                          const SizedBox(
                            height: 40.0,
                          ),
                          FloatingActionButton.extended(
                            extendedPadding:
                                const EdgeInsets.symmetric(horizontal: 95.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            backgroundColor: const Color(0xFFB2EBF2),
                            onPressed: _signIn,
                            label: Text(
                              "Se connecter",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Row(
                              children: [
                                const Text("Pas encore inscrit ? "),
                                GestureDetector(
                                  onTap: () => {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupPage(),
                                      ),
                                    ),
                                  },
                                  child: const Text(
                                    "S'inscrire",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  void _signIn() async {
    String email = emailController.text;
    String password = passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AccueilPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur : la connexion a échouée")),
      );
    }
  }
}
