import 'package:flutter/material.dart';

class Mytextfiled extends StatelessWidget {
  final controller;
  final String hinttext;
  final bool obscuretext;
  const Mytextfiled({
    super.key,
    required this.controller,
    required this.hinttext,
    required this.obscuretext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller ,
        obscureText: obscuretext,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade400,
            ),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hinttext,
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }
}
