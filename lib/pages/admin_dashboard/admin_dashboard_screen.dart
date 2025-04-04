import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:punch_in_out/dto/user_dto.dart';
import 'package:punch_in_out/helper/database_helper.dart';
import 'package:punch_in_out/pages/landing/landing_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserDto userDto;

  const AdminDashboardScreen({super.key, required this.userDto});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  RxList<UserDto> staffRecords = <UserDto>[].obs;
  RxString selectedDate = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadStaffRecords();
  }

  Future<void> _loadStaffRecords([String? date]) async {
    staffRecords.clear();
    await DatabaseHelper.instance.getStaffRecords(date).then((value) => staffRecords.addAll(value));
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate.value = DateFormat('yyyy-MM-dd').format(picked);
      _loadStaffRecords(selectedDate.value);
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(onPressed: () => _selectDate(context), icon: Icon(Icons.calendar_month)),
                    IconButton(
                        onPressed: () {
                          selectedDate.value = '';
                          _loadStaffRecords();
                        },
                        icon: Icon(Icons.refresh))
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: staffRecords.length,
                    itemBuilder: (context, index) {
                      final record = staffRecords[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ListTile(
                          tileColor: Colors.grey.shade200,
                          title: Text('#${record.id} ${record.username}'),
                          subtitle: Text(
                            '${String.fromCharCode(128344)} Punch In: ${record.punchIn} ${record.punchInLat != null ? '\n${String.fromCharCode(128205)} ${record.punchInLat}, ${record.punchInLon}' : ''}'
                            '\n'
                            '${String.fromCharCode(128353)} Punch Out: ${record.punchOut ?? '-'}  ${record.punchOutLat != null ? '\n${String.fromCharCode(128205)} ${record.punchOutLat}, ${record.punchOutLon}' : ''}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
