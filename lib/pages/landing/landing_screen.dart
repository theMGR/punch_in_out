import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_in_out/pages/create_user/create_user_screen.dart';
import 'package:punch_in_out/pages/login/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Punch In/Out')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(CreateUserScreen());
              },
              child: Text('Create User'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(LoginScreen());
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}