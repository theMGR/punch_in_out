class EventDto{
  int? id;
  String? title;
  DateTime? date;
  String? company;
  String? notes;

  EventDto({
    this.id,
    this.title,
    this.date,
    this.company,
    this.notes,
  });

  EventDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    date = DateTime.tryParse(json['date']);
    company = json['company'];
    notes = json['notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['date'] = date?.toIso8601String();
    data['company'] = company;
    data['notes'] = notes;
    return data;
  }
}
