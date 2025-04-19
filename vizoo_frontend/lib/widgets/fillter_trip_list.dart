import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/models/trip_models_json.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';

class FillterTripList extends StatelessWidget {
  final Map<String, dynamic> filters;
  const FillterTripList({super.key, this.filters = const {}});

  Future<List<Trip>> _fetchTrips() async {
    try {
      List<Trip> trips = [];

      if (filters['id_dia_diem'] != null) {
        // Lấy dữ liệu từ một địa điểm cụ thể
        final tripSnapshot = await FirebaseFirestore.instance
            .collection('dia_diem')
            .doc(filters['id_dia_diem'])
            .collection('trips')
            .get();

        for (var doc in tripSnapshot.docs) {
          final data = doc.data();

          // Áp dụng các điều kiện lọc
          if (_matchFilters(data)) {
            trips.add(Trip.fromJson(
              data,
              id: doc.id,
              locationId: filters['id_dia_diem'],
            ));
          }
        }
      } else {
        // Lấy toàn bộ trips từ tất cả địa điểm
        final diaDiemSnapshot =
            await FirebaseFirestore.instance.collection('dia_diem').get();

        for (var diaDiemDoc in diaDiemSnapshot.docs) {
          final tripSnapshot = await FirebaseFirestore.instance
              .collection('dia_diem')
              .doc(diaDiemDoc.id)
              .collection('trips')
              .get();

          for (var tripDoc in tripSnapshot.docs) {
            final data = tripDoc.data();

            if (_matchFilters(data)) {
              trips.add(Trip.fromJson(
                data,
                id: tripDoc.id,
                locationId: diaDiemDoc.id,
              ));
            }
          }
        }
      }

      return trips;
    } catch (e) {
      throw Exception('Lỗi khi tải dữ liệu: $e');
    }
  }

  bool _matchFilters(Map<String, dynamic> data) {
    // Kiểm tra từng bộ lọc
    if (filters['maxPrice'] != null &&
        (data['chi_phi'] ?? 0) > filters['maxPrice']) return false;

    if (filters['people'] != null &&
        (data['so_nguoi'] ?? -1) != filters['people']) return false;

    if (filters['days'] != null &&
        (data['so_ngay'] ?? -1) != filters['days']) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trip>>(
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
