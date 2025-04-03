import 'package:flutter/material.dart';
import 'package:vizoo_frontend/models/locations_model.dart';
import 'package:vizoo_frontend/widgets/locations_card.dart';

class LocationList extends StatelessWidget {
  LocationList({super.key});

  final List<LocationsModel> locations = LocationsModel.getLocations();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 137,
      child: ListView.builder(
        padding: EdgeInsets.only(right: 8),
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        itemBuilder: (context, index){
          return LocationsCard(
            name: locations[index].name,
            imageUrl: locations[index].imageUrl,
          );
        },
      ),
    );
  }
}