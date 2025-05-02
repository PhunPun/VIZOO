import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../themes/colors/colors.dart';

class AddSchedulePage extends StatefulWidget {
  final String locationId;
  final String tripId;
  final int dayNumber;

  const AddSchedulePage({
    Key? key,
    required this.locationId,
    required this.tripId,
    required this.dayNumber,
  }) : super(key: key);

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  String? _selectedActId;
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<List<QueryDocumentSnapshot>> _loadActivities() async {
    final snap = await FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.locationId)
        .collection('activities')
        .get();
    return snap.docs;
  }

  Future<void> _save() async {
    if (_selectedActId == null) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final masterTripRef = FirebaseFirestore.instance
        .collection('dia_diem')
        .doc(widget.locationId)
        .collection('trips')
        .doc(widget.tripId);

    final userTripRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('selected_trips')
        .doc(widget.tripId);

    // Nếu userTrip chưa có, copy toàn bộ dữ liệu từ diadiem
    final userTripSnap = await userTripRef.get();
    if (!userTripSnap.exists) {
      // Sao chép dữ liệu từ diadiem sang selected_trips
      final masterSnap = await masterTripRef.get();
      if (masterSnap.exists) {
        await userTripRef.set({
          ...masterSnap.data()!,
          'location_id': widget.locationId,
        }, SetOptions(merge: true));
      }
      //  copy timelines và schedule
      final tlSnap = await masterTripRef.collection('timelines').get();
      for (var tlDoc in tlSnap.docs) {
        // timeline
        await userTripRef
            .collection('timelines')
            .doc(tlDoc.id)
            .set(tlDoc.data(), SetOptions(merge: true));

        // schedules
        final schSnap = await tlDoc.reference.collection('schedule').get();
        for (var schDoc in schSnap.docs) {
          await userTripRef
              .collection('timelines')
              .doc(tlDoc.id)
              .collection('schedule')
              .doc(schDoc.id)
              .set(schDoc.data(), SetOptions(merge: true));
        }
      }
    }

    final timelineSnap = await userTripRef
        .collection('timelines')
        .where('day_number', isEqualTo: widget.dayNumber)
        .limit(1)
        .get();


    DocumentReference timelineRef;
    if (timelineSnap.docs.isEmpty) {
      timelineRef = await userTripRef.collection('timelines').add({
        'day_number': widget.dayNumber,
      });
    } else {
      timelineRef = timelineSnap.docs.first.reference;
    }

    //Kiểm tra nếu act_id đã tồn tại trong schedule
    final existing = await timelineRef
        .collection('schedule')
        .where('act_id', isEqualTo: _selectedActId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hoạt động này đã có trong lịch trình.')),
      );
      return;
    }

   // Thêm nếu chưa tồn tại
    await timelineRef.collection('schedule').add({
      'act_id': _selectedActId!,
      'hour': _selectedTime.format(context),
      'status': false,
    });
    Navigator.pop(context, true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Hoạt Động', style: TextStyle(fontWeight: FontWeight.bold,color: Color(MyColor.pr5)),),
        centerTitle: true,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _loadActivities(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final activities = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Chọn hoạt động',
                            border: OutlineInputBorder(),
                          ),
                          items: activities.map((doc) {
                            return DropdownMenuItem(
                              value: doc.id,
                              child: Text(doc['name'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedActId = v),
                          value: _selectedActId,
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (t != null) setState(() => _selectedTime = t);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Giờ: ${_selectedTime.format(context)}'),
                                const Icon(Icons.access_time),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Color(MyColor.pr4)
                  ),
                  child: const Text('Lưu', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}