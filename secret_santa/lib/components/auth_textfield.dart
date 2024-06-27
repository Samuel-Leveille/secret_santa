import 'package:flutter/material.dart';

class AuthTextfield extends StatelessWidget {
  final TextEditingController controller;
  final Icon icon;
  final String label;
  const AuthTextfield({
    super.key,
    required this.controller,
    required this.icon,
    required this.label,
  });

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
        controller: controller,
        decoration: InputDecoration(
          fillColor: const Color(0xFF80DEEA),
          filled: true,
          prefixIcon: icon,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          label: Text(
            label,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
    );
  }
}
