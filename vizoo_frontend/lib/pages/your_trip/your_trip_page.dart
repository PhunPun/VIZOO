import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_body.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/hearder.dart';

class YourTripPage extends StatelessWidget {
  const YourTripPage({super.key});

  Future<QuerySnapshot<Map<String, dynamic>>> _fetchOngoingTrips() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('selected_trips')
        .where('status', isEqualTo: true)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _fetchOngoingTrips(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Lỗi: ${snap.error}'));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('Chưa có chuyến nào đang tiến hành.'));
        }

        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 38),
              const Hearder(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  'Lịch trình đang tiến hành',
                  style: TextStyle(
                    color: Color(MyColor.black),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ...docs.map((doc) {
                final data = doc.data();
                final tripId = doc.id;
                final locationId = data['location_id'] as String? ?? '';

                if (locationId.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Thiếu location_id, vui lòng kiểm tra lưu dữ liệu.'),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TimelineBody(
                    tripId: tripId,
                    locationId: locationId,
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
