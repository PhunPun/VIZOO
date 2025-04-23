import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:weather_icons/weather_icons.dart';
import '../Wearher_API/weather_API.dart';

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

  final tripsSnap = await FirebaseFirestore.instance
      .collection('dia_diem')
      .doc(diaDiemId)
      .collection('trips')
      .get();

  final result = <String, List<Map<String, dynamic>>>{};

  for (final tripDoc in tripsSnap.docs) {
    final trip = tripDoc.data();
    final ngayBatDau = (trip['ngay_bat_dau'] as Timestamp).toDate();
    final soNgay = trip['so_ngay'] ?? 0;

    final weatherList = <Map<String, dynamic>>[];

    for (int i = 0; i < soNgay; i++) {
      final d = ngayBatDau.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(d);
      final temps = weatherMap[key]?['temps'] ?? [];
      final descs = weatherMap[key]?['descs'] ?? [];

      final avgTemp = temps.isNotEmpty
          ? (temps.cast<double>().reduce((a, b) => a + b) / temps.length).round()
          : null;

      final desc = descs.isNotEmpty ? _mostCommon(descs.cast<String>()) : null;

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
      'descs': <String>[],
    });

    map[key]!['temps']!.add(temp);
    //map[key]!['descs']!.add(desc);
  }
  return map;
}

String _mostCommon(List<String> items) {
  final counts = <String, int>{};
  for (final item in items) {
    counts[item] = (counts[item] ?? 0) + 1;
  }
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

/// Widget hiển thị danh sách thời tiết của 1 trip
class WeatherCard extends StatelessWidget {
  final String diaDiemId;
  final String tripId;

  const WeatherCard({
    Key? key,
    required this.diaDiemId,
    required this.tripId,
  }) : super(key: key);

  /// Gọi API và lấy thời tiết chỉ cho 1 trip
  Future<List<Map<String, dynamic>>> _getWeatherForTrip() async {
    final allWeather = await getWeatherForAllTripsInLocation(diaDiemId);
    return allWeather[tripId] ?? [];
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
  //(DateTime date, int avgTemp, String description)
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
