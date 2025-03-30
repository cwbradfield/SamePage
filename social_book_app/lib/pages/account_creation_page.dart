import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/components/textfield.dart';
import 'package:social_book_app/pages/login_or_create_user_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountCreationPage extends StatefulWidget {
  final Function()? onTap;
  const AccountCreationPage({super.key, required this.onTap});

  @override
  State<AccountCreationPage> createState() => _AccountCreationPageState();
}

class _AccountCreationPageState extends State<AccountCreationPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void createAccount() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 186, 146, 109),
          ),
        );
      },
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        User? user = userCredential.user;

        if (user != null) {
          if (mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }

          await FirebaseFirestore.instance
              .collection("Users")
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'email': user.email,
          });
        }
      } else {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        showErrorMessage('Passwords do not match');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      showErrorMessage(e.code);

      if (e.code == 'invalid-credential') {
        showErrorMessage(e.code);
      }
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 66, 37, 10),
          title: Center(
            child: Text(
              message,
              style: TextStyle(
                color: Color.fromARGB(255, 186, 146, 109),
              ),
            ),
          ),
        );
      },
    );
  }

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
                        // fontFamily: '',
                        color: const Color.fromARGB(255, 66, 37, 10)),
                    "SamePage"),
                SizedBox(
                  height: 60,
                ),
                MyTextfield(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                SizedBox(height: 12),
                MyTextfield(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
                SizedBox(height: 12),
                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    createAccount();
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Colors.black87)),
                  child: Text('Create Account',
                      style: TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  height: 60,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginOrCreatePage()),
                        );
                      },
                      child: GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
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
