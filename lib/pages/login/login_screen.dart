import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_in_out/constants/value_constant.dart';
import 'package:punch_in_out/helper/database_helper.dart';
import 'package:punch_in_out/helper/utils.dart';
import 'package:punch_in_out/pages/admin_dashboard/admin_dashboard_screen.dart';
import 'package:punch_in_out/pages/landing/landing_screen.dart';
import 'package:punch_in_out/pages/staff_dashboard/staff_dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_sharp),
            onPressed: () async {
              Get.offAll(LandingScreen());
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Utils.getButton(
                text: 'Login',
                onPressed: () async {
                  await DatabaseHelper.instance.authenticateUser(usernameController.text.removeAllWhitespace, passwordController.text.removeAllWhitespace).then((user) {
                    if (user?.userType == ValueConstant.admin) {
                      Get.offAll(AdminDashboardScreen(
                        userDto: user!,
                      ));
                    } else if (user?.userType == ValueConstant.staff) {
                      Get.offAll(StaffDashboardScreen(userDto: user!));
                    } else {
                      Get.snackbar('Error', 'Invalid credentials', backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  });
                })
          ],
        ),
      ),
    );
  }
}
