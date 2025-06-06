import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_in_out/pages/landing/landing_screen.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendar_controller.dart';

class CalendarScreen extends StatelessWidget {
  final controller = Get.put(CalendarController());

  CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Compalendar'),
        actions: [
          Obx(() => DropdownButton<String>(
                value: controller.selectedCompany.value,
                underline: SizedBox(),
                alignment: Alignment.centerRight,
                icon: Row(
                  children: [
                    SizedBox(width: 12),
                    const Icon(Icons.filter_list),
                  ],
                ),
                items: controller.listCompany.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedCompany.value = val;
                  }
                },
              )),
          IconButton(
            icon: Icon(Icons.arrow_back_sharp),
            onPressed: () async {
              Get.offAll(LandingScreen());
            },
          )
        ],
      ),
      body: ListView(
        //spacing: 12,
        children: [
          Obx(() => TableCalendar(
                calendarFormat: controller.calendarFormat.value,
                focusedDay: controller.selectedDay.value,
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                selectedDayPredicate: (day) => isSameDay(day, controller.selectedDay.value),
                onDaySelected: (selected, focused) {
                  controller.selectedDay.value = selected;
                },
                eventLoader: (day) => controller.getFilteredEventsForDay(day),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Get.theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                onFormatChanged: (format) {
                  controller.calendarFormat.value = format;
                },
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
              ),
              onChanged: (value) => controller.searchQuery.value = value,
            ),
          ),
          Obx(() {
            final events = controller.getFilteredEventsForDay(controller.selectedDay.value);
            if (events.isEmpty) {
              return Center(child: Text('No events for selected day'));
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: events.length,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(8),
              itemBuilder: (_, i) {
                final e = events[i];
                final color = controller.getCompanyColor(e.company!);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color, width: 1),
                  ),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Title: ${e.title!}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        if (e.notes != null && e.notes!.isNotEmpty)
                          Text(
                            'Notes: ${e.notes!}',
                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54, fontSize: 12),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      '${e.company} - ${e.date?.toLocal().toString().split(" ")[0]}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black54),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue.shade400),
                          onPressed: () => controller.showAddEditDialog(context, isEdit: true, event: e),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red.shade400),
                          onPressed: () => controller.deleteEvent(e.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Event"),
        onPressed: () => controller.showAddEditDialog(context),
      ),
    );
  }
}
