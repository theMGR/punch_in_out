import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:punch_in_out/helper/database_helper.dart';
import 'package:punch_in_out/pages/login/login_screen.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  String? punchInTime;
  String? punchOutTime;
  Position? _currentPosition;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
    _loadLastPunch();
  }

  Future<void> _loadLastPunch() async {
    final lastPunch = await DatabaseHelper.instance.getLastPunch();
    setState(() {
      punchInTime = lastPunch['punchIn'];
      punchOutTime = lastPunch['punchOut'];
    });
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
    setState(() {
      _currentPosition = position;
    });
  }

  void _scanQRCode() async {
    await _getCurrentLocation();
    controller?.resumeCamera();
  }

  void _onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    controller?.scannedDataStream.listen((scanData) async {
      final String time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      if (punchInTime == null) {
        await DatabaseHelper.instance.punchIn(time);
        setState(() {
          punchInTime = time;
        });
      } else if (punchOutTime == null) {
        await DatabaseHelper.instance.punchOut(time);
        setState(() {
          punchOutTime = time;
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
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
            onPressed: () => Get.offAll(LoginScreen()),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Punch In: ${punchInTime ?? "Not Punched In"}'),
          Text('Punch Out: ${punchOutTime ?? "Not Punched Out"}'),
          Text(_currentPosition != null
              ? 'Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'
              : 'Location not acquired'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _scanQRCode,
            child: Text('Scan QR Code to Punch In/Out'),
          ),
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }
}
