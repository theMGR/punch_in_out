import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:punch_in_out/dto/event_dto.dart';
import 'package:punch_in_out/helper/database_helper.dart';
import 'package:punch_in_out/helper/utils.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarController extends GetxController {
  var selectedDay = DateTime.now().obs;
  var selectedCompany = 'All'.obs;
  var searchQuery = ''.obs;
  var allEvents = <EventDto>[].obs;
  Rx<CalendarFormat> calendarFormat = CalendarFormat.month.obs;
  List<String> listCompany = ['All', 'Company A', 'Company B'];
  RxBool floatingButtonVisibility = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    allEvents.value = await DatabaseHelper.instance.getEvents();
  }

  List<EventDto> getEventsForDay(DateTime day) {
    return allEvents.where((e) => e.date?.year == day.year && e.date?.month == day.month && e.date?.day == day.day).toList();
  }

  List<EventDto> getFilteredEventsForDay(DateTime day) {
    final events = getEventsForDay(day);
    return events.where((e) {
      final matchesCompany = selectedCompany.value == 'All' || e.company == selectedCompany.value;
      final matchesSearch = searchQuery.value.isEmpty || e.title!.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesCompany && matchesSearch;
    }).toList();
  }

  Future<void> addEvent(EventDto event) async {
    await DatabaseHelper.instance.insertEvent(event);
    await loadEvents();
  }

  Future<void> updateEvent(EventDto event) async {
    await DatabaseHelper.instance.updateEvent(event);
    await loadEvents();
  }

  Future<void> deleteEvent(int id) async {
    await DatabaseHelper.instance.deleteEvent(id);
    await loadEvents();
  }

  Color getCompanyColor(String company) {
    switch (company) {
      case 'Company A':
        return Colors.blue;
      case 'Company B':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void showAddEditDialog(BuildContext context, {bool isEdit = false, EventDto? event}) {
    Rx<TextEditingController> titleCtrl = TextEditingController().obs;
    Rx<TextEditingController> notesCtrl = TextEditingController().obs;
    titleCtrl.value.text = event?.title ?? '';
    notesCtrl.value.text = event?.notes ?? '';

    final company = isEdit
        ? event!.company
        : selectedCompany.value != listCompany[0]
            ? selectedCompany.value
            : listCompany[1];
    String selected = company!;

    Get.defaultDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedCompany.value == listCompany[0] || isEdit)
              DropdownButtonFormField<String>(
                value: selected,
                onChanged: (val) => selected = val!,
                items: listCompany.where((s) => s != listCompany[0],).map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
              ),
            SizedBox(height: 12),
            TextField(controller: titleCtrl.value, decoration: InputDecoration(labelText: 'Title', hintStyle: TextStyle(color: Colors.grey)), onChanged: (value) {
              titleCtrl.refresh();
            },),
            SizedBox(height: 12),
            TextField(controller: notesCtrl.value, decoration: InputDecoration(labelText: 'Notes', hintStyle: TextStyle(color: Colors.grey))),
            Row(
              children: [
                TextButton(child: Text('Cancel'), onPressed: () => Get.back()),
                Obx(() => TextButton(
                    child: Text(
                      'Save',
                      style: TextStyle(color: titleCtrl.value.text.trim().isEmpty ? Colors.grey : null),
                    ),
                    onPressed: () {
                      if (titleCtrl.value.text.trim().isNotEmpty) {
                        final title = titleCtrl.value.text.trim();
                        final notes = notesCtrl.value.text.trim();
                        if (title.isEmpty) return;
                        if (isEdit && event != null) {
                          updateEvent(EventDto(id: event.id, title: title, notes: notes, date: event.date, company: selected));
                        } else {
                          addEvent(EventDto(title: title, notes: notes, date: selectedDay.value, company: selected));
                        }
                        Get.back();
                      }
                    }))
              ],
            )
          ],
        ),
      ),contentPadding: EdgeInsets.all(12)
    );
  }
}
