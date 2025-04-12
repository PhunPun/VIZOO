import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({super.key});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  final List<int> peopleOptions = [1, 2, 3, 4, 5, 6];
  final List<String> locations = ['Hà Nội', 'Đà Nẵng', 'Hồ Chí Minh', 'Đà Lạt'];
  final List<Map<String, int>> dayNightOptions = [
    {"day": 1, "night": 0},
    {"day": 2, "night": 1},
    {"day": 3, "night": 2},
    {"day": 4, "night": 3},
    {"day": 5, "night": 4},
  ];

  int selectedPrice = 1000000; // giá mặc định
  int minPrice = 500000;
  int maxPrice = 5000000;

  int? selectedPeople;
  String? selectedLocation;
  Map<String, int>? selectedDayNight;

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
                color: Color(MyColor.pr5)
              )),

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
            const Text("Địa điểm", style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: selectedLocation,
              hint: const Text("Chọn địa điểm"),
              isExpanded: true,
              items: locations.map((loc) {
                return DropdownMenuItem(
                  value: loc,
                  child: Text(loc),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
              },
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Gửi dữ liệu lọc về ở đây nếu cần
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(MyColor.pr5)
              ),
              child: const Text(
                "Áp dụng",
                style: TextStyle(
                  color: Color(MyColor.white),
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
