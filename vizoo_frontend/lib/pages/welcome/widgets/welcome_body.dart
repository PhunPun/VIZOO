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
      .doc("6cHdpF1FDYcERqUEvzCz")
      .collection('activities');

  // --- eat ---
  await activitiesRef.add({'name': 'Bún bò Huế', 'address': '45 Lê Lợi, Đà Nẵng', 'categories': 'eat', 'price': 35000});
  await activitiesRef.add({'name': 'Mì Quảng', 'address': '23 Nguyễn Văn Linh, Đà Nẵng', 'categories': 'eat', 'price': 30000});
  await activitiesRef.add({'name': 'Bánh tráng thịt heo', 'address': '12 Nguyễn Tri Phương, Đà Nẵng', 'categories': 'eat', 'price': 45000});
  await activitiesRef.add({'name': 'Cao lầu Hội An', 'address': '101 Trần Phú, Đà Nẵng', 'categories': 'eat', 'price': 40000});
  await activitiesRef.add({'name': 'Gỏi cuốn', 'address': '17 Phan Đình Phùng, Đà Nẵng', 'categories': 'eat', 'price': 25000});
  await activitiesRef.add({'name': 'Bánh xèo', 'address': '66 Lê Duẩn, Đà Nẵng', 'categories': 'eat', 'price': 30000});
  await activitiesRef.add({'name': 'Nem lụi', 'address': '19 Hoàng Diệu, Đà Nẵng', 'categories': 'eat', 'price': 35000});
  await activitiesRef.add({'name': 'Bún mắm nêm', 'address': '88 Nguyễn Chí Thanh, Đà Nẵng', 'categories': 'eat', 'price': 25000});
  await activitiesRef.add({'name': 'Chè sầu', 'address': '55 Hải Phòng, Đà Nẵng', 'categories': 'eat', 'price': 20000});
  await activitiesRef.add({'name': 'Cơm gà', 'address': '31 Pasteur, Đà Nẵng', 'categories': 'eat', 'price': 40000});

  // --- drink ---
  await activitiesRef.add({'name': 'Cà phê Highlands', 'address': '10 Bạch Đằng, Đà Nẵng', 'categories': 'drink', 'price': 55000});
  await activitiesRef.add({'name': 'Trà sữa Tocotoco', 'address': '78 Phan Châu Trinh, Đà Nẵng', 'categories': 'drink', 'price': 50000});
  await activitiesRef.add({'name': 'Gong Cha', 'address': '99 Nguyễn Văn Linh, Đà Nẵng', 'categories': 'drink', 'price': 52000});
  await activitiesRef.add({'name': 'Cộng Cà Phê', 'address': '34 Lê Lợi, Đà Nẵng', 'categories': 'drink', 'price': 50000});
  await activitiesRef.add({'name': 'Memory Lounge', 'address': '32 Bạch Đằng, Đà Nẵng', 'categories': 'drink', 'price': 60000});
  await activitiesRef.add({'name': 'The Coffee House', 'address': '56 Nguyễn Tri Phương, Đà Nẵng', 'categories': 'drink', 'price': 45000});
  await activitiesRef.add({'name': 'Phúc Long', 'address': '80 Lê Duẩn, Đà Nẵng', 'categories': 'drink', 'price': 55000});
  await activitiesRef.add({'name': 'Urban Station', 'address': '22 Hoàng Diệu, Đà Nẵng', 'categories': 'drink', 'price': 40000});
  await activitiesRef.add({'name': 'Guta Cafe', 'address': '105 Trần Phú, Đà Nẵng', 'categories': 'drink', 'price': 35000});
  await activitiesRef.add({'name': 'Zone 7 Cafe', 'address': '07 Nguyễn Chí Thanh, Đà Nẵng', 'categories': 'drink', 'price': 45000});

  // --- play ---
  await activitiesRef.add({'name': 'Tắm biển Mỹ Khê', 'address': 'Bãi biển Mỹ Khê, Đà Nẵng', 'categories': 'play', 'price': 0});
  await activitiesRef.add({'name': 'Leo núi Ngũ Hành Sơn', 'address': 'Quận Ngũ Hành Sơn, Đà Nẵng', 'categories': 'play', 'price': 20000});
  await activitiesRef.add({'name': 'Du thuyền sông Hàn', 'address': 'Bến sông Hàn, Đà Nẵng', 'categories': 'play', 'price': 100000});
  await activitiesRef.add({'name': 'Asia Park', 'address': '01 Phan Đăng Lưu, Đà Nẵng', 'categories': 'play', 'price': 200000});
  await activitiesRef.add({'name': 'Bảo tàng Chăm', 'address': '02 Trưng Nữ Vương, Đà Nẵng', 'categories': 'play', 'price': 40000});
  await activitiesRef.add({'name': 'Công viên Biển Đông', 'address': 'Võ Nguyên Giáp, Đà Nẵng', 'categories': 'play', 'price': 0});
  await activitiesRef.add({'name': 'Sun Wheel', 'address': 'Asia Park, Đà Nẵng', 'categories': 'play', 'price': 150000});
  await activitiesRef.add({'name': 'Cầu Rồng phun lửa', 'address': 'Cầu Rồng, Đà Nẵng', 'categories': 'play', 'price': 0});
  await activitiesRef.add({'name': 'Ngắm bán đảo Sơn Trà', 'address': 'Sơn Trà, Đà Nẵng', 'categories': 'play', 'price': 0});
  await activitiesRef.add({'name': 'Làng đá Non Nước', 'address': 'Ngũ Hành Sơn, Đà Nẵng', 'categories': 'play', 'price': 30000});

  // --- hotel ---
  await activitiesRef.add({'name': 'Khách sạn Novotel', 'address': '36 Bạch Đằng, Đà Nẵng', 'categories': 'hotel', 'price': 1200000});
  await activitiesRef.add({'name': 'Mường Thanh Luxury', 'address': '270 Võ Nguyên Giáp, Đà Nẵng', 'categories': 'hotel', 'price': 900000});
  await activitiesRef.add({'name': 'Furama Resort', 'address': 'Võ Nguyên Giáp, Đà Nẵng', 'categories': 'hotel', 'price': 2500000});
  await activitiesRef.add({'name': 'Golden Bay', 'address': 'Lê Văn Duyệt, Đà Nẵng', 'categories': 'hotel', 'price': 1600000});
  await activitiesRef.add({'name': 'Vanda Hotel', 'address': '03 Nguyễn Văn Linh, Đà Nẵng', 'categories': 'hotel', 'price': 850000});
  await activitiesRef.add({'name': 'Minh Toàn Galaxy', 'address': '306 2/9, Đà Nẵng', 'categories': 'hotel', 'price': 950000});
  await activitiesRef.add({'name': 'Sala Danang Beach', 'address': '36 Lâm Hoành, Đà Nẵng', 'categories': 'hotel', 'price': 1100000});
  await activitiesRef.add({'name': 'A La Carte Hotel', 'address': '200 Võ Nguyên Giáp, Đà Nẵng', 'categories': 'hotel', 'price': 1300000});
  await activitiesRef.add({'name': 'Serene Beach Hotel', 'address': '274 Võ Nguyên Giáp, Đà Nẵng', 'categories': 'hotel', 'price': 800000});
  await activitiesRef.add({'name': 'Grand Tourane Hotel', 'address': '252 Võ Nguyên Giáp, Đà Nẵng', 'categories': 'hotel', 'price': 1000000});
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
      .doc("6cHdpF1FDYcERqUEvzCz")
      .collection("trips");

  final List<Map<String, dynamic>> daNangTrips = [
    {
      'anh': 'https://i.pinimg.com/736x/00/a3/7f/00a37fd9c7479911e36ba748d139e425.jpg',
      'chi_phi': 1500000,
      'danh_gia': 4,
      'love': false,
      'name': 'Du lịch Đà Nẵng',
      'ngay_bat_dau': '18/04/2024',
      'noi_o': 'Nhà nghỉ An Bình',
      'so_act': 15,
      'so_eat': 9,
      'so_ngay': 3,
      'so_nguoi': 1,
    },
    {
      'anh': 'https://i.pinimg.com/736x/aa/64/23/aa6423a37266eed99f8dffecfa8eef84.jpg',
      'chi_phi': 2200000,
      'danh_gia': 5,
      'love': true,
      'name': 'Khám phá Đà Nẵng',
      'ngay_bat_dau': '20/05/2024',
      'noi_o': 'Khách sạn Hương Biển',
      'so_act': 12,
      'so_eat': 7,
      'so_ngay': 2,
      'so_nguoi': 2,
    },
    {
      'anh': 'https://i.pinimg.com/736x/41/85/b6/4185b62acb34fc7ffae350e31256e424.jpg',
      'chi_phi': 3000000,
      'danh_gia': 3,
      'love': false,
      'name': 'Trải nghiệm Đà Nẵng',
      'ngay_bat_dau': '05/06/2024',
      'noi_o': 'Resort Biển Xanh',
      'so_act': 10,
      'so_eat': 6,
      'so_ngay': 4,
      'so_nguoi': 3,
    },
    {
      'anh': 'https://i.pinimg.com/736x/7d/54/e2/7d54e239d8c77eb6a9b81785ef5b3889.jpg',
      'chi_phi': 2700000,
      'danh_gia': 4,
      'love': true,
      'name': 'Food tour Đà Nẵng',
      'ngay_bat_dau': '15/06/2024',
      'noi_o': 'Khách sạn Sunlight',
      'so_act': 9,
      'so_eat': 9,
      'so_ngay': 2,
      'so_nguoi': 2,
    },
    {
      'anh': 'https://i.pinimg.com/736x/cf/d6/91/cfd691aae696bc98bcf413bb92f8363a.jpg',
      'chi_phi': 1800000,
      'danh_gia': 5,
      'love': false,
      'name': 'Tham quan Đà Nẵng',
      'ngay_bat_dau': '01/07/2024',
      'noi_o': 'Homestay Đà Nẵng Xanh',
      'so_act': 11,
      'so_eat': 8,
      'so_ngay': 3,
      'so_nguoi': 1,
    },
  ];

  for (var trip in daNangTrips) {
    await tripRef.add(trip);
  }

  print("✅ Đã thêm danh sách trips tại Đà Nẵng thành công!");
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