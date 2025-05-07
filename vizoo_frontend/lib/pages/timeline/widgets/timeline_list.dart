import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_card.dart';
import '../../../models/schedule_model.dart';
import '../../../themes/colors/colors.dart';
import '../../../widgets/AddSchedulePage.dart';
import '../../edit_timeline/edit_timeline_page.dart';

class TimelineList extends StatefulWidget {
  final int numberDay;
  final Query<Map<String, dynamic>> timelineQuery;
  final String locationId;
  final String tripId;
  final VoidCallback? onDataChanged;
  // Thêm callback khi trạng thái hoạt động thay đổi
  final VoidCallback? onActivityStatusChanged;
  final String? se_tripId;

  const TimelineList({
    Key? key,
    required this.numberDay,
    required this.timelineQuery,
    required this.locationId,
    required this.tripId,
    this.onDataChanged,
    this.onActivityStatusChanged,
    this.se_tripId,
  }) : super(key: key);

  @override
  State<TimelineList> createState() => _TimelineListState();
}

class _TimelineListState extends State<TimelineList> {
  late Future<List<Map<String, dynamic>>> _futureSchedules;
  String? se_tripId;

  @override
  void initState() {
    super.initState();
    _futureSchedules = fetchSchedules();
    fetchSchedules();
    //print('aaaaaaaaa sch '+ widget.se_tripId!);
  }

  // phương thức để reload data
  void reload() {
    setState(() {
      _futureSchedules = fetchSchedules();
    });
  }

  Future<List<Map<String, dynamic>>> fetchSchedules() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Query<Map<String, dynamic>> timelineQuery = widget.timelineQuery;

    // Nếu đã login, kiểm tra trip trong bảng user
    if (uid != null) {
      DocumentReference<Map<String, dynamic>> userTripRef;

      if (widget.se_tripId != null) {
        userTripRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('selected_trips')
            .doc(widget.se_tripId!);
        setState(() {
        se_tripId = userTripRef.id; // dùng để truyền cho TimelineCard
      });
      final userSnap = await userTripRef.get();
      if (userSnap.exists) {
        timelineQuery = userTripRef
            .collection('timelines')
            .where('day_number', isEqualTo: widget.numberDay);
      }
       }
      // else {
      //   final newRef =
      //       FirebaseFirestore.instance
      //           .collection('users')
      //           .doc(uid)
      //           .collection('selected_trips')
      //           .doc(); // tự tạo ID mới
      //   userTripRef = newRef;
      //   final masterRef = FirebaseFirestore.instance
      //       .collection('dia_diem')
      //       .doc(widget.locationId)
      //       .collection('trips')
      //       .doc(widget.tripId);
      //   final masterSnap = await masterRef.get();
      //   if (masterSnap.exists) {
      //     await userTripRef!.set({
      //       ...masterSnap.data()!,
      //       'saved_at': FieldValue.serverTimestamp(),
      //       'location_id': widget.locationId,
      //     }, SetOptions(merge: true));

      //     // copy timelines + schedule
      //     final tlSnap = await masterRef.collection('timelines').get();
      //     for (var tl in tlSnap.docs) {
      //       await userTripRef!.collection('timelines').doc(tl.id).set({
      //         ...tl.data(),
      //         'location_id': widget.locationId,
      //       }, SetOptions(merge: true));
      //       final schSnap = await tl.reference.collection('schedule').get();
      //       for (var sch in schSnap.docs) {
      //         await userTripRef!
      //             .collection('timelines')
      //             .doc(tl.id)
      //             .collection('schedule')
      //             .doc(sch.id)
      //             .set({
      //               ...sch.data(),
      //               'location_id': widget.locationId,
      //             }, SetOptions(merge: true));
      //       }
      //     }
      //   }
      // }
      
    }

    // Lấy danh sách timeline docs (từ user )
    final tDocs = await timelineQuery.get();
    List<Map<String, dynamic>> result = [];

    for (var tDoc in tDocs.docs) {
      final timelineId = tDoc.id;

      // schedule
      final schedSnap =
          await tDoc.reference.collection('schedule').orderBy('hour').get();

      for (var sDoc in schedSnap.docs) {
        final schedule = Schedule.fromSnapshots(tDoc, sDoc);
        final scheduleId = sDoc.id;

        // Hoạt động thì vẫn lấy từ master activities
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
          'act_id': schedule.actId,
          'se_tripId': se_tripId,
        });
      }
    }
    return result;
  }

  Future<bool> checkSelectedTripExists(String seTripId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final userTripRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('selected_trips')
        .doc(seTripId);

    final snap = await userTripRef.get();
    return snap.exists;
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
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 13,
                  ),
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(MyColor.pr5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children:
                        items.map((i) {
                          return TimelineCard(
                            time: i['time'],
                            activities: i['activities'],
                            address: i['address'],
                            price: i['price'],
                            completed: i['completed'],
                            categories: i['categories'],
                            onTap: () async {
                              if (widget.se_tripId == null ||
                                  widget.se_tripId!.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Bạn cần \"Áp dụng chuyến đi\" để chỉnh sửa.',
                                    ),
                                  ),
                                );
                              } else {
                                final seTripId = i['se_tripId'];
                                final exists =
                                    seTripId != null &&
                                    await checkSelectedTripExists(seTripId);

                                if (!exists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Dữ liệu không tông tại'),
                                    ),
                                  );
                                  return;
                                }

                                final updated = await Navigator.push<bool>(
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
                                          actId: i['act_id'],
                                          se_tripId: seTripId,
                                        ),
                                  ),
                                );

                                if (updated == true) {
                                  reload();
                                  widget.onDataChanged?.call();
                                }
                              }
                            },
                          );
                        }).toList(), // ✅ thêm đoạn này
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
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
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
                        if (widget.se_tripId == null ||
                            widget.se_tripId!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Bạn cần \"Áp dụng chuyến đi\" để chỉnh sửa.',
                              ),
                            ),
                          );
                        } else {
                          try {
                            print('🔘 [+] Nút thêm lịch ' + widget.se_tripId!);
                            print('🔘 [+] Nút thêm lịch trình được nhấn');

                            final timelineDocs =
                                await widget.timelineQuery.get();
                            print(
                              '📄 Tổng số timeline docs: ${timelineDocs.docs.length}',
                            );

                            QueryDocumentSnapshot<Map<String, dynamic>>?
                            timelineDoc;

                            try {
                              for (var doc in timelineDocs.docs) {
                                print(
                                  "✅ Timeline doc: ${doc.id}, day_number: ${doc.data()['day_number']}",
                                );
                              }
                              timelineDoc = timelineDocs.docs.firstWhere((doc) {
                                final dayRaw = doc.data()['day_number'];
                                final day =
                                    dayRaw is int
                                        ? dayRaw
                                        : int.tryParse(dayRaw.toString());
                                print('🔍 Kiểm tra doc với day_number = $day');
                                return day == widget.numberDay;
                              });
                            } catch (_) {
                              timelineDoc = null;
                            }
                            late final String firstDoc;
                            if (timelineDoc == null) {
                              print(
                                '❌ Không tìm thấy timeline phù hợp với day = ${widget.numberDay}',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Không tìm thấy timeline cho ngày này',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }

                            final timelineId = timelineDoc.id;
                            print('✅ Tìm thấy timelineId = $timelineId');
                            final snapshot =
                                await FirebaseFirestore.instance
                                    .collection('dia_diem')
                                    .doc(widget.locationId)
                                    .collection('activities')
                                    .where('categories', isEqualTo: 'eat')
                                    .limit(1)
                                    .get();

                            if (snapshot.docs.isNotEmpty) {
                              firstDoc = snapshot.docs.first.id;
                            }
                            final scheduleRef =
                                timelineDoc.reference
                                    .collection('schedule')
                                    .doc();
                            await scheduleRef.set({
                              'hour': '09:00',
                              'act_id': firstDoc,
                              'status': false,
                            });
                            print('✅ Tạo schedule mới: ${scheduleRef.id}');

                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => EditTimelinePage(
                                      time: const TimeOfDay(hour: 9, minute: 0),
                                      activities: '',
                                      address: '',
                                      price: 0,
                                      completed: false,
                                      categories: '',
                                      diaDiemId: widget.locationId,
                                      tripId: widget.tripId,
                                      timelineId:
                                          timelineId, // ✅ đã chắc chắn không null
                                      scheduleId: scheduleRef.id,
                                      actId: firstDoc ?? "",
                                      se_tripId: se_tripId,
                                    ),
                              ),
                            );
                            if (updated == true) {
                              reload();
                              widget.onDataChanged?.call();
                            }
                          } catch (e, st) {
                            print('❗ Lỗi khi thêm lịch trình: $e');
                            print(st);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi khi thêm lịch trình: $e'),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Color(MyColor.pr4),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
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
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
