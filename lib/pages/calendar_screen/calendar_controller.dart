import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:punch_in_out/dto/event_dto.dart';
import 'package:punch_in_out/helper/database_helper.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarController extends GetxController {
  var selectedDay = DateTime.now().obs;
  var selectedCompany = 'All'.obs;
  var searchQuery = ''.obs;
  var allEvents = <EventDto>[].obs;
  Rx<CalendarFormat> calendarFormat = CalendarFormat.month.obs;

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
    final titleCtrl = TextEditingController(text: event?.title ?? '');
    final notesCtrl = TextEditingController(text: event?.notes ?? '');
    final company = isEdit
        ? event!.company
        : selectedCompany.value != 'All'
            ? selectedCompany.value
            : 'Company A';
    String selected = company!;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Event' : 'Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Title')),
              if (selectedCompany.value == 'All' || isEdit)
                DropdownButtonFormField<String>(
                  value: selected,
                  onChanged: (val) => selected = val!,
                  items: ['Company A', 'Company B'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                ),
              TextField(controller: notesCtrl, decoration: InputDecoration(labelText: 'Notes')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final notes = notesCtrl.text.trim();
                if (title.isEmpty) return;
                if (isEdit && event != null) {
                  updateEvent(EventDto(id: event.id, title: title, notes: notes, date: event.date, company: selected));
                } else {
                  addEvent(EventDto(title: title, date: selectedDay.value, company: selected));
                }
                Get.back();
              },
              child: Text('Save'),
            )
          ],
        );
      },
    );
  }
}
