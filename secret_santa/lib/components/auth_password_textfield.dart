import 'package:flutter/material.dart';

class AuthPasswordTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  const AuthPasswordTextfield({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  State<AuthPasswordTextfield> createState() => _AuthPasswordTextfieldState();
}

class _AuthPasswordTextfieldState extends State<AuthPasswordTextfield> {
  bool _isVisible = true;

  @override
  void initState() {
    _isVisible = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _isVisible,
        decoration: InputDecoration(
          fillColor: const Color(0xFF80DEEA),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          prefixIcon: const Icon(Icons.lock),
          label: Text(
            widget.label,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
          suffixIcon: IconButton(
            icon: _isVisible == true
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onPressed: () => setState(() {
              _isVisible = !_isVisible;
            }),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
    );
  }
}
