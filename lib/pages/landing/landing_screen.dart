import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_in_out/helper/utils.dart';
import 'package:punch_in_out/pages/calendar_screen/calendar_screen.dart';

import 'landing_screen_punch_in_out.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Utils.getButton(text: 'Punch In/Out', onPressed: () => Get.offAll(LandingScreenPunchInOut())),
            Utils.getButton(text: 'Calendar Task', onPressed: () => Get.offAll(CalendarScreen())),
          ],
        ),
      ),
    );
  }
}
