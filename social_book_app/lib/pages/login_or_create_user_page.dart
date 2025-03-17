import 'package:flutter/material.dart';
import 'package:social_book_app/pages/account_creation_page.dart';
import 'package:social_book_app/pages/login_page.dart';

class LoginOrCreatePage extends StatefulWidget {
  const LoginOrCreatePage({super.key});

  @override
  State<LoginOrCreatePage> createState() => _LoginOrCreatePageState();
}

class _LoginOrCreatePageState extends State<LoginOrCreatePage> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return AccountCreationPage(
        onTap: togglePages,
      );
    }
  }
}
