import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

/// ✅ Class đại diện cho lựa chọn lịch trình (ngày, đêm)
class DayNightOption {
  final int day;
  final int night;

  DayNightOption(this.day, this.night);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayNightOption &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          night == other.night;

  @override
  int get hashCode => day.hashCode ^ night.hashCode;

  @override
  String toString() => '$day ngày $night đêm';
}

/// ✅ Widget FilterDrawer
class FilterDrawer extends StatefulWidget {
  final void Function(Map<String, dynamic>) onApply;
  final Map<String, dynamic> initialFilters;

  const FilterDrawer({
    super.key,
    required this.onApply,
    this.initialFilters = const {},
  });

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  int selectedPrice = 3000000;
  int? selectedPeople;
  String? selectedLocation;
  DayNightOption? selectedDayNight;
  String? selectedDiaDiemId;

  final List<int> peopleOptions = [1, 2, 3, 4, 5, 6];
  final List<DayNightOption> dayNightOptions = [
    DayNightOption(1, 0),
    DayNightOption(2, 1),
    DayNightOption(3, 2),
    DayNightOption(4, 3),
    DayNightOption(5, 4),
  ];

  int minPrice = 500000;
  int maxPrice = 15000000;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> diaDiemDocs = [];

  @override
  void initState() {
    super.initState();
    fetchDiaDiems();

    selectedPrice = widget.initialFilters['maxPrice'] ?? 3000000;
    selectedPeople = widget.initialFilters['people'];
    selectedDiaDiemId = widget.initialFilters['id_dia_diem'];

    final day = widget.initialFilters['days'];
    final night = widget.initialFilters['nights'];
    if (day != null && night != null) {
      selectedDayNight = dayNightOptions.firstWhere(
        (option) => option.day == day && option.night == night,
        orElse: () => DayNightOption(day, night),
      );
    }
  }

  Future<void> fetchDiaDiems() async {
    final snapshot = await FirebaseFirestore.instance.collection('dia_diem').get();
    setState(() {
      diaDiemDocs = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Bộ lọc",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(MyColor.pr5)),
            ),
            const SizedBox(height: 24),

            const Text("Giá tiền", style: TextStyle(fontSize: 16)),
            Text(
              "${NumberFormat("#,###", "vi_VN").format(selectedPrice)}đ",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: selectedPrice.toDouble(),
              min: minPrice.toDouble(),
              max: maxPrice.toDouble(),
              divisions: ((maxPrice - minPrice) ~/ 500000),
              label: "${NumberFormat("#,###", "vi_VN").format(selectedPrice)}đ",
              activeColor: Color(MyColor.pr4),
              thumbColor: Color(MyColor.pr5),
              onChanged: (value) {
                setState(() {
                  selectedPrice = value.toInt();
                });
              },
            ),

            const SizedBox(height: 20),

            const Text("Số người", style: TextStyle(fontSize: 16)),
            DropdownButton<int>(
              value: selectedPeople,
              hint: const Text("Chọn số người"),
              isExpanded: true,
              items: peopleOptions.map((num) {
                return DropdownMenuItem(
                  value: num,
                  child: Text('$num người'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPeople = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Text("Lịch trình", style: TextStyle(fontSize: 16)),
            DropdownButton<DayNightOption>(
              value: selectedDayNight,
              hint: const Text("Chọn lịch trình"),
              isExpanded: true,
              items: dayNightOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDayNight = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Text("Địa điểm", style: TextStyle(fontSize: 16)),
            diaDiemDocs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : DropdownButton<String>(
                    value: selectedDiaDiemId,
                    hint: const Text("Chọn địa điểm"),
                    isExpanded: true,
                    items: diaDiemDocs.map((doc) {
                      final name = doc['ten'] ?? 'Không tên';
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDiaDiemId = value;
                      });
                    },
                  ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                final filters = {
                  "maxPrice": selectedPrice,
                  "people": selectedPeople,
                  "id_dia_diem": selectedDiaDiemId,
                  "days": selectedDayNight?.day,
                  "nights": selectedDayNight?.night,
                };

                widget.onApply(filters);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(MyColor.pr5)),
              child: const Text(
                "Áp dụng",
                style: TextStyle(
                    color: Color(MyColor.white),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
