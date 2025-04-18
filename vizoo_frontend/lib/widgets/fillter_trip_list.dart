import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/models/trip_models.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';

class FillterTripList extends StatelessWidget {
  final Map<String, dynamic> filters;
  const FillterTripList({super.key, this.filters = const {}});

  Future<List<Trips>> _fetchTrips() async {
    try {
      Query query;

      // Nếu có id_dia_diem -> lấy từ collection riêng
      if (filters['id_dia_diem'] != null) {
        query = FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(filters['id_dia_diem'])
            .collection('trips');
      } else {
        // Nếu không có id_dia_diem -> lấy toàn bộ trips
        query = FirebaseFirestore.instance.collectionGroup('trips');
      }

      // Áp dụng các điều kiện lọc khác
      if (filters['maxPrice'] != null) {
        query = query.where('chi_phi', isLessThanOrEqualTo: filters['maxPrice']);
      }
      if (filters['people'] != null) {
        query = query.where('so_nguoi', isEqualTo: filters['people']);
      }
      if (filters['days'] != null) {
        query = query.where('so_ngay', isEqualTo: filters['days']);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Trips.fromFirestore(doc)).toList();
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
          print('Lỗi: ${snapshot.error}');
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
            return TripCard(trip: trips[index]);
          },
        );
      },
    );
  }
}
