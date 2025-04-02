import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:punch_in_out/helper/database_helper.dart';
import 'package:punch_in_out/pages/login/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> _staffRecords = [];
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadStaffRecords();
  }

  Future<void> _loadStaffRecords([String? date]) async {
    final records = await DatabaseHelper.instance.getStaffRecords(date);
    setState(() {
      _staffRecords = records;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      _loadStaffRecords(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Get.offAll(LoginScreen()),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedDate ?? 'Select Date'),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Pick Date'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _staffRecords.length,
              itemBuilder: (context, index) {
                final record = _staffRecords[index];
                return ListTile(
                  title: Text('User ID: ${record['userId']}'),
                  subtitle: Text(
                    'Punch In: ${record['punchIn']}\nPunch Out: ${record['punchOut'] ?? 'Still Punched In'}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}