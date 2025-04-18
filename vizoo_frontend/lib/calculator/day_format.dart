String dayFormat(int so_ngay) {
  String dayFormat;
  if (so_ngay == 1) {
    dayFormat = '1 ngày 1 đêm';
  } else {
    dayFormat = '$so_ngay ngày ${so_ngay - 1} đêm';
  }
  return dayFormat;
}
