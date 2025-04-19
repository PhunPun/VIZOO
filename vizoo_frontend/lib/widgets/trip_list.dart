import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';
import '../models/trip_models.dart';

class TripList extends StatelessWidget {
  const TripList({super.key});

  Future<List<Trips>> _fetchTrips() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('trips') // Lấy tất cả các trips từ mọi địa điểm
          .get();
      return snapshot.docs.map((doc) {
        // Kiểm tra các trường và xử lý null
        final data = doc.data() as Map<String, dynamic>;

        // Tạo đối tượng Trips từ dữ liệu Firestore
        return Trips.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải dữ liệu: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trips>>(
      future: _fetchTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có chuyến đi nào'));
        }

        final trips = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            return TripCard(
              trip: trips[index],
            );
          },
        );
      },
    );
  }
}