import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secret_santa/components/auth_password_textfield.dart';
import 'package:secret_santa/components/auth_textfield.dart';
import 'package:secret_santa/firebase_auth/auth_services.dart';
import 'package:secret_santa/pages/accueil_page.dart';
import 'package:secret_santa/pages/login_page.dart';
import 'package:secret_santa/pages/transition_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthServices _auth = AuthServices();

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final firstNameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    firstNameController.dispose();
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
                    const SizedBox(height: 75),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text("Inscription",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800])),
                          const SizedBox(height: 50),

                          // Firstname TextField
                          AuthTextfield(
                              controller: firstNameController,
                              icon: const Icon(Icons.person),
                              label: "Prénom"),
                          const SizedBox(height: 25),

                          // Name TextField
                          AuthTextfield(
                              controller: nameController,
                              icon: const Icon(Icons.person),
                              label: "Nom"),
                          const SizedBox(height: 25),

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
                          const SizedBox(height: 25),

                          // Confirm Password TextField
                          AuthPasswordTextfield(
                              controller: confirmPasswordController,
                              label: "Confirmer le mot de passe"),
                          const SizedBox(
                            height: 40.0,
                          ),
                          FloatingActionButton.extended(
                            extendedPadding:
                                const EdgeInsets.symmetric(horizontal: 111.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            backgroundColor: const Color(0xFFB2EBF2),
                            onPressed: _signUp,
                            label: Text(
                              "S'inscrire",
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
                                const Text("Déjà inscrit ? "),
                                GestureDetector(
                                  onTap: () => {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    ),
                                  },
                                  child: const Text(
                                    "Se connecter",
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

  void _signUp() async {
    String name = nameController.text;
    String firstName = firstNameController.text;
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        firstName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Remplissez tous les champs du formulaire d'inscription")),
      );
      return;
    }
    // Vérification du format de l'e-mail
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern as String);
    if (!regex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrez une adresse courriel valide")),
      );
      return;
    }

    // Vérification de la complexité du mot de passe
    Pattern passwordPattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp passwordRegex = new RegExp(passwordPattern as String);
    if (!passwordRegex.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Le mot de passe doit comporter au moins 8 caractères, dont une lettre majuscule, une lettre minuscule, un chiffre et un caractère spécial")),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }
    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      CollectionReference collRef =
          FirebaseFirestore.instance.collection('users');
      collRef.add({
        'firstName': firstName,
        'name': name,
        'email': email,
        'role': 'utilisateur',
        'profileImageUrl': '',
        'dateInscription': DateTime.now().toString()
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TransitionPage(),
        ),
      );
      emailController.text = "";
      passwordController.text = "";
      confirmPasswordController.text = "";
      nameController.text = "";
      firstNameController.text = "";
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur : la création de compte a échouée")),
      );
    }
  }
}
