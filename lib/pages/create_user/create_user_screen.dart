import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_in_out/helper/database_helper.dart';

class CreateUserScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxInt userType = 2.obs;

  CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create User')),
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
            Obx(
                  () => DropdownButton<int>(
                value: userType.value,
                items: [
                  DropdownMenuItem(value: 1, child: Text('Admin')),
                  DropdownMenuItem(value: 2, child: Text('Staff')),
                ],
                onChanged: (value) {
                  if (value != null) userType.value = value;
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.instance.createUser(
                  usernameController.text,
                  passwordController.text,
                  userType.value,
                );
              },
              child: Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}