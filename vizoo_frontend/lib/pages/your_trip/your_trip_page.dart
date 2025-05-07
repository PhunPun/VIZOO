import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/timeline/widgets/timeline_body.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/hearder.dart';

class YourTripPage extends StatefulWidget {
  final String? se_tripId;
  const YourTripPage({
    super.key,
    this.se_tripId,
  });

  @override
  State<YourTripPage> createState() => _YourTripPageState();
}

class _YourTripPageState extends State<YourTripPage> {
  late Future<QuerySnapshot<Map<String, dynamic>>> _futureTrips;
  String? se_tripId;

  @override
  void initState() {
  super.initState();
  _futureTrips = _fetchOngoingTrips().then((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        se_tripId = snapshot.docs.first.id;
      });
    }
    return snapshot;
  });
}

  /// Gọi lại truy vấn chuyến đi đang tiến hành
  Future<QuerySnapshot<Map<String, dynamic>>> _fetchOngoingTrips() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('selected_trips')
        .where('status', isEqualTo: true)
        .get();
  }

  /// Gọi lại setState để FutureBuilder rebuild
  void _refreshTrips() {
    setState(() {
      _futureTrips = _fetchOngoingTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _futureTrips,
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
                    key: ValueKey(tripId), // ép rebuild nếu cần
                    tripId: tripId,
                    locationId: locationId,
                    se_tripId: se_tripId,
                   // onDataChanged: _refreshTrips, // ✅ gọi lại nếu bên trong thay đổi
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
