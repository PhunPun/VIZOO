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

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// void main() {
//   runApp(MyApp());
// }
//
// /// Widget chính
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Weather API Test',
//       home: WeatherTestScreen(),
//     );
//   }
// }
//
// /// Màn hình test API
// class WeatherTestScreen extends StatefulWidget {
//   @override
//   _WeatherTestScreenState createState() => _WeatherTestScreenState();
// }
//
// class _WeatherTestScreenState extends State<WeatherTestScreen> {
//   String city = "Quang tri";
//   String temperature = "";
//   String description = "";
//   bool isLoading = true;
//   String errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     testWeatherAPI();
//   }
//
//   Future<Map<String, dynamic>> fetchWeather(String city) async {
//     final apiKey = 'ed57a6779f4f51b754bb2c73ce7344b0'; // ✅ Đảm bảo thay bằng key thật
//     final url =
//         'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=vi';
//
//     final response = await http.get(Uri.parse(url));
//
//     print('🔍 URL gọi: $url');
//     print('📡 Status code: ${response.statusCode}');
//     print('📄 Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Không thể tải dữ liệu thời tiết');
//     }
//   }
//
//   /// Hàm test đơn giản
//   void testWeatherAPI() async {
//     try {
//       final weather = await fetchWeather(city);
//       setState(() {
//         temperature = '${weather['main']['temp']}°C';
//         description = weather['weather'][0]['description'];
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = '❌ Lỗi khi gọi API: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Weather Information')),
//       body: Center(
//         child: isLoading
//             ? CircularProgressIndicator() // Hiển thị khi đang tải
//             : errorMessage.isNotEmpty
//             ? Text(errorMessage) // Hiển thị lỗi nếu có
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               '📍 Thành phố: $city',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 10),
//             Text(
//               '🌡️ Nhiệt độ: $temperature',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 10),
//             Text(
//               '☁️ Mô tả: $description',
//               style: TextStyle(fontSize: 24),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo binding được khởi tạo
//   await Firebase.initializeApp(); // Khởi tạo Firebase
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Trip Weather App',
//       home: TripListScreen(),
//     );
//   }
// }
//
// class Trip {
//   final String id;
//   final String name;
//   final String locationId;
//   final String ngay_bat_dau; // Ngày bắt đầu (chuyển đổi từ Timestamp)
//
//   Trip({required this.id, required this.name, required this.locationId, required this.ngay_bat_dau});
//
//   factory Trip.fromJson(Map<String, dynamic> data, {required String id, required String locationId}) {
//     String startDate = 'Không xác định';
//     if (data.containsKey('startDate') && data['startDate'] != null) {
//       final timestamp = data['startDate'] as Timestamp;
//       startDate = timestamp.toDate().toString().split(' ')[0];
//     }
//
//     return Trip(
//       id: id,
//       name: data['name'] ?? 'Chuyến đi không tên',
//       locationId: locationId,
//       ngay_bat_dau: startDate,
//     );
//   }
//
// }
//
// class TripListScreen extends StatefulWidget {
//   @override
//   _TripListScreenState createState() => _TripListScreenState();
// }
//
// class _TripListScreenState extends State<TripListScreen> {
//   late Future<List<Trip>> futureTrips;
//
//   @override
//   void initState() {
//     super.initState();
//     futureTrips = _fetchTrips();
//   }
//
//   Future<List<Trip>> _fetchTrips() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collectionGroup('trips')
//           .get();
//
//       return snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         final tripId = doc.id;
//         final locationId = doc.reference.parent.parent?.id ?? '';
//
//         return Trip.fromJson(data, id: tripId, locationId: locationId);
//       }).toList();
//     } catch (e) {
//       throw Exception('Lỗi khi tải dữ liệu: $e');
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchWeather(String city) async {
//     final apiKey = 'ed57a6779f4f51b754bb2c73ce7344b0';
//     final url =
//         'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=vi';
//
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Không thể tải dữ liệu thời tiết');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Danh sách chuyến đi')),
//       body: FutureBuilder<List<Trip>>(
//         future: futureTrips,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Lỗi: ${snapshot.error}'));
//           }
//
//           final trips = snapshot.data ?? [];
//
//           return ListView.builder(
//             itemCount: trips.length,
//             itemBuilder: (context, index) {
//               final trip = trips[index];
//
//               return ListTile(
//                 title: Text(trip.name),
//                 subtitle: Text('Mã địa điểm: ${trip.locationId}'),
//                 onTap: () async {
//                   try {
//                     final diaDiemDoc = await FirebaseFirestore.instance
//                         .collection('dia_diem')
//                         .doc(trip.locationId)
//                         .get();
//
//                     final cityName = diaDiemDoc.data()?['ten'] ?? 'Không rõ';
//
//                     final weather = await fetchWeather(cityName);
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => TripDetailScreen(
//                           trip: trip,
//                           weather: weather,
//                         ),
//                       ),
//                     );
//                   } catch (e) {
//                     print('Lỗi khi lấy thời tiết: $e');
//                   }
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
// class TripDetailScreen extends StatelessWidget {
//   final Trip trip;
//   final Map<String, dynamic> weather;
//
//   TripDetailScreen({required this.trip, required this.weather});
//
//   @override
//   Widget build(BuildContext context) {
//     // Lấy dữ liệu thời tiết cho 3 ngày
//     final forecastList = _get3DayForecast(weather);
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Chi tiết chuyến đi')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Tên chuyến đi: ${trip.name}',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Text('Ngày bắt đầu: ${trip.ngay_bat_dau}', style: TextStyle(fontSize: 20)),
//             SizedBox(height: 20),
//             Text('📍 Thành phố: ${weather['city']['name']}', style: TextStyle(fontSize: 20)),
//             SizedBox(height: 10),
//             Text('Dự báo thời tiết trong 3 ngày tới:', style: TextStyle(fontSize: 22)),
//             SizedBox(height: 10),
//             // Hiển thị thông tin thời tiết 3 ngày
//             Column(
//               children: forecastList.map((forecast) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(forecast['date'], style: TextStyle(fontSize: 18)),
//                       Text('${forecast['temp']}°C', style: TextStyle(fontSize: 18)),
//                       Text(forecast['description'], style: TextStyle(fontSize: 18)),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Hàm lấy dự báo 3 ngày
//   List<Map<String, dynamic>> _get3DayForecast(Map<String, dynamic> weatherData) {
//     final List<Map<String, dynamic>> forecastList = [];
//
//     for (int i = 0; i < 3; i++) {
//       final forecast = weatherData['list'][i * 8]; // Mỗi ngày có 8 lần dự báo (3 giờ/lần)
//       final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
//       final temp = forecast['main']['temp'];
//       final description = forecast['weather'][0]['description'];
//
//       forecastList.add({
//         'date': '${date.day}/${date.month}', // Ngày/tháng
//         'temp': temp,
//         'description': description,
//       });
//     }
//
//     return forecastList;
//   }
// }
