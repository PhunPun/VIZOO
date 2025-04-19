import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:vizoo_frontend/models/act_model.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class ActList extends StatefulWidget {
  final String categories;
  
  const ActList({
    super.key,
    required this.categories,
  });

  @override
  State<ActList> createState() => _ActListState();
}

class _ActListState extends State<ActList> {
  String? selectedactName;
  @override
  Widget build(BuildContext context) {
    final List<ActModel> filteredActs = ActModel.getActModel()
        .where((act) => act.actCategories == widget.categories)
        .toList();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      padding: const EdgeInsets.only(top: 13, left: 8, right: 8, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(MyColor.pr5)),
      ),
      child: Column(
        children: [
          if (filteredActs.isEmpty)
            const Text(
              'Không có hoạt động nào cho danh mục này',
              style: TextStyle(
                color: Color(MyColor.grey),
                fontSize: 16,
              ),
            )
          else
            ...filteredActs.map((act) => actCard(act)).toList(),
        ]
      ),
    );
  }

  Widget actCard(ActModel act){
    final bool _isSelected = selectedactName == act.actName;
    return InkWell(
      onTap: () {
        setState(() {
          selectedactName = act.actName;
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              width: 4,
              color: Color(MyColor.pr3)
            ),
            bottom: BorderSide(
                width: 0.2,
                color: Color(MyColor.pr3)
              )
          )
        ),
        child: Row(
          children: [
            Expanded(
              flex: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    act.actName,
                    style: TextStyle(
                      color: Color(MyColor.black),
                      fontSize: 16
                    ),
                  ),
                  Text(
                    act.actAddress,
                    style: TextStyle(
                      color: Color(MyColor.grey),
                      fontSize: 14
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "${NumberFormat("#,###", "vi_VN").format(act.actPrice)}đ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(MyColor.pr4)
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: _isSelected
                  ? SvgPicture.asset(
                      'assets/icons/done.svg',
                      width: 13.33,
                      height: 13.33,
                    )
                  : const SizedBox.shrink(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

