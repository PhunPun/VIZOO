import 'package:flutter/material.dart';

class TimelineModel {
  final TimeOfDay time;
  final String activities;
  final String address;
  final int price;
  final bool completed;
  TimelineModel({
    required this.time,
    required this.activities,
    required this.address,
    required this.price,
    required this.completed
  });

  static Map<int, List<TimelineModel>> getAllTimelinesByDay() {
    return {
      1: [
        TimelineModel(
          time: TimeOfDay(hour: 7, minute: 30),
          activities: 'Ăn sáng',
          address: '123 Bình Thạnh',
          price: 30000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 9, minute: 0),
          activities: 'Tham quan Bạch Đằng',
          address: 'Bến Bạch Đằng, Quận 1',
          price: 0,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 12, minute: 15),
          activities: 'Ăn trưa',
          address: '45 Pasteur, Quận 1',
          price: 55000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 14, minute: 0),
          activities: 'Uống cà phê',
          address: 'Highlands Coffee, Lê Lợi',
          price: 45000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 16, minute: 30),
          activities: 'Tham quan Landmark 81',
          address: 'Vinhomes Central Park',
          price: 100000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 19, minute: 0),
          activities: 'Ăn tối',
          address: 'Sorae Sushi, Bitexco',
          price: 200000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 21, minute: 0),
          activities: 'Dạo phố đi bộ',
          address: 'Nguyễn Huệ, Quận 1',
          price: 0,
          completed: false
        ),
      ],
      2: [
        TimelineModel(
          time: TimeOfDay(hour: 8, minute: 0),
          activities: 'Đi chợ Bến Thành',
          address: 'Chợ Bến Thành, Quận 1',
          price: 150000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 10, minute: 0),
          activities: 'Tham quan Dinh Độc Lập',
          address: '135 Nam Kỳ Khởi Nghĩa',
          price: 40000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 12, minute: 30),
          activities: 'Ăn trưa tại nhà hàng',
          address: 'Nhà hàng Ngon 138, Quận 1',
          price: 90000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 15, minute: 0),
          activities: 'Tham quan Nhà thờ Đức Bà',
          address: '1 Công Xã Paris, Quận 1',
          price: 0,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 17, minute: 0),
          activities: 'Mua sắm tại Takashimaya',
          address: '92-94 Nam Kỳ Khởi Nghĩa',
          price: 500000,
          completed: false
        ),
      ],
      3: [
        TimelineModel(
          time: TimeOfDay(hour: 7, minute: 0),
          activities: 'Ăn sáng nhẹ',
          address: 'Tiệm bánh ABC, Quận 3',
          price: 25000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 9, minute: 0),
          activities: 'Tham quan Thảo Cầm Viên',
          address: '2 Nguyễn Bỉnh Khiêm, Quận 1',
          price: 50000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 11, minute: 30),
          activities: 'Trả phòng khách sạn',
          address: 'Vinpearl Landmark 81',
          price: 0,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 13, minute: 0),
          activities: 'Ăn trưa cuối chuyến',
          address: 'Cơm Niêu Sài Gòn',
          price: 120000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 15, minute: 0),
          activities: 'Ra sân bay',
          address: 'Tân Sơn Nhất',
          price: 100000,
          completed: false
        ),
      ],
      4: [
        TimelineModel(
          time: TimeOfDay(hour: 7, minute: 30),
          activities: 'Ăn sáng',
          address: '123 Bình Thạnh',
          price: 30000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 9, minute: 0),
          activities: 'Tham quan Bạch Đằng',
          address: 'Bến Bạch Đằng, Quận 1',
          price: 0,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 12, minute: 15),
          activities: 'Ăn trưa',
          address: '45 Pasteur, Quận 1',
          price: 55000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 14, minute: 0),
          activities: 'Uống cà phê',
          address: 'Highlands Coffee, Lê Lợi',
          price: 45000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 16, minute: 30),
          activities: 'Tham quan Landmark 81',
          address: 'Vinhomes Central Park',
          price: 100000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 19, minute: 0),
          activities: 'Ăn tối',
          address: 'Sorae Sushi, Bitexco',
          price: 200000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 21, minute: 0),
          activities: 'Dạo phố đi bộ',
          address: 'Nguyễn Huệ, Quận 1',
          price: 0,
          completed: false
        ),
      ],
      5: [
        TimelineModel(
          time: TimeOfDay(hour: 8, minute: 0),
          activities: 'Đi chợ Bến Thành',
          address: 'Chợ Bến Thành, Quận 1',
          price: 150000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 10, minute: 0),
          activities: 'Tham quan Dinh Độc Lập',
          address: '135 Nam Kỳ Khởi Nghĩa',
          price: 40000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 12, minute: 30),
          activities: 'Ăn trưa tại nhà hàng',
          address: 'Nhà hàng Ngon 138, Quận 1',
          price: 90000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 15, minute: 0),
          activities: 'Tham quan Nhà thờ Đức Bà',
          address: '1 Công Xã Paris, Quận 1',
          price: 0,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 17, minute: 0),
          activities: 'Mua sắm tại Takashimaya',
          address: '92-94 Nam Kỳ Khởi Nghĩa',
          price: 500000,
          completed: false
        ),
      ],
      6: [
        TimelineModel(
          time: TimeOfDay(hour: 7, minute: 0),
          activities: 'Ăn sáng nhẹ',
          address: 'Tiệm bánh ABC, Quận 3',
          price: 25000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 9, minute: 0),
          activities: 'Tham quan Thảo Cầm Viên',
          address: '2 Nguyễn Bỉnh Khiêm, Quận 1',
          price: 50000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 11, minute: 30),
          activities: 'Trả phòng khách sạn',
          address: 'Vinpearl Landmark 81',
          price: 0,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 13, minute: 0),
          activities: 'Ăn trưa cuối chuyến',
          address: 'Cơm Niêu Sài Gòn',
          price: 120000,
          completed: false
        ),
        TimelineModel(
          time: TimeOfDay(hour: 15, minute: 0),
          activities: 'Ra sân bay',
          address: 'Tân Sơn Nhất',
          price: 100000,
          completed: false
        ),
      ]
    };
  }
}
