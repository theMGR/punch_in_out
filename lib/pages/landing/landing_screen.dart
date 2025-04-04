import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_in_out/helper/utils.dart';
import 'package:punch_in_out/pages/create_user/create_user_screen.dart';
import 'package:punch_in_out/pages/login/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Text('Punch In/Out', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
            SizedBox(height: 50),
            Utils.getButton(text: 'Register', onPressed: () => Get.to(CreateUserScreen())),
            Utils.getButton(text: 'Login', onPressed: () => Get.offAll(LoginScreen())),
          ],
        ),
      ),
    );
  }
}
