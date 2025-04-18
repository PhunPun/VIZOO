import 'package:cloud_firestore/cloud_firestore.dart';

class Trips {
  final String id;
  final String anh;
  final int chiPhi;
  final int danhGia;
  final bool love;
  final String name;
  final String ngayBatDau;
  final String noiO;
  final int soAct;
  final int soEat;
  final int soNgay;
  final int soNguoi;

  Trips({
    required this.id,
    required this.anh,
    required this.chiPhi,
    required this.danhGia,
    required this.love,
    required this.name,
    required this.ngayBatDau,
    required this.noiO,
    required this.soAct,
    required this.soEat,
    required this.soNgay,
    required this.soNguoi,
  });

  factory Trips.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String ngayBatDauStr = '';
  if (data['ngay_bat_dau'] is Timestamp) {
    final DateTime ngay = (data['ngay_bat_dau'] as Timestamp).toDate();
    ngayBatDauStr = '${ngay.day.toString().padLeft(2, '0')}/${ngay.month.toString().padLeft(2, '0')}/${ngay.year}';
  } else if (data['ngay_bat_dau'] is String) {
    ngayBatDauStr = data['ngay_bat_dau'];
  }
    return Trips(
      id: doc.id,
      anh: data['anh'] ?? '',
      chiPhi: data['chi_phi'] ?? 0,
      danhGia: data['danh_gia'] ?? 0,
      love: data['love'] ?? false,
      name: data['name'] ?? '',
      ngayBatDau: ngayBatDauStr,
      noiO: data['noi_o'] ?? '',
      soAct: data['so_act'] ?? 0,
      soEat: data['so_eat'] ?? 0,
      soNgay: data['so_ngay'] ?? 0,
      soNguoi: data['so_nguoi'] ?? 0,
    );
  }
}
