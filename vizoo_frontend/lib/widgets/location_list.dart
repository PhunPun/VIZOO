import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/widgets/locations_card.dart';

import '../models/locations_models.dart';

// class LocationList extends StatelessWidget {
//   LocationList({super.key});
//
//   final List<LocationsModel> locations = LocationsModel.getLocations();
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 137,
//       child: ListView.builder(
//         padding: EdgeInsets.only(right: 8),
//         scrollDirection: Axis.horizontal,
//         itemCount: locations.length,
//         itemBuilder: (context, index){
//           return LocationsCard(
//             ten: locations[index].name,
//             hinhAnh1: locations[index].imageUrl,
//           );
//         },
//       ),
//     );
//   }
// }

class LocationList extends StatelessWidget {
  const LocationList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 137,
      child: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('dia_diem').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có địa điểm'));
          }

          final List<DiaDiem> diaDiemList = snapshot.data!.docs.map((doc) {
            return DiaDiem.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: diaDiemList.length,
            itemBuilder: (context, index) {
              final diaDiem = diaDiemList[index];
              return LocationsCard(ten: diaDiem.ten,
                     hinhAnh1: diaDiem.hinhAnh1,);
            },
          );
        },
      ),
    );
  }
}

