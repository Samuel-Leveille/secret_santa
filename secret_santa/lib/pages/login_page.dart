import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _isVisible;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    _isVisible = false;
    super.initState();
  }

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
        height: double.infinity,
        width: double.infinity,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
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
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          fillColor: const Color(0xFF80DEEA),
                          filled: true,
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          label: Text(
                            "Courriel",
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _isVisible,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          label: Text(
                            "Mot de passe",
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          suffixIcon: IconButton(
                            icon: _isVisible == true
                                ? const Icon(Icons.visibility)
                                : const Icon(Icons.visibility_off),
                            onPressed: () => setState(() {
                              _isVisible = !_isVisible;
                            }),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Mot de passe oublié ?"),
                          ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
