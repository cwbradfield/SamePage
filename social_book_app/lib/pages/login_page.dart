import 'package:flutter/material.dart';
import 'package:social_book_app/components/textfield.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 186, 146, 109),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Icon(
                Icons.person,
                size: 100,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                  style: TextStyle(fontSize: 24),
                  "Social Book App or something"),
              SizedBox(
                height: 50,
              ),
              MyTextfield(),
              SizedBox(height: 12),
              MyTextfield(),
            ],
          ),
        ),
      ),
    );
  }
}
