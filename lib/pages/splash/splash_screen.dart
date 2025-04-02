import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_in_out/constants/asset_constant.dart';
import 'package:punch_in_out/pages/landing/landing_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Get.off(LandingScreen());
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(AssetConstant.dreamCorpGc),
      ),
    );
  }
}
