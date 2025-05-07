import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:weather_icons/weather_icons.dart';
import '../Wearher_API/weather_API.dart';




/// Widget hiển thị danh sách thời tiết của 1 trip
class WeatherCard extends StatefulWidget {
  final String diaDiemId;
  final String tripId;
  final String? se_tripId;

  const WeatherCard({
    Key? key,
    required this.diaDiemId,
    required this.tripId,
    this.se_tripId,
  }) : super(key: key);

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  /// Hàm lấy dữ liệu thời tiết cho tất cả các trip trong 1 địa điểm
Future<Map<String, List<Map<String, dynamic>>>> getWeatherForAllTripsInLocation(String diaDiemId) async {
  final diaDiemDoc = await FirebaseFirestore.instance
      .collection('dia_diem')
      .doc(diaDiemId)
      .get();

  final cityName = diaDiemDoc.data()?['ten'] ?? '';
  if (cityName.trim().isEmpty) {
    throw Exception('Tên thành phố rỗng.');
  }

  final weatherData = await WeatherService.fetchWeather(cityName);
  final weatherMap = _groupWeatherDataByDate(weatherData['list']);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null){
    return{};
  }
  QuerySnapshot<Map<String, dynamic>> tripsSnap;
  if(widget.se_tripId != null){
    tripsSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('selected_trips')
        .get();
  }else{
    tripsSnap = await FirebaseFirestore.instance
      .collection('dia_diem')
      .doc(diaDiemId)
      .collection('trips')
      .get();
  }
  

  final result = <String, List<Map<String, dynamic>>>{};
  final uid = FirebaseAuth.instance.currentUser?.uid;

  for (final tripDoc in tripsSnap.docs) {
    final trip = tripDoc.data();
    DateTime ngayBatDau = (trip['ngay_bat_dau'] as Timestamp).toDate();
    int soNgay = trip['so_ngay'] ?? 0;

    // 2) Nếu user đã lưu trip này, override từ users/{uid}/selected_trips/{tripId}
    if (uid != null) {
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('selected_trips')
          .doc(tripDoc.id)
          .get();
      if (userSnap.exists) {
        final userData = userSnap.data() as Map<String, dynamic>;
        if (userData.containsKey('ngay_bat_dau')) {
          ngayBatDau = (userData['ngay_bat_dau'] as Timestamp).toDate();
        }
        if (userData.containsKey('so_ngay')) {
          soNgay = userData['so_ngay'] as int;
        }
      }
    }

    final weatherList = <Map<String, dynamic>>[];

    for (int i = 0; i < soNgay; i++) {
      final d = ngayBatDau.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(d);
      final temps = weatherMap[key]?['temps'] ?? [];
      final descs = weatherMap[key]?['descs'] ?? [];

      final avgTemp = temps.isNotEmpty
          ? (temps.cast<double>().reduce((a, b) => a + b) / temps.length).round()
          : null;

      //final desc = descs.isNotEmpty ? _mostCommon(descs.cast<String>()) : null;

      weatherList.add({
        'date': key,
        'avgTemp': avgTemp,
        //'description': desc,
      });
    }
    result[tripDoc.id] = weatherList;
  }
  return result;
}

Map<String, Map<String, List>> _groupWeatherDataByDate(List<dynamic> list) {
  final map = <String, Map<String, List>>{};
  for (final item in list) {
    final m = item as Map<String, dynamic>;
    final dt = DateTime.fromMillisecondsSinceEpoch(m['dt'] * 1000);
    final key = DateFormat('yyyy-MM-dd').format(dt);
    final temp = (m['main']['temp'] as num).toDouble();
    //final desc = m['weather'][0]['description'] as String;

    map.putIfAbsent(key, () => {
      'temps': <double>[],
      //'descs': <String>[],
    });

    map[key]!['temps']!.add(temp);
    //map[key]!['descs']!.add(desc);
  }
  return map;
}
  /// Gọi API và lấy thời tiết chỉ cho 1 trip
  Future<List<Map<String, dynamic>>> _getWeatherForTrip() async {
    final allWeather = await getWeatherForAllTripsInLocation(widget.diaDiemId);
    if(widget.se_tripId != null){
      return allWeather[widget.se_tripId] ?? [];
    }else{
      return allWeather[widget.tripId] ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getWeatherForTrip(),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) {
          return Center(child: Text('Lỗi: ${snap.error ?? 'Không có dữ liệu thời tiết'}'));
        }

        final weatherList = snap.data!;
        return Column(
          children: weatherList.map((item) {
            final date = DateTime.parse(item['date']);
            final avgTemp = item['avgTemp'] ?? 0;
            //final desc = item['description'] ?? '---';
            // return _buildWeatherItem(date, avgTemp, desc);
            return _buildWeatherItem(date, avgTemp);
          }).toList(),
        );
      },
    );
  }

  Widget _buildWeatherItem(DateTime date, int avgTemp) {
    IconData weatherIcon;
    if (avgTemp >= 28) {
      weatherIcon = WeatherIcons.day_sunny;
    } else if (avgTemp >= 20) {
      weatherIcon = WeatherIcons.cloudy;
    } else if (avgTemp >= 10) {
      weatherIcon = WeatherIcons.day_snow;
    } else {
      weatherIcon = WeatherIcons.night_clear;
    }
    return Container(
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border(
            bottom: BorderSide(
              color: Color(MyColor.pr3),
              width: 0.5,
            )
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(date),
                      style: const TextStyle(
                          color: Color(MyColor.black),
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(weatherIcon, size: 20, color: Colors.orange),
                    const SizedBox(width: 5,),
                    Text(
                      '$avgTemp°C',
                      style: const TextStyle(
                          color: Color(MyColor.black),
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
