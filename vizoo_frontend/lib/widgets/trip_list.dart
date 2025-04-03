import 'package:flutter/material.dart';
import 'package:vizoo_frontend/models/trip_model.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';

class TripList extends StatelessWidget {
  // Danh sách trips được lấy từ TripModel
  final List<TripModel> trips = TripModel.getTrips();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: trips.map((trip) {
        return TripCard(
          address: trip.address, 
          imageUrl: trip.imageUrl, 
          dayNum: trip.dayNum, 
          activitiesNum: trip.activitiesNum, 
          mealNum: trip.mealNum, 
          peopleNum: trip.peopleNum, 
          residence: trip.residence, 
          cost: trip.cost, 
          rating: trip.rating,
        );
      }).toList(),
    );
  }
}
