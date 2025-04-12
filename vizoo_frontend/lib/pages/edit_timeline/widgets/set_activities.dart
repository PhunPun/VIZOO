import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class SetActivities extends StatefulWidget {
  final String actCategories;
  final ValueChanged<String> onChangeCategories;
  const SetActivities({
    super.key,
    required this.actCategories,
    required this.onChangeCategories
  });

  @override
  State<SetActivities> createState() => _SetActivitiesState();
}

class _SetActivitiesState extends State<SetActivities> {
  final List<String> _activities = ['Ăn', 'Uống', 'Chơi', 'Nơi ở'];
  late String _selectedActivity;
  bool _showActivities = false;

  @override
  void initState() {
    super.initState();
    _selectedActivity = widget.actCategories;
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
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Row(
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
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showActivities = !_showActivities;
                    });
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _selectedActivity, // Hiển thị hoạt động được chọn
                      style: const TextStyle(
                        color: Color(MyColor.pr4),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 2,
            margin: const EdgeInsets.only(left: 15, top: 4),
            color: const Color(MyColor.pr5),
          ),
          // Hiển thị danh sách hoạt động trực tiếp
          if (_showActivities)
              ..._activities.map((activity) => InkWell(
                    onTap: () {
                      setState(() {
                        _selectedActivity = activity;
                         widget.onChangeCategories(_selectedActivity);
                        _showActivities = false; 
                      });
                    },
                    child: _activitiesName(_selectedActivity, activity),
                  )),
        ],
      ),
    );
  }
}

Widget _activitiesName(String selectedActivity, String activity) {
  return Container(
    height: 31,
    alignment: AlignmentDirectional.center,
    decoration: BoxDecoration(
      color: selectedActivity == activity ? Color(MyColor.pr1) : Colors.transparent,
      border: const Border(
        top: BorderSide(width: 1),
      ),
    ),
    child: Text(
      activity,
      style: TextStyle(
        fontSize: 16,
        color: const Color(MyColor.black),
        fontWeight: selectedActivity == activity ? FontWeight.bold : FontWeight.w400,
      ),
    ),
  );
}