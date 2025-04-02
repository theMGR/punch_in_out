import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_in_out/helper/database_helper.dart';
import 'package:punch_in_out/pages/admin_dashboard/admin_dashboard_screen.dart';
import 'package:punch_in_out/pages/staff_dashboard/staff_dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
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
            ElevatedButton(
              onPressed: () async {
                int? userType = await DatabaseHelper.instance.authenticateUser(
                  usernameController.text,
                  passwordController.text,
                );
                if (userType != null) {
                  if (userType == 1) {
                    Get.off(AdminDashboardScreen());
                  } else {
                    Get.off(StaffDashboardScreen());
                  }
                } else {
                  Get.snackbar('Error', 'Invalid credentials', backgroundColor: Colors.red, colorText: Colors.white);
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}