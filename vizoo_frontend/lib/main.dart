import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vizoo_frontend/pages/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Trong suốt
    statusBarIconBrightness: Brightness.dark, // Đổi màu icon (light = icon trắng, dark = icon đen)
    systemNavigationBarColor: Colors.transparent, // Làm trong suốt hoặc đổi thành màu nền
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  await Firebase.initializeApp();
  runApp(const MyApp());
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
//
// /// Model Trip lấy dữ liệu từ subcollection `trips`
// class Trip {
//   final String id;
//   final String name;
//   final String imageUrl;
//   final int cost;
//   final double rating;
//   final bool love;
//   final DateTime startDate;
//   final String accommodation;
//   final int days;
//   final int eats;
//   final int acts;
//   final int people;
//
//   Trip({
//     required this.id,
//     required this.name,
//     required this.imageUrl,
//     required this.cost,
//     required this.rating,
//     required this.love,
//     required this.startDate,
//     required this.accommodation,
//     required this.days,
//     required this.eats,
//     required this.acts,
//     required this.people,
//   });
//
//   factory Trip.fromSnapshot(DocumentSnapshot snap) {
//     final data = snap.data() as Map<String, dynamic>;
//     return Trip(
//       id: snap.id,
//       name: data['name'] ?? '',
//       imageUrl: data['anh'] ?? '',
//       cost: data['chi_phi']?.toInt() ?? 0,
//       rating: (data['danh_gia'] as num?)?.toDouble() ?? 0.0,
//       love: data['love'] ?? false,
//       startDate: (data['ngay_bat_dau'] as Timestamp).toDate(),
//       accommodation: data['noi_o'] ?? '',
//       days: data['so_ngay'] ?? 0,
//       eats: data['so_eat'] ?? 0,
//       acts: data['so_act'] ?? 0,
//       people: data['so_nguoi'] ?? 0,
//     );
//   }
// }
//
// /// Model Activity lấy dữ liệu từ subcollection `activities`
// class Activity {
//   final String id;
//   final String name;
//   final String address;
//   final List<String> categories;
//   final int price;
//
//   Activity({
//     required this.id,
//     required this.name,
//     required this.address,
//     required this.categories,
//     required this.price,
//   });
//
//   factory Activity.fromSnapshot(DocumentSnapshot snap) {
//     final data = snap.data() as Map<String, dynamic>;
//     return Activity(
//       id: snap.id,
//       name: data['name'] ?? '',
//       address: data['address'] ?? '',
//       categories: (data['categories'] is List)
//           ? List<String>.from(data['categories'])
//           : [],
//       price: data['price']?.toInt() ?? 0,
//     );
//   }
// }
//
// /// Model Schedule từ subcollection `schedule`
// class Schedule {
//   final String id;
//   final int dayNumber;
//   final String actId;
//   final String hour;
//   final bool status;
//
//   Schedule({
//     required this.id,
//     required this.dayNumber,
//     required this.actId,
//     required this.hour,
//     required this.status,
//   });
//
//   factory Schedule.fromSnapshots(
//       DocumentSnapshot timelineSnap,
//       DocumentSnapshot schedSnap) {
//     final tData = timelineSnap.data() as Map<String, dynamic>;
//     final sData = schedSnap.data() as Map<String, dynamic>;
//     return Schedule(
//       id: schedSnap.id,
//       dayNumber: tData['day_number']?.toInt() ?? 0,
//       actId: sData['act_id'] ?? '',
//       hour: sData['hour'] ?? '',
//       status: sData['status'] ?? false,
//     );
//   }
// }
//
// class TripListScreen extends StatelessWidget {
//   final String diaDiemId;
//
//   const TripListScreen({Key? key, required this.diaDiemId}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final ref = FirebaseFirestore.instance
//         .collection('dia_diem')
//         .doc(diaDiemId)
//         .collection('trips');
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Danh sách Chuyến đi')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: ref.snapshots(),
//         builder: (ctx, snap) {
//           if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final trips = snap.data!.docs.map((d) => Trip.fromSnapshot(d)).toList();
//           if (trips.isEmpty) return const Center(child: Text('Chưa có chuyến nào'));
//
//           return ListView.builder(
//             itemCount: trips.length,
//             itemBuilder: (ctx, i) {
//               final t = trips[i];
//               return ListTile(
//                 leading: Image.network(t.imageUrl, width: 60, fit: BoxFit.cover),
//                 title: Text(t.name),
//                 trailing: Icon(t.love ? Icons.favorite : Icons.favorite_border),
//                 onTap: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (_) => TripDetailScreen(
//                         diaDiemId: diaDiemId,
//                         trip: t,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class TripDetailScreen extends StatefulWidget {
//   final String diaDiemId;
//   final Trip trip;
//
//   const TripDetailScreen({Key? key, required this.diaDiemId, required this.trip})
//       : super(key: key);
//
//   @override
//   State<TripDetailScreen> createState() => _TripDetailScreenState();
// }
//
// class _TripDetailScreenState extends State<TripDetailScreen> {
//   late final CollectionReference timelinesRef;
//
//   @override
//   void initState() {
//     super.initState();
//     timelinesRef = FirebaseFirestore.instance
//         .collection('dia_diem')
//         .doc(widget.diaDiemId)
//         .collection('trips')
//         .doc(widget.trip.id)
//         .collection('timelines');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.trip.name)),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: timelinesRef.orderBy('day_number').snapshots(),
//         builder: (ctx, tlSnap) {
//           if (tlSnap.hasError) return Center(child: Text('Error: ${tlSnap.error}'));
//           if (tlSnap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final timelines = tlSnap.data!.docs;
//           if (timelines.isEmpty) return const Center(child: Text('Không có timeline'));
//
//           return ListView(
//             children: timelines.map((tDoc) {
//               final dayNum = (tDoc.data() as Map<String, dynamic>)['day_number'];
//               return ExpansionTile(
//                 title: Text('Ngày $dayNum'),
//                 children: [
//                   StreamBuilder<QuerySnapshot>(
//                     stream: tDoc.reference
//                         .collection('schedule')
//                         .orderBy('hour')
//                         .snapshots(),
//                     builder: (ctx2, scSnap) {
//                       if (scSnap.hasError) return ListTile(title: Text('Lỗi tải schedule'));
//                       if (!scSnap.hasData) return const SizedBox();
//
//                       return Column(
//                         children: scSnap.data!.docs.map((sDoc) {
//                           final sched = Schedule.fromSnapshots(tDoc, sDoc);
//                           return FutureBuilder<DocumentSnapshot>(
//                             future: FirebaseFirestore.instance
//                                 .collection('dia_diem')
//                                 .doc(widget.diaDiemId)
//                                 .collection('activities')
//                                 .doc(sched.actId)
//                                 .get(),
//                             builder: (ctx3, actSnap) {
//                               if (!actSnap.hasData) return const ListTile();
//                               final act = Activity.fromSnapshot(actSnap.data!);
//                               return ListTile(
//                                 leading: Text(sched.hour),
//                                 title: Text(act.name),
//                                 subtitle: Text(act.address),
//                                 trailing: Icon(
//                                   sched.status ? Icons.check_circle : Icons.radio_button_unchecked,
//                                   color: sched.status ? Colors.green : Colors.grey,
//                                 ),
//                               );
//                             },
//                           );
//                         }).toList(),
//                       );
//                     },
//                   ),
//                 ],
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(); // Khởi tạo Firebase trước khi chạy ứng dụng.
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Chuyến đi Du lịch',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ứng dụng Du lịch'),
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('dia_diem')
//             .doc('6cHdpF1FDYcERqUEvzCz')
//             .get(),
//         builder: (ctx, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text('Không có dữ liệu địa điểm.'));
//           }
//           final diaDiemData = snapshot.data!;
//           final diaDiemId = diaDiemData.id;
//
//           return TripListScreen(diaDiemId: diaDiemId);
//         },
//       ),
//     );
//   }
// }