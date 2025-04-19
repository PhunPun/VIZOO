import 'package:vizoo_frontend/models/schedule_model.dart';

class Timeline {
  final String id;
  final int dayNumber;
  final List<Schedule> schedules;

  Timeline({
    required this.id,
    required this.dayNumber,
    required this.schedules,
  });

  // Chuyển từ Map (Firestore) thành đối tượng Timeline
  factory Timeline.fromMap(Map<String, dynamic> map, String id) {
    var scheduleList = map['schedule'] as List? ?? []; // Ensure that schedule is a list
    List<Schedule> schedules = scheduleList
        .map((scheduleMap) => Schedule.fromMap(scheduleMap))
        .toList();

    return Timeline(
      id: id,
      dayNumber: map['day_number'] ?? '',
      schedules: schedules,
    );
  }

  // Chuyển đối tượng Timeline thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'day_number': dayNumber,
      'schedule': schedules.map((schedule) => schedule.toMap()).toList(),
    };
  }
}
