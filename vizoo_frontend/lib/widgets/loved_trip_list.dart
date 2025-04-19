import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/models/trip_models_json.dart';
import 'trip_card.dart';

class LovedTripList extends StatelessWidget {
  const LovedTripList({super.key});

  Future<List<Trip>> _fetchLovedTrips() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    // Lấy danh sách trip_id đã yêu thích
    final loveSnapshot = await FirebaseFirestore.instance
        .collection('love')
        .where('user_id', isEqualTo: currentUser.uid)
        .get();

    final lovedTripIds = loveSnapshot.docs
        .map((doc) => doc['trip_id'] as String)
        .toSet();

    if (lovedTripIds.isEmpty) return [];

    // Lấy tất cả trips rồi lọc theo trip_id đã yêu thích
    final allTripsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('trips')
        .get();

    List<Trip> lovedTrips = [];

    for (var doc in allTripsSnapshot.docs) {
      if (lovedTripIds.contains(doc.id)) {
        final data = doc.data();
        final tripId = doc.id;

        // Lấy locationId từ đường dẫn: dia_diem/{locationId}/trips/{tripId}
        final segments = doc.reference.path.split('/');
        String locationId = 'unknown';
        final tripIndex = segments.indexOf('trips');
        if (tripIndex > 0) {
          locationId = segments[tripIndex - 1];
        }

        lovedTrips.add(Trip.fromJson(data, id: tripId, locationId: locationId));
      }
    }

    return lovedTrips;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trip>>(
      future: _fetchLovedTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Bạn chưa yêu thích chuyến đi nào.'));
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
