import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    fetchTripData().then((_) => fetchDayNumbers());
  }

  Future<void> fetchTripData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('dia_diem')
          .doc(widget.locationId)
          .collection('trips')
          .doc(widget.tripId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
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

  Future<void> fetchDayNumbers() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('dia_diem')
          .doc(widget.locationId)
          .collection('trips')
          .doc(widget.tripId)
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
              );
            }).toList(),
          Container(
            padding: const EdgeInsets.only(bottom: 30),
            child:
            Center(
              child: tripData == null
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: tripData!.status == null
                    ? null
                    : () async {
                  try {
                    final newStatus = !tripData!.status!;
                    await FirebaseFirestore.instance
                        .collection('dia_diem')
                        .doc(widget.locationId)
                        .collection('trips')
                        .doc(widget.tripId)
                        .update({'status': newStatus});

                    setState(() {
                      tripData = tripData!.copyWith(status: newStatus);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã cập nhật trạng thái thành công')),
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
                  tripData!.status! ? 'Dừng hàng trình' : 'Áp dụng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}
