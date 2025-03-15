import 'package:flutter/material.dart';

class CreateAccountPage extends
StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Center(
        child: Text("This is the Create Account page"),
      ),
    );
  }
}