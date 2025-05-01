import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/models/schedule_model.dart';
import 'package:vizoo_frontend/pages/admin/admin_edit_timeline/admin_edit_timeline_page.dart';
import 'package:vizoo_frontend/pages/admin/admin_timeline/widgets/admin_timeline_card.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class AdminTimelineList extends StatefulWidget {
  final int numberDay;
  final Query<Map<String, dynamic>> timelineQuery;
  final String locationId;
  final String tripId;
  final VoidCallback onRefreshTripData;

  // ✅ Các callback để cập nhật UI ngay sau khi chỉnh sửa
  final void Function(int)? onSetPrice;
  final void Function(String)? onSetStay;
  final void Function(int)? onSetActivityCount;
  final void Function(int)? onSetMealCount;

  const AdminTimelineList({
    Key? key,
    required this.numberDay,
    required this.timelineQuery,
    required this.locationId,
    required this.tripId,
    required this.onRefreshTripData,
    this.onSetPrice,
    this.onSetStay,
    this.onSetActivityCount,
    this.onSetMealCount,
  }) : super(key: key);

  @override
  State<AdminTimelineList> createState() => _AdminTimelineListState();
}

class _AdminTimelineListState extends State<AdminTimelineList> {
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

        if (schedule.actId.trim().isEmpty) {
          debugPrint('Bỏ qua schedule $scheduleId vì actId rỗng');
          continue;
        }

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
          'act_id': schedule.actId,
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

        return Column(
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(MyColor.pr5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Chưa có lịch trình', style: TextStyle(color: Colors.grey)),
                        )
                      : Column(
                          children: items.map((i) {
                            return AdminTimelineCard(
                              time: i['time'],
                              activities: i['activities'],
                              address: i['address'],
                              price: i['price'],
                              completed: i['completed'],
                              categories: i['categories'],
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminEditTimelinePage(
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
                                      actId: i['act_id'],
                                      onRefreshTripData: widget.onRefreshTripData,
                                    ),
                                  ),
                                );

                                // ✅ Gọi callback nếu có dữ liệu trả về
                                if (result != null && result is Map) {
                                  if (result['chiPhi'] != null && widget.onSetPrice != null) {
                                    widget.onSetPrice!(result['chiPhi']);
                                  }
                                  if (result['noiO'] != null && widget.onSetStay != null) {
                                    widget.onSetStay!(result['noiO']);
                                  }
                                  if (result['soAct'] != null && widget.onSetActivityCount != null) {
                                    widget.onSetActivityCount!(result['soAct']);
                                  }
                                  if (result['soEat'] != null && widget.onSetMealCount != null) {
                                    widget.onSetMealCount!(result['soEat']);
                                  }

                                  widget.onRefreshTripData(); // luôn sync lại trip từ Firestore
                                }

                                if (mounted) {
                                  setState(() {
                                    _futureSchedules = fetchSchedules();
                                  });
                                }

                              },
                            );
                          }).toList(),
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
                      boxShadow: const [
                        BoxShadow(color: Colors.white, blurRadius: 12, spreadRadius: 1),
                      ],
                    ),
                    child: Text(
                      'Day ${widget.numberDay}',
                      style: TextStyle(fontSize: 20, color: Color(MyColor.pr5)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: InkWell(
                      onTap: () async {
                        final timelineDocs = await widget.timelineQuery.get();

                        if (timelineDocs.docs.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Không tìm thấy timeline cho ngày này')),
                          );
                          return;
                        }

                        final timelineDoc = timelineDocs.docs.firstWhere(
                          (doc) => doc.data()['day_number'] == widget.numberDay,
                          orElse: () => throw Exception('Không tìm thấy ngày tương ứng'),
                        );

                        final scheduleRef = timelineDoc.reference.collection('schedule').doc();
                        await scheduleRef.set({
                          'hour': '09:00',
                          'act_id': '',
                          'status': false,
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminEditTimelinePage(
                              time: const TimeOfDay(hour: 9, minute: 0),
                              activities: '',
                              address: '',
                              price: 0,
                              completed: false,
                              categories: '',
                              diaDiemId: widget.locationId,
                              tripId: widget.tripId,
                              timelineId: timelineDoc.id,
                              scheduleId: scheduleRef.id,
                              actId: '',
                              onRefreshTripData: widget.onRefreshTripData,
                            ),
                          ),
                        ).then((_) {
                          widget.onRefreshTripData();
                          setState(() {
                            _futureSchedules = fetchSchedules();
                          });
                        });
                      },
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Color(MyColor.pr4), width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.white, blurRadius: 12, spreadRadius: 1),
                          ],
                        ),
                        child: const Text(
                          "+",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(MyColor.pr5),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
