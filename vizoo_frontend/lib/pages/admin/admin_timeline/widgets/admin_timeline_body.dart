import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/calculator/day_format.dart';
import 'package:vizoo_frontend/pages/admin/admin_timeline/widgets/admin_timeline_list.dart';
import 'package:vizoo_frontend/pages/admin/calculator/admin_set_day_start.dart';
import 'package:vizoo_frontend/pages/admin/calculator/admin_set_people_num.dart';
import 'package:vizoo_frontend/pages/admin/widgets/admin_trip_card.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/models/trip_models_json.dart';

class AdminTimelineBody extends StatefulWidget {
  final String tripId;
  final String locationId;
  final VoidCallback onRefreshTripData;

  const AdminTimelineBody({
    super.key,
    required this.tripId,
    required this.locationId,
    required this.onRefreshTripData,
  });

  @override
  State<AdminTimelineBody> createState() => _AdminTimelineBodyState();
}

class _AdminTimelineBodyState extends State<AdminTimelineBody> {
  Trip? tripData;
  DateTime initDate = DateTime.now();
  List<int> days = [];
  String? _selectedFilterDay;
  final List<int> dayOptions = [1, 2, 3, 4, 5, 6, 7];
  int? so_ngay;

  @override
  void initState() {
    super.initState();
    fetchTripData().then((_) => fetchDayNumbers());
  }

  Future<void> fetchTripData() async {
    print('[DEBUG] fetchTripData đang chạy');
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
          so_ngay = trip.soNgay;
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

      final fetchedDays =
          snap.docs.map((d) => (d.data()['day_number'] as int)).toList();

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

  void onSetStay(String newStay) {
    if (tripData != null) {
      setState(() {
        tripData = tripData!.copyWith(noiO: newStay);
      });
    }
  }

  void onSetActivityCount(int newCount) {
    if (tripData != null) {
      setState(() {
        tripData = tripData!.copyWith(soAct: newCount);
      });
    }
  }

  void onSetMealCount(int newCount) {
    if (tripData != null) {
      setState(() {
        tripData = tripData!.copyWith(soEat: newCount);
      });
    }
  }

  Future<void> refreshTripData() async {
    await fetchTripData();
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
          AdminTripCard(
            trip: tripData!,
            onDeleted: () {
              widget.onRefreshTripData(); // ✅ gọi lại hàm từ cha
            },
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(MyColor.pr3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(MyColor.pr3), width: 2),
                ),
              ),
              value: _selectedFilterDay ?? so_ngay?.toString(),
              items: dayOptions.map((day) {
                return DropdownMenuItem<String>(
                  value: day.toString(),
                  child: Text(dayFormat(day)),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  final newSoNgay = int.parse(value);
                  setState(() {
                    _selectedFilterDay = value;
                  });

                  try {
                    // Cập nhật số ngày trong trip
                    await FirebaseFirestore.instance
                        .collection('dia_diem')
                        .doc(widget.locationId)
                        .collection('trips')
                        .doc(widget.tripId)
                        .update({'so_ngay': newSoNgay});

                    // Đồng bộ timelines
                    final timelinesRef = FirebaseFirestore.instance
                        .collection('dia_diem')
                        .doc(widget.locationId)
                        .collection('trips')
                        .doc(widget.tripId)
                        .collection('timelines');

                    final currentTimelinesSnap = await timelinesRef.get();
                    final currentDayNumbers = currentTimelinesSnap.docs
                        .map((doc) => doc.data()['day_number'] as int)
                        .toSet();

                    for (int i = 1; i <= newSoNgay; i++) {
                      if (!currentDayNumbers.contains(i)) {
                        await timelinesRef.add({'day_number': i});
                      }
                    }

                    for (final doc in currentTimelinesSnap.docs) {
                      final dayNumber = doc.data()['day_number'] as int;
                      if (dayNumber > newSoNgay) {
                        await doc.reference.delete();
                      }
                    }

                    // Cập nhật local state
                    setState(() {
                      so_ngay = newSoNgay;
                      tripData = tripData!.copyWith(soNgay: newSoNgay);
                    });

                    await fetchDayNumbers(); // cập nhật lại danh sách ngày mới

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật số ngày thành công'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi cập nhật: $e')),
                    );
                  }
                }
              },
            ),
          ),
          AdminSetPeopleNum(
            peopleNum: tripData!.soNguoi,
            cost: tripData!.chiPhi,
            onSetPeople: onSetPeople,
            onSetCost: onSetCost,
            diaDiemId: widget.locationId,
            tripId: widget.tripId,
          ),
          AdminSetDayStart(
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
              final query = FirebaseFirestore.instance
                  .collection('dia_diem')
                  .doc(widget.locationId)
                  .collection('trips')
                  .doc(widget.tripId)
                  .collection('timelines')
                  .where('day_number', isEqualTo: day);

              return AdminTimelineList(
                numberDay: day,
                timelineQuery: query,
                locationId: widget.locationId,
                tripId: widget.tripId,
                onRefreshTripData: widget.onRefreshTripData,
              );
            }).toList(),
        ],
      ),
    );
  }
}
