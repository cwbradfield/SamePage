import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  const MyTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black87),
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black87)),
            fillColor: Colors.grey[200],
            filled: true),
      ),
    );
  }
}
