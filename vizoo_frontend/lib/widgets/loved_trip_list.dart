import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/trip_models.dart';
import 'trip_card.dart';

class LovedTripList extends StatelessWidget {
  const LovedTripList({super.key});

  Future<List<Trips>> _fetchLovedTrips() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    // Lấy danh sách trip_id đã yêu thích
    final loveSnapshot = await FirebaseFirestore.instance
        .collection('love')
        .where('user_id', isEqualTo: currentUser.uid)
        .get();

    final lovedTripIds = loveSnapshot.docs.map((doc) => doc['trip_id']).toSet();

    if (lovedTripIds.isEmpty) return [];

    // Lấy tất cả trips rồi lọc theo trip_id đã yêu thích
    final allTripsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('trips')
        .get();

    return allTripsSnapshot.docs
        .where((doc) => lovedTripIds.contains(doc.id))
        .map((doc) => Trips.fromFirestore(doc))
        .toList();


  }

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder<List<Trips>>(
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
            return TripCard(
              trip: trips[index],
            );
          },
        );
      },
    );
  }
}
