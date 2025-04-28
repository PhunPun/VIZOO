import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});

  void addSampleActivities() async {
  final activitiesRef = FirebaseFirestore.instance
      .collection("dia_diem")
      .doc("4eJDHyp6eYbE1G8RwMyw") // Đà Lạt
      .collection('activities');

  // --- eat ---
  await activitiesRef.add({'name': 'Bánh căn Nhà Chung', 'address': '13 Nhà Chung, Đà Lạt', 'categories': 'eat', 'price': 30000});
  await activitiesRef.add({'name': 'Nem nướng Bà Hùng', 'address': '254 Phan Đình Phùng, Đà Lạt', 'categories': 'eat', 'price': 50000});
  await activitiesRef.add({'name': 'Lẩu gà lá é Tao Ngộ', 'address': '5 3 Tháng 4, Đà Lạt', 'categories': 'eat', 'price': 200000});
  await activitiesRef.add({'name': 'Bánh mì xíu mại Hoàng Diệu', 'address': '26 Hoàng Diệu, Đà Lạt', 'categories': 'eat', 'price': 25000});
  await activitiesRef.add({'name': 'Bánh ướt lòng gà Long', 'address': '202 Phan Đình Phùng, Đà Lạt', 'categories': 'eat', 'price': 40000});
  await activitiesRef.add({'name': 'Cháo ếch Singapore 151', 'address': '151 Bùi Thị Xuân, Đà Lạt', 'categories': 'eat', 'price': 60000});

  // --- drink ---
  await activitiesRef.add({'name': 'Cafe Tùng', 'address': '06 Khu Hòa Bình, Đà Lạt', 'categories': 'drink', 'price': 50000});
  await activitiesRef.add({'name': 'An Cafe', 'address': '63Bis Đường 3/2, Đà Lạt', 'categories': 'drink', 'price': 60000});
  await activitiesRef.add({'name': 'The Married Beans', 'address': '6 Nguyễn Chí Thanh, Đà Lạt', 'categories': 'drink', 'price': 70000});
  await activitiesRef.add({'name': 'La Viet Coffee', 'address': '200 Nguyễn Công Trứ, Đà Lạt', 'categories': 'drink', 'price': 70000});
  await activitiesRef.add({'name': 'Dalaland', 'address': 'Đèo Mimosa, Đà Lạt', 'categories': 'drink', 'price': 90000});
  await activitiesRef.add({'name': 'The Wilder Nest', 'address': 'Đèo Prenn, Đà Lạt', 'categories': 'drink', 'price': 80000});
  await activitiesRef.add({'name': 'Cafe Panorama', 'address': 'Đèo Trại Mát, Đà Lạt', 'categories': 'drink', 'price': 80000});

  // --- play ---
  await activitiesRef.add({'name': 'Thung lũng Tình Yêu', 'address': '07 Mai Anh Đào, Đà Lạt', 'categories': 'play', 'price': 250000});
  await activitiesRef.add({'name': 'Hồ Xuân Hương', 'address': 'Trung tâm thành phố, Đà Lạt', 'categories': 'play', 'price': 0});
  await activitiesRef.add({'name': 'Langbiang', 'address': 'Lạc Dương, Đà Lạt', 'categories': 'play', 'price': 50000});
  await activitiesRef.add({'name': 'Đồi chè Cầu Đất', 'address': 'Xuân Trường, Đà Lạt', 'categories': 'play', 'price': 30000});
  await activitiesRef.add({'name': 'Chợ đêm Đà Lạt', 'address': 'Nguyễn Thị Minh Khai, Đà Lạt', 'categories': 'play', 'price': 0});
  await activitiesRef.add({'name': 'Nhà thờ Con Gà', 'address': '15 Trần Phú, Đà Lạt', 'categories': 'play', 'price': 0});
  await activitiesRef.add({'name': 'Dinh Bảo Đại', 'address': '01 Triệu Việt Vương, Đà Lạt', 'categories': 'play', 'price': 40000});
  await activitiesRef.add({'name': 'Quảng trường Lâm Viên', 'address': 'Trần Quốc Toản, Đà Lạt', 'categories': 'play', 'price': 0});
  await activitiesRef.add({'name': 'Crazy House', 'address': '03 Huỳnh Thúc Kháng, Đà Lạt', 'categories': 'play', 'price': 60000});

  // --- hotel ---
  await activitiesRef.add({'name': 'Dalat Palace Heritage Hotel', 'address': '02 Trần Phú, Đà Lạt', 'categories': 'hotel', 'price': 5000000});
  await activitiesRef.add({'name': 'Ana Mandara Villas Dalat Resort & Spa', 'address': 'Le Lai, Đà Lạt', 'categories': 'hotel', 'price': 4000000});
  await activitiesRef.add({'name': 'Terracotta Hotel & Resort', 'address': 'Zone 7.9, Tuyền Lâm Lake, Đà Lạt', 'categories': 'hotel', 'price': 3000000});
  await activitiesRef.add({'name': 'Dalat Edensee Lake Resort & Spa', 'address': 'Tuyền Lâm Lake, Đà Lạt', 'categories': 'hotel', 'price': 4500000});
  await activitiesRef.add({'name': 'Swiss-BelResort Tuyen Lam', 'address': 'Zone 7&8, Tuyền Lâm Lake, Đà Lạt', 'categories': 'hotel', 'price': 2500000});
  await activitiesRef.add({'name': 'Ladalat Hotel', 'address': '106A Mai Anh Đào, Đà Lạt', 'categories': 'hotel', 'price': 2000000});
  await activitiesRef.add({'name': 'Colline Hotel', 'address': '10 Phan Bội Châu, Đà Lạt', 'categories': 'hotel', 'price': 1800000});
  await activitiesRef.add({'name': 'Mường Thanh Holiday Đà Lạt', 'address': '42 Phan Bội Châu, Đà Lạt', 'categories': 'hotel', 'price': 1700000});
}

  void addScheduleItems() async {
  final scheduleRef = FirebaseFirestore.instance
    .collection("dia_diem")
    .doc("6cHdpF1FDYcERqUEvzCz")
    .collection("trips")
    .doc("Tin61S3STSWEDbjypkYY")
    .collection("timelines")
    .doc("7Q6n7r1G0m1lcIUcF3eW")
    .collection("schedule");

  final List<String> activityIds = [
    "2UdLSjX7p7yEjufF35UF",
    "2xANpJkWjMc3cpYWCFRn",
    "4e3pWRjbPq3hUW5DZn8x",
    "604WbdwFToIOw1qVvqOs",
    "6BsQF01NGaGivR43bWp4",
    "6kQHcYY70sQUWHIyiGJ1",
    "7QmHXhrWUNxag4ojBQcM",
    "9ukA1aOW2fEs35hPdihG",
    "Ei0SBjHjO85vHGSQnqod",
    "FHWvzEjRIEUjTl1IbTtm",
    // thêm nếu muốn đủ 40+
  ];

  for (int i = 0; i < activityIds.length; i++) {
    await scheduleRef.add({
      'act_id': activityIds[i],
      'hour': '${7 + i ~/ 2}:${(i % 2 == 0) ? '30' : '00'}', // giờ tự động tăng
      'status': false,
    });
  }

  print("Đã thêm tất cả activities vào schedule.");
}

void addSampleTripsDaNang() async {
  final tripRef = FirebaseFirestore.instance
      .collection("dia_diem")
      .doc("4eJDHyp6eYbE1G8RwMyw")
      .collection("trips");

  final List<Map<String, dynamic>> daLatTrips = [
    {
      'anh': 'https://i.pinimg.com/736x/55/10/44/5510445ad8e8391e48c41cad589f584b.jpg',
      'chi_phi': 1800000,
      'danh_gia': 5,
      'love': true,
      'name': 'Đà Lạt mùa hoa',
      'ngay_bat_dau': '10/05/2024',
      'noi_o': 'Khách sạn TTC Đà Lạt',
      'so_act': 9,
      'so_eat': 7,
      'so_ngay': 3,
      'so_nguoi': 2,
    },
    {
      'anh': 'https://i.pinimg.com/736x/bc/83/ba/bc83bab6fb507b149f3d64b5e29049cf.jpg',
      'chi_phi': 2000000,
      'danh_gia': 4,
      'love': false,
      'name': 'Food Tour Đà Lạt',
      'ngay_bat_dau': '20/05/2024',
      'noi_o': 'Homestay Dalat Note',
      'so_act': 8,
      'so_eat': 9,
      'so_ngay': 2,
      'so_nguoi': 1,
    },
    {
      'anh': 'https://i.pinimg.com/736x/98/80/87/988087266d6cf95378682dd8a1675412.jpg',
      'chi_phi': 2500000,
      'danh_gia': 5,
      'love': true,
      'name': 'Săn mây đồi chè',
      'ngay_bat_dau': '25/05/2024',
      'noi_o': 'Ana Mandara Villas Dalat',
      'so_act': 10,
      'so_eat': 6,
      'so_ngay': 3,
      'so_nguoi': 2,
    },
    {
      'anh': 'https://i.pinimg.com/736x/cb/fd/61/cbfd613328b9fd0d9a1d797ac7e46f75.jpg',
      'chi_phi': 2200000,
      'danh_gia': 4,
      'love': false,
      'name': 'Langbiang - khám phá',
      'ngay_bat_dau': '01/06/2024',
      'noi_o': 'Swiss-BelResort Tuyền Lâm',
      'so_act': 7,
      'so_eat': 5,
      'so_ngay': 3,
      'so_nguoi': 2,
    },
    {
      'anh': 'https://i.pinimg.com/736x/e7/db/3c/e7db3c45dfae9090ad09bda9c0c81f5a.jpg',
      'chi_phi': 2100000,
      'danh_gia': 5,
      'love': true,
      'name': 'Đà Lạt săn dã quỳ',
      'ngay_bat_dau': '08/06/2024',
      'noi_o': 'Colline Hotel Dalat',
      'so_act': 6,
      'so_eat': 5,
      'so_ngay': 2,
      'so_nguoi': 2,
    },
  ];

  for (var trip in daLatTrips) {
    await tripRef.add(trip);
  }

  print("✅ Đã thêm danh sách trips tại Đà Lạt thành công!");
}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 150,),
          Image.asset(
            'assets/images/earth.png'
          ),
          Text(
            'What to eat? Where to go?',
            style: TextStyle(
              fontSize: 20,
              color: Color(MyColor.pr5)
            ),
          ),
          Text(
            'Let Vizoo guide you!',
            style: TextStyle(
              fontSize: 20,
              color: Color(MyColor.pr5)
            ),
          ),
          const SizedBox(height: 20,),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.goNamed(RouterName.login);
                    //addSampleActivities();
                    //addScheduleItems();
                    //addSampleTripsDaNang();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(MyColor.pr4),
                    minimumSize: Size(122, 37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  ),
                  child: Text(
                    'Get started',
                    style: TextStyle(
                      color: Color(MyColor.white),
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(width: 20,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}