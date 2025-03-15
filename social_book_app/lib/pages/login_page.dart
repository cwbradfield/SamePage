import 'package:flutter/material.dart';
import 'package:social_book_app/components/login_textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 186, 146, 109),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Icon(
                  Icons.menu_book_rounded,
                  size: 150,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                    style: TextStyle(fontSize: 26),
                    "Social Book App or something"),
                SizedBox(
                  height: 80,
                ),
                MyTextfield(
                  controller: usernameController,
                  hintText: "Username",
                  obscureText: false,
                ),
                SizedBox(height: 12),
                MyTextfield(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Forgot Password?'),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Sign In', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(
                  height: 100,
                ),
                Text('Don\'t have an account?'),
                ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Create Account',
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
