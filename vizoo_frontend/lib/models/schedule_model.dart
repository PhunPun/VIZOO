import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final int dayNumber;
  final String actId;
  final String hour;
  final bool status;

  Schedule({
    required this.id,
    required this.dayNumber,
    required this.actId,
    required this.hour,
    required this.status,
  });

  // Convert from Firestore document snapshots to Schedule object
  factory Schedule.fromSnapshots(
      DocumentSnapshot timelineSnap,
      DocumentSnapshot schedSnap) {
    final tData = timelineSnap.data() as Map<String, dynamic>;
    final sData = schedSnap.data() as Map<String, dynamic>;
    return Schedule(
      id: schedSnap.id,
      dayNumber: tData['day_number']?.toInt() ?? 0, // Ensure dayNumber is fetched correctly
      actId: sData['act_id'] ?? '',
      hour: sData['hour'] ?? '',
      status: sData['status'] ?? false,
    );
  }

  // Convert from Map to Schedule object
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] ?? '',
      hour: map['hour'] ?? '',
      actId: map['act_id'] ?? '',
      status: map['status'] ?? false,
      dayNumber: map['day_number']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': hour,
      'act_id': actId,
      'status': status,
      'day_number': dayNumber,
    };
  }
}
