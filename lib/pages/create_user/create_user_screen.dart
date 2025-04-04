import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_in_out/constants/value_constant.dart';
import 'package:punch_in_out/dto/user_dto.dart';
import 'package:punch_in_out/helper/database_helper.dart';
import 'package:punch_in_out/helper/utils.dart';
import 'package:punch_in_out/pages/login/login_screen.dart';

class CreateUserScreen extends StatelessWidget {
  final Rx<TextEditingController> usernameController = TextEditingController().obs;
  final Rx<TextEditingController> passwordController = TextEditingController().obs;
  final RxString userType = (ValueConstant.admin).obs;

  CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Obx(() => Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                TextField(
                  controller: usernameController.value,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController.value,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                DropdownButtonFormField<String>(
                  value: userType.value,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: ValueConstant.admin, child: Text('Admin')),
                    DropdownMenuItem(value: ValueConstant.staff, child: Text('Staff')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      userType.value = value;
                    }
                  },
                ),
                SizedBox(height: 20),
                Utils.getButton(
                    text: 'Register',
                    onPressed: () async {
                      if (usernameController.value.text.replaceAll(' ', '').length < 8 || passwordController.value.text.replaceAll(' ', '').length < 8) {
                        Get.snackbar('Error', 'User Name / Password must be 8 characters and cannot be empty', backgroundColor: Colors.red, colorText: Colors.white);
                      } else if (await DatabaseHelper.instance.checkUserExists(usernameController.value.text) == false) {
                        await DatabaseHelper.instance.createUser(UserDto(username: usernameController.value.text.replaceAll(' ', ''), password: passwordController.value.text.replaceAll(' ', ''), userType: userType.value)).then((value) {
                          if (value != 0) {
                            //Get.snackbar('Success', 'User registered successfully', backgroundColor: Colors.green, colorText: Colors.white);
                            Get.dialog(
                              AlertDialog(
                                title: Text('Alert'),
                                content: Text('User registered successfully'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      usernameController.value.text = '';
                                      passwordController.value.text = '';
                                      userType.value = ValueConstant.admin;
                                      Get.back();
                                    },
                                    child: Text('Register More User'),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.offAll(LoginScreen()),
                                    child: Text('Login'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Get.snackbar('Error', 'Something went wrong', backgroundColor: Colors.red, colorText: Colors.white);
                          }
                        });
                      } else {
                        Get.snackbar('Error', 'User already exists', backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    })
              ],
            ),
          )),
    );
  }
}
