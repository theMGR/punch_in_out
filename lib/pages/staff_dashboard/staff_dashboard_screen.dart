import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:punch_in_out/dto/user_dto.dart';
import 'package:punch_in_out/helper/database_helper.dart';
import 'package:punch_in_out/helper/utils.dart';
import 'package:punch_in_out/pages/landing/landing_screen.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class StaffDashboardScreen extends StatefulWidget {
  final UserDto userDto;

  const StaffDashboardScreen({super.key, required this.userDto});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  RxString punchInTime = ''.obs;
  RxString punchOutTime = ''.obs;
  RxBool enableQrView = false.obs;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
    _loadLastPunch();
    Utils.getLocationPermission();
  }

  Future<void> _loadLastPunch() async {
    punchInTime.value = widget.userDto.punchIn ?? '';
    punchOutTime.value = widget.userDto.punchOut ?? '';
  }

  void _onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    controller?.resumeCamera();
    controller?.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.removeAllWhitespace.isNotEmpty) {
        enableQrView.value = false;
        qrController.pauseCamera();
        onUpdatePunch(scanData: scanData.code);
      }
    });
  }

  void onUpdatePunch({String? scanData}) async {
    final String time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    Position? position = await Utils.getLocation();
    if (punchInTime.isEmpty) {
      await DatabaseHelper.instance.updatePunchInOut(
        userId: widget.userDto.id!,
        punchInOutTime: time,
        latitude: position?.latitude,
        longitude: position?.longitude,
        punchType: 1,
        punchInOutScanData: scanData,
      );
      punchInTime.value = time;
    } else if (punchOutTime.isEmpty) {
      await DatabaseHelper.instance.updatePunchInOut(
        userId: widget.userDto.id!,
        punchInOutTime: time,
        latitude: position?.latitude,
        longitude: position?.longitude,
        punchType: 2,
        punchInOutScanData: scanData,
      );
      punchOutTime.value = time;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              //await DatabaseHelper.instance.deleteUser(widget.userDto.id);
              //await DatabaseHelper.instance.deleteDb();
              Get.offAll(LandingScreen());
            },
          )
        ],
      ),
      body: Obx(() => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Text(
                  'Hi ${widget.userDto.username} !',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
                if (punchInTime.value.isNotEmpty)
                  Text(
                    '${String.fromCharCode(128344)} Punch In: ${punchInTime.value}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                if (punchInTime.value.isNotEmpty)
                  Text(
                    '${String.fromCharCode(128353)} Punch Out: ${punchOutTime.value}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                //Text(_currentPosition != null ? 'Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}' : 'Location not acquired'),

                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    if (punchInTime.value.isEmpty || punchOutTime.value.isEmpty)
                      Utils.getButton(
                          text: punchInTime.value.isEmpty ? 'Punch In' : 'Punch Out',
                          onPressed: () {
                            onUpdatePunch();
                          }),
                    if (punchInTime.value.isEmpty || punchOutTime.value.isEmpty)
                      Utils.getButton(
                          text: 'Scan QR Code to Punch In/Out',
                          onPressed: () {
                            enableQrView.value = !enableQrView.value;
                          }),
                    if (enableQrView.value)
                      SizedBox(
                        width: Get.width,
                        height: Get.width,
                        child: QRView(
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                        ),
                      ),
                  ],
                )),
              ],
            ),
          )),
    );
  }
}
