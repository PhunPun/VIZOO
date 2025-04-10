import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class WeatherCard extends StatefulWidget {
  final DateTime dateStart;
  final int numberDay;
  const WeatherCard({
    super.key,
    required this.dateStart,
    required this.numberDay,
  });

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.numberDay,
      itemBuilder: (context, index){
        return _buildWeatherItem(widget.dateStart.add(Duration(days: index)));
      }
    );
  }

Widget _buildWeatherItem(DateTime date){
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
                  SvgPicture.asset(
                    'assets/icons/sun.svg'
                  ),
                  const SizedBox(width: 3,),
                  Text(
                    '30'+'°',
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

