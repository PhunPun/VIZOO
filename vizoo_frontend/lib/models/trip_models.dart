import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Trips {
  final String id;
  final String moTa;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final int soNgay;
  final int soNguoi;
  final String ten;
  final String hinh_anh;
  final int chi_phi;

  Trips({
    required this.id,
    required this.moTa,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.soNgay,
    required this.soNguoi,
    required this.ten,
    required this.hinh_anh,
    required this.chi_phi,
  });

  factory Trips.fromFirestore(Map<String, dynamic> data, String id) {
    return Trips(
      id: id,
      moTa: data['mo_ta'] ?? '',
      ngayBatDau: data['ngay_bat_dau'] != null
          ? (data['ngay_bat_dau'] as Timestamp).toDate()
          : DateTime.now(),
      ngayKetThuc: data['ngay_ket_thuc'] != null
          ? (data['ngay_ket_thuc'] as Timestamp).toDate()
          : DateTime.now(),
      soNgay: data['so_ngay'] ?? 0,
      soNguoi: data['so_nguoi'] ?? 0,
      ten: data['ten'] ?? '',
      hinh_anh: data['hinh_anh'] ?? '',
      chi_phi: data['chi_phi'] ?? '',
    );
  }
}