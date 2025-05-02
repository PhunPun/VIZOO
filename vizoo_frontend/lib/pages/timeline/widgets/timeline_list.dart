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
  // Thêm callback khi trạng thái hoạt động thay đổi
  final VoidCallback? onActivityStatusChanged;

  const TimelineList({
    super.key,
    required this.numberDay,
    required this.timelineQuery,
    required this.locationId,
    required this.tripId,
    this.onActivityStatusChanged,
  });

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
      final schedSnap =
          await tDoc.reference.collection('schedule').orderBy('hour').get();

      for (var sDoc in schedSnap.docs) {
        final schedule = Schedule.fromSnapshots(tDoc, sDoc);
        final scheduleId = sDoc.id;

        final actSnap =
            await FirebaseFirestore.instance
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

  // Thêm phương thức cập nhật trạng thái hoàn thành của một hoạt động
  Future<void> toggleActivityStatus(
    String timelineId,
    String scheduleId,
    bool currentStatus,
  ) async {
    try {
      // Cập nhật trạng thái trong Firestore
      await FirebaseFirestore.instance
          .collection('dia_diem')
          .doc(widget.locationId)
          .collection('trips')
          .doc(widget.tripId)
          .collection('timelines')
          .doc(timelineId)
          .collection('schedule')
          .doc(scheduleId)
          .update({'status': !currentStatus});

      // Làm mới dữ liệu
      setState(() {
        _futureSchedules = fetchSchedules();
      });

      // Gọi callback nếu được cung cấp
      if (widget.onActivityStatusChanged != null) {
        widget.onActivityStatusChanged!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !currentStatus
                ? 'Đã đánh dấu hoàn thành hoạt động'
                : 'Đã đánh dấu chưa hoàn thành hoạt động',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái hoạt động: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  // Inside TimelineList class in timeline_list.dart
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 13,
                  ),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(MyColor.pr5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children:
                        items
                            .map(
                              (i) => TimelineCard(
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
                                      builder:
                                          (_) => EditTimelinePage(
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
                                  ).then((_) {
                                    // Khi quay về, refresh lại dữ liệu
                                    setState(() {
                                      _futureSchedules = fetchSchedules();
                                    });

                                    // Gọi callback nếu được cung cấp
                                    if (widget.onActivityStatusChanged !=
                                        null) {
                                      widget.onActivityStatusChanged!();
                                    }
                                  });
                                },
                                onToggleStatus: () {
                                  toggleActivityStatus(
                                    i['timelineId'],
                                    i['scheduleId'],
                                    i['completed'],
                                  );
                                },
                              ),
                            )
                            .toList(),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(33),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Day ${widget.numberDay}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(MyColor.pr5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Hiển thị % hoạt động đã hoàn thành
                        _buildCompletionStatus(items),
                      ],
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
  
  // Hiển thị trạng thái hoàn thành
  Widget _buildCompletionStatus(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    int total = items.length;
    int completed = items.where((item) => item['completed'] == true).length;
    double percentage = completed / total * 100;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: percentage == 100 ? Colors.green.shade100 : Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${percentage.toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: percentage == 100 ? Colors.green.shade800 : Colors.amber.shade800,
        ),
      ),
    );
  }
}