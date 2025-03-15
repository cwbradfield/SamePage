import 'package:flutter/material.dart';
import 'package:social_book_app/components/login_textfield.dart';
import 'package:social_book_app/pages/create_account_page.dart';

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
                  height: 30,
                ),
                Icon(
                  Icons.menu_book_rounded,
                  size: 200,
                  color: const Color.fromARGB(255, 66, 37, 10),
                ),
                // SizedBox(
                //   height: 10,
                // ),
                Text(
                    style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        // Change font at some point
                        fontFamily: '',
                        color: const Color.fromARGB(255, 66, 37, 10)),
                    "SamePage"),
                SizedBox(
                  height: 60,
                ),
                MyTextfield(
                  controller: usernameController,
                  hintText: "Email",
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
                Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Colors.black87)),
                  child: Text('Sign In', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  height: 100,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateAccountPage()),
                        );
                      },
                      child: Text(
                        'Create Account',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
