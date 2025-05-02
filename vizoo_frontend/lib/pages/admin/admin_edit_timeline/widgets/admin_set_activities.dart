import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class AdminSetActivities extends StatefulWidget {
  final String actCategories;
  final ValueChanged<String> onChangeCategories;

  const AdminSetActivities({
    super.key,
    required this.actCategories,
    required this.onChangeCategories,
  });

  @override
  State<AdminSetActivities> createState() => _AdminSetActivitiesState();
}

class _AdminSetActivitiesState extends State<AdminSetActivities> {
  // map tiếng Việt <-> key trong Firestore
  final Map<String, String> _activityMap = {
    'Ăn': 'eat',
    'Uống': 'drink',
    'Chơi': 'play',
    'Nơi ở': 'hotel',
  };

  late String _selectedActivityVi;
  bool _showActivities = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo từ widget.actCategories
    _selectedActivityVi = _activityMap.entries
        .firstWhere((e) => e.value == widget.actCategories,
        orElse: () => const MapEntry('Ăn', 'eat'))
        .key;

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(MyColor.pr3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/icons/activities.svg'),
              const SizedBox(width: 14),
              const Text(
                'Hoạt động',
                style: TextStyle(
                  color: Color(MyColor.black),
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => setState(() => _showActivities = !_showActivities),
                child: Text(
                  _selectedActivityVi,
                  style: const TextStyle(
                    color: Color(MyColor.pr4),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(color: const Color(MyColor.pr5), height: 2),
          if (_showActivities)
            ..._activityMap.keys.map((activityVi) => InkWell(
              onTap: () {
                setState(() {
                  _selectedActivityVi = activityVi;
                  _showActivities = false;
                });
                // gọi callback về parent
                widget.onChangeCategories(_activityMap[activityVi]!);
              },
              child: Container(
                height: 31,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedActivityVi == activityVi
                      ? Color(MyColor.pr1)
                      : Colors.transparent,
                  border: const Border(top: BorderSide(width: 1)),
                ),
                child: Text(
                  activityVi,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(MyColor.black),
                    fontWeight: _selectedActivityVi == activityVi
                        ? FontWeight.bold
                        : FontWeight.w400,
                  ),
                ),
              ),
            )),
        ],
      ),
    );
  }
}

