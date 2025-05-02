
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/set_day_start.dart';
import 'package:vizoo_frontend/widgets/set_people_num.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_list.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';
import 'package:vizoo_frontend/models/trip_models_json.dart';

class TimelineBody extends StatefulWidget {
  final String tripId;
  final String locationId;

  const TimelineBody({
    super.key,
    required this.tripId,
    required this.locationId,
  });

  @override
  State<TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<TimelineBody> {
  Trip? tripData;
  DateTime initDate = DateTime.now();
  List<int> days = [];


  late final DocumentReference<Map<String, dynamic>> _masterTripRef;
  DocumentReference<Map<String, dynamic>>? _userTripRef;
  bool _useUserData = false;

  @override
  void initState() {
    super.initState();
    _masterTripRef = FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.locationId)
        .collection('trips')
        .doc(widget.tripId)
    as DocumentReference<Map<String, dynamic>>;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userTripRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('selected_trips')
          .doc(widget.tripId)
      as DocumentReference<Map<String, dynamic>>;
    }

    // Lần đầu: kiểm tra và fetch dữ liệu
    _loadTripData().then((_) => _fetchDayNumbers());
  }

  Future<void> _loadTripData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapUser;
      if (_userTripRef != null) {
        snapUser = await _userTripRef!.get();
        if (snapUser.exists) {
          _useUserData = true;
          final data = snapUser.data()!;
          final trip = Trip.fromJson(
            data,
            id: widget.tripId,
            locationId: widget.locationId,
          );
          setState(() {
            tripData = trip;
            initDate = trip.ngayBatDau;
          });
          return;
        }
      }

      // Nếu không có trong user -> fetch dia diem
      final snapMaster = await _masterTripRef.get();
      if (snapMaster.exists) {
        final data = snapMaster.data()!;
        final trip = Trip.fromJson(
          data,
          id: widget.tripId,
          locationId: widget.locationId,
        );
        setState(() {
          tripData = trip;
          initDate = trip.ngayBatDau;
        });
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu chuyến đi: $e');
    }
  }

  Future<void> _fetchDayNumbers() async {
    try {
      // chọn đúng collection timelines dựa vào _useUserData
      final baseRef = (_useUserData && _userTripRef != null)
          ? _userTripRef!
          : _masterTripRef;

      final snap = await baseRef
          .collection('timelines')
          .orderBy('day_number')
          .get();

      final fetchedDays = snap.docs
          .map((d) => (d.data()['day_number'] as int))
          .toList();

      setState(() {
        days = fetchedDays;
      });
      print('Các ngày có lịch trình: $days');
    } catch (e) {
      print('Lỗi khi lấy dữ liệu ngày: $e');
    }
  }

  void onSetPeople(int newCount) {
    if (tripData != null) {
      setState(() {
        tripData = tripData!.copyWith(soNguoi: newCount);
      });
    }
  }

  void onSetCost(int newCost) {
    if (tripData != null) {
      setState(() {
        tripData = tripData!.copyWith(chiPhi: newCost);
      });
    }
  }

  void onChangeDate(DateTime newDate) {

    setState(() {
      initDate = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (tripData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // chuẩn bị query cho TimelineList
    Query<Map<String, dynamic>> timelineQuery = (_useUserData && _userTripRef != null)
        ? _userTripRef!.collection('timelines')
        .where('day_number', isEqualTo: 0)
        : FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.locationId)
        .collection('trips')
        .doc(widget.tripId)
        .collection('timelines')
        .where('day_number', isEqualTo: 0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripCard(trip: tripData!),
          SetPeopleNum(
            peopleNum: tripData!.soNguoi,
            cost: tripData!.chiPhi,
            onSetPeople: onSetPeople,
            onSetCost: onSetCost,
            diaDiemId: widget.locationId,
            tripId: widget.tripId,
          ),
          SetDayStart(
            dateStart: initDate,
            numberDay: tripData!.soNgay,
            onChangeDate: onChangeDate,
            locationId: widget.locationId,
            tripId: widget.tripId,
          ),
          const SizedBox(height: 16),

          if (days.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Không có lịch trình cho ngày nào'),
            )
          else
            ...days.map((day) {
              // Tạo query để lấy đúng timeline docs của ngày này
              final query = FirebaseFirestore.instance
                  .collection('dia_diem')
                  .doc(widget.locationId)
                  .collection('trips')
                  .doc(widget.tripId)
                  .collection('timelines')
                  .where('day_number', isEqualTo: day);
                  //.orderBy('hour');

              return TimelineList(
                numberDay: day,
                timelineQuery: query,
                locationId: widget.locationId,
                tripId: widget.tripId,
                  onDataChanged: () async {
                    await _loadTripData();
                    await _fetchDayNumbers();
                  }
              );
            }).toList(),
          SizedBox(height: 12,),
          Container(
            padding: const EdgeInsets.only(bottom: 30),
            child: Center(
              child: tripData == null
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: tripData!.status == null
                    ? null
                    : () async {
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final selectedTrips = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('selected_trips')
                        .where('status', isEqualTo: true)
                        .get();

                    // Nếu đang áp dụng mới và đã có 1 trip status true khác
                    if (!tripData!.status! && selectedTrips.docs.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bạn đã có một hành trình đang áp dụng. Vui lòng dừng hoặc hoàn thành hành trình đó trước.'),
                        ),
                      );
                      return;
                    }

                    // Nếu chưa lưu vào user -> copy như cũ
                    if (!_useUserData && _userTripRef != null) {
                      final masterSnap = await _masterTripRef.get();
                      if (masterSnap.exists) {
                        await _userTripRef!.set({
                          ...masterSnap.data()!,
                          'saved_at': FieldValue.serverTimestamp(),
                          'location_id': widget.locationId,
                        }, SetOptions(merge: true));

                        final tlSnap = await _masterTripRef.collection('timelines').get();
                        for (var tl in tlSnap.docs) {
                          await _userTripRef!
                              .collection('timelines')
                              .doc(tl.id)
                              .set(tl.data(), SetOptions(merge: true));
                          final schSnap = await tl.reference.collection('schedule').get();
                          for (var sch in schSnap.docs) {
                            await _userTripRef!
                                .collection('timelines')
                                .doc(tl.id)
                                .collection('schedule')
                                .doc(sch.id)
                                .set(sch.data(), SetOptions(merge: true));
                          }
                        }
                        _useUserData = true;
                      }
                    }

                    final targetRef = (_useUserData && _userTripRef != null)
                        ? _userTripRef!
                        : _masterTripRef;

                    final newStatus = !(tripData!.status!);
                    await targetRef.update({
                      'status': newStatus,
                      'location_id': widget.locationId,
                    });

                    setState(() {
                      tripData = tripData!.copyWith(status: newStatus);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Áp dụng thành công')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi cập nhật: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(MyColor.pr4),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  tripData!.status! ? 'Dừng hành trình' : 'Áp dụng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
