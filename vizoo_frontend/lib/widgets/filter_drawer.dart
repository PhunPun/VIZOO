import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

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
  Map<String, int>? selectedDayNight;
  final List<int> peopleOptions = [1, 2, 3, 4, 5, 6];
  final List<Map<String, int>> dayNightOptions = [
    {"day": 1, "night": 0},
    {"day": 2, "night": 1},
    {"day": 3, "night": 2},
    {"day": 4, "night": 3},
    {"day": 5, "night": 4},
  ];

  int minPrice = 500000;
  int maxPrice = 15000000;
  String? selectedDiaDiemId;
  void initState() {
    super.initState();
    fetchDiaDiems();

    selectedPrice = widget.initialFilters['maxPrice'] ?? 3000000;
    selectedPeople = widget.initialFilters['people'];
    selectedDiaDiemId = widget.initialFilters['id_dia_diem'];
    
    final day = widget.initialFilters['days'];
    final night = widget.initialFilters['nights'];
    if (day != null && night != null) {
      selectedDayNight = {"day": day, "night": night};
    }
  }
  List<QueryDocumentSnapshot<Map<String, dynamic>>> diaDiemDocs = [];

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

            // Giá tiền
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

            // Số người
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

            // Lịch trình
            const Text("Lịch trình", style: TextStyle(fontSize: 16)),
            DropdownButton<Map<String, int>>(
              value: selectedDayNight,
              hint: const Text("Chọn lịch trình"),
              isExpanded: true,
              items: dayNightOptions.map((option) {
                final day = option["day"]!;
                final night = option["night"]!;
                return DropdownMenuItem(
                  value: option,
                  child: Text('$day ngày $night đêm'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDayNight = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Địa điểm từ Firestore
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

            // Nút áp dụng
            ElevatedButton(
              onPressed: () {
                final filters = {
                  "maxPrice": selectedPrice,
                  "people": selectedPeople,
                  "id_dia_diem": selectedDiaDiemId,
                  "days": selectedDayNight?["day"],
                  "nights": selectedDayNight?["night"],
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
