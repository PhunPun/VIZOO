import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';
import '../models/trip_models.dart';
import '../pages/timeline/timeline_page.dart';

class TripList extends StatelessWidget {
  const TripList({super.key});

  Future<List<Trip>> _fetchTrips() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('trips')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final tripId = doc.id;
        final locationId = doc.reference.parent.parent?.id ?? '';

        return Trip.fromJson(data, id: tripId, locationId: locationId);
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải dữ liệu: $e');
    }
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
          return Center(child: Text('Lỗi : ${snapshot.error}'));
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
            final trip = trips[index];
            return TripCard(
              trip: trip,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimelinePage(
                      tripId: trip.id,
                      locationId: trip.locationId,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
