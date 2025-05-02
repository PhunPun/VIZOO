import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/weather_card.dart';

class AdminSetDayStart extends StatefulWidget {
  final DateTime dateStart;
  final int numberDay;
  final ValueChanged<DateTime> onChangeDate;
  final String locationId;
  final String tripId;

  const AdminSetDayStart({
    super.key,
    required this.dateStart,
    required this.numberDay,
    required this.onChangeDate,
    required this.locationId,
    required this.tripId,
  });

  @override
  State<AdminSetDayStart> createState() => _AdminSetDayStartState();
}

class _AdminSetDayStartState extends State<AdminSetDayStart> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.dateStart;
  }

  Future<void> _selectDate(BuildContext context) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    builder: (ctx, child) => Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: ColorScheme.light(
          primary: Color(MyColor.pr4),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: child!,
    ),
  );

  if (picked != null && picked != _selectedDate) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day); 
    if (picked.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể chọn ngày trong quá khứ!')),
      );
      return; 
    }

    setState(() {
      _selectedDate = picked;
    });
    widget.onChangeDate(_selectedDate);
    await _updateFirestore(_selectedDate);
  }
}

  Future<void> _updateFirestore(DateTime newDate) async {
    try {
      await FirebaseFirestore.instance
          .collection('dia_diem')
          .doc(widget.locationId)
          .collection('trips')
          .doc(widget.tripId)
          .update({
        'ngay_bat_dau': Timestamp.fromDate(newDate),
      });
    } catch (e) {
      print('Lỗi cập nhật ngày bắt đầu Firestore: $e');
    }
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
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/schedule.svg'),
                    const SizedBox(width: 8),
                    const Text(
                      'Ngày bắt đầu',
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
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
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
          WeatherCard(
            diaDiemId: widget.locationId,
            tripId: widget.tripId,
          ),
        ],
      ),
    );
  }
}
