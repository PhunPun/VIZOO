import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class SetDayStart extends StatefulWidget {
  const SetDayStart({super.key});

  @override
  State<SetDayStart> createState() => _SetDayStartState();
}

class _SetDayStartState extends State<SetDayStart> {
  DateTime _selectedDate = DateTime.now();

  // Hàm hiển thị date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(MyColor.pr4), // Màu chủ đạo
              onPrimary: Colors.white, // Màu chữ trên primary
              surface: Colors.white, // Màu nền
              onSurface: Colors.black, // Màu chữ
            ),
            dialogTheme: DialogTheme( 
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(MyColor.pr3)),
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
                    SvgPicture.asset('assets/icons/schedule.svg'),
                    const SizedBox(width: 8),
                    const Text(
                      'Ngày bắt đầu',
                      style: TextStyle(
                        color: Color(MyColor.black),
                        fontSize: 18
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
                        fontWeight: FontWeight.w500
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
          )
        ],
      ),
    );
  }
}