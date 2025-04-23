import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_card.dart';
import '../../../models/schedule_model.dart';
import '../../../themes/colors/colors.dart';
import '../../edit_timeline/edit_timeline_page.dart';

class TimelineList extends StatefulWidget {
  final int numberDay;
  final Query<Map<String, dynamic>> timelineQuery;
  final String locationId;
  final String tripId;

  const TimelineList({
    Key? key,
    required this.numberDay,
    required this.timelineQuery,
    required this.locationId,
    required this.tripId,
  }) : super(key: key);

  @override
  State<TimelineList> createState() => _TimelineListState();
}

class _TimelineListState extends State<TimelineList> {
  late Future<List<Map<String, dynamic>>> _futureSchedules;

  @override
  void initState() {
    super.initState();
    _futureSchedules = fetchSchedules();
  }

  Future<List<Map<String, dynamic>>> fetchSchedules() async {
    final tDocs = await widget.timelineQuery.get();
    List<Map<String, dynamic>> result = [];

    for (var tDoc in tDocs.docs) {
      final timelineId = tDoc.id;
      final schedSnap = await tDoc.reference
          .collection('schedule')
          .orderBy('hour')
          .get();

      for (var sDoc in schedSnap.docs) {
        final schedule  = Schedule.fromSnapshots(tDoc, sDoc);
        final scheduleId = sDoc.id;

        final actSnap = await FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(widget.locationId)
            .collection('activities')
            .doc(schedule.actId)
            .get();
        final act = actSnap.data() ?? {};

        result.add({
          'time': TimeOfDay(
            hour: int.parse(schedule.hour.split(':')[0]),
            minute: int.parse(schedule.hour.split(':')[1]),
          ),
          'activities': act['name'] ?? '',
          'address': act['address'] ?? '',
          'price': act['price'] ?? 0,
          'completed': schedule.status,
          'categories': act['categories'] ?? '',
          'timelineId': timelineId,
          'scheduleId': scheduleId,
        });
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureSchedules,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Không có lịch trình cho ngày ${widget.numberDay}'),
          );
        }
        return Column(
          children: [
            // Tiêu đề Day
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(MyColor.pr5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: items.map((i) => TimelineCard(
                      time: i['time'],
                      activities: i['activities'],
                      address: i['address'],
                      price: i['price'],
                      completed: i['completed'],
                      categories: i['categories'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTimelinePage(
                              time: i['time'],
                              activities: i['activities'],
                              address: i['address'],
                              price: i['price'],
                              completed: i['completed'],
                              categories: i['categories'],
                              diaDiemId: widget.locationId,
                              tripId: widget.tripId,
                              timelineId: i['timelineId'],
                              scheduleId: i['scheduleId'],
                            ),
                          ),
                        )
                            .then((_) {
                          // Khi quay về, refresh lại dữ liệu
                          setState(() {
                            _futureSchedules = fetchSchedules();
                          });
                        });
                      },
                    )).toList(),
                  ),
                ),
                Positioned(
                  top: 0, left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(33),
                      boxShadow: [BoxShadow(color: Colors.white, blurRadius:12, spreadRadius:1)],
                    ),
                    child: Text(
                      'Day ${widget.numberDay}',
                      style: TextStyle(fontSize: 20, color: Color(MyColor.pr5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
