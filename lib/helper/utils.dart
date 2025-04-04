import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  Utils._();

  static Widget getButton({required String text, required Function() onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }

  static Future<Position?> getLocation() async {
    Position? position;

    try {
      position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
    } catch (e) {
      debugPrint('$e');
    }
    return position;
  }

  static void getLocationPermission() async {
    if (await Permission.location.isGranted == false || await Permission.locationWhenInUse.isGranted == false) {
      await Permission.location.request().then((value) async{
        if(value.isGranted == true) {
          await Permission.locationWhenInUse.request();
        }
      },);
    }
  }
}
