import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});

  void addSampleActivities() async {
  final activitiesRefHanoi = FirebaseFirestore.instance
    .collection("dia_diem")
    .doc("d6pQM0l3VVIHpRWwc2s8") // Hà Nội
    .collection('activities');

// --- eat ---
await activitiesRefHanoi.add({'name': 'Phở Thìn Bờ Hồ', 'address': '61 Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội', 'categories': 'eat', 'price': 50000});
await activitiesRefHanoi.add({'name': 'Bún chả Hương Liên', 'address': '24 Lê Văn Hưu, Hai Bà Trưng, Hà Nội', 'categories': 'eat', 'price': 50000});
await activitiesRefHanoi.add({'name': 'Chả cá Lã Vọng', 'address': '14 Chả Cá, Hoàn Kiếm, Hà Nội', 'categories': 'eat', 'price': 150000});
await activitiesRefHanoi.add({'name': 'Bún đậu mắm tôm Mơ', 'address': '1B Ngõ Tràng Tiền, Hoàn Kiếm, Hà Nội', 'categories': 'eat', 'price': 40000});
await activitiesRefHanoi.add({'name': 'Xôi Yến', 'address': '35B Nguyễn Hữu Huân, Hoàn Kiếm, Hà Nội', 'categories': 'eat', 'price': 35000});

// --- drink ---
await activitiesRefHanoi.add({'name': 'The Note Coffee', 'address': '64 Lương Văn Can, Hoàn Kiếm, Hà Nội', 'categories': 'drink', 'price': 45000});
await activitiesRefHanoi.add({'name': 'Cafe Giảng', 'address': '39 Nguyễn Hữu Huân, Hoàn Kiếm, Hà Nội', 'categories': 'drink', 'price': 40000});
await activitiesRefHanoi.add({'name': 'Cong Cafe', 'address': '54 Mã Mây, Hoàn Kiếm, Hà Nội', 'categories': 'drink', 'price': 45000});
await activitiesRefHanoi.add({'name': 'Tranquil Books & Coffee', 'address': '5 Nguyễn Quang Bích, Hoàn Kiếm, Hà Nội', 'categories': 'drink', 'price': 50000});
await activitiesRefHanoi.add({'name': 'Serein Cafe & Lounge', 'address': '16 Trần Nhật Duật, Long Biên, Hà Nội', 'categories': 'drink', 'price': 60000});

// --- play ---
await activitiesRefHanoi.add({'name': 'Hồ Gươm', 'address': 'Hoàn Kiếm, Hà Nội', 'categories': 'play', 'price': 0});
await activitiesRefHanoi.add({'name': 'Lăng Bác', 'address': 'Số 2 Hùng Vương, Ba Đình, Hà Nội', 'categories': 'play', 'price': 0});
await activitiesRefHanoi.add({'name': 'Văn Miếu - Quốc Tử Giám', 'address': '58 Quốc Tử Giám, Đống Đa, Hà Nội', 'categories': 'play', 'price': 30000});
await activitiesRefHanoi.add({'name': 'Phố cổ Hà Nội', 'address': 'Hoàn Kiếm, Hà Nội', 'categories': 'play', 'price': 0});
await activitiesRefHanoi.add({'name': 'Chùa Trấn Quốc', 'address': 'Thanh Niên, Tây Hồ, Hà Nội', 'categories': 'play', 'price': 0});
await activitiesRefHanoi.add({'name': 'Hoàng thành Thăng Long', 'address': '19C Hoàng Diệu, Ba Đình, Hà Nội', 'categories': 'play', 'price': 30000});
await activitiesRefHanoi.add({'name': 'Bảo tàng Dân tộc học Việt Nam', 'address': 'Nguyễn Văn Huyên, Cầu Giấy, Hà Nội', 'categories': 'play', 'price': 40000});

// --- hotel ---
await activitiesRefHanoi.add({'name': 'Sofitel Legend Metropole Hanoi', 'address': '15 Ngô Quyền, Hoàn Kiếm, Hà Nội', 'categories': 'hotel', 'price': 5500000});
await activitiesRefHanoi.add({'name': 'Lotte Hotel Hanoi', 'address': '54 Liễu Giai, Ba Đình, Hà Nội', 'categories': 'hotel', 'price': 4000000});
await activitiesRefHanoi.add({'name': 'Apricot Hotel', 'address': '136 Hàng Trống, Hoàn Kiếm, Hà Nội', 'categories': 'hotel', 'price': 3500000});
await activitiesRefHanoi.add({'name': 'Hotel de l’Opera Hanoi', 'address': '29 Tràng Tiền, Hoàn Kiếm, Hà Nội', 'categories': 'hotel', 'price': 3200000});
await activitiesRefHanoi.add({'name': 'Pan Pacific Hanoi', 'address': '1 Thanh Niên, Ba Đình, Hà Nội', 'categories': 'hotel', 'price': 3000000});
await activitiesRefHanoi.add({'name': 'Melia Hanoi', 'address': '44B Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', 'categories': 'hotel', 'price': 2800000});
await activitiesRefHanoi.add({'name': 'Hanoi Pearl Hotel', 'address': '6 Bảo Khánh, Hoàn Kiếm, Hà Nội', 'categories': 'hotel', 'price': 2000000});
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