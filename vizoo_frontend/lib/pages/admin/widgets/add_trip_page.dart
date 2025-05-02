import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/admin/admin_timeline/admin_timeline_page.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class AddTripPage extends StatefulWidget {
  const AddTripPage({super.key});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  DateTime? _startDate;

  List<Map<String, dynamic>> _locations = [];
  String? _selectedLocationId;

  final List<Map<String, dynamic>> _durationOptions = [
    {'label': '1 ngày 1 đêm', 'so_ngay': 1},
    {'label': '2 ngày 1 đêm', 'so_ngay': 2},
    {'label': '3 ngày 2 đêm', 'so_ngay': 3},
    {'label': '4 ngày 3 đêm', 'so_ngay': 4},
    {'label': '5 ngày 4 đêm', 'so_ngay': 5},
  ];
  int? _selectedSoNgay;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocations() async {
    final snapshot = await FirebaseFirestore.instance.collection('dia_diem').get();
    setState(() {
      _locations = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['ten'] ?? 'Không tên',
        };
      }).toList();
    });
  }

  Future<void> _saveTrip() async {
  if (!_formKey.currentState!.validate() ||
      _startDate == null ||
      _selectedLocationId == null ||
      _selectedSoNgay == null) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
    );
    return;
  }

  print('✅ Bắt đầu lưu trip');

  final newTrip = {
    'anh': _imageUrlController.text,
    'chi_phi': 0,
    'danh_gia': 0,
    'love': false,
    'name': _nameController.text,
    'ngay_bat_dau': Timestamp.fromDate(_startDate!),
    'noi_o': 'chưa chọn',
    'so_act': 0,
    'so_eat': 0,
    'so_ngay': _selectedSoNgay,
    'so_nguoi': 1,
    'status': false,
  };

  final docRef = FirebaseFirestore.instance
      .collection("dia_diem")
      .doc(_selectedLocationId)
      .collection("trips")
      .doc();

  await docRef.set(newTrip);
  print('✅ Đã lưu trip');

  final timelinesRef = docRef.collection("timelines");

  for (int i = 1; i <= _selectedSoNgay!; i++) {
    await timelinesRef.add({'day_number': i});
    print('✅ Đã tạo timeline ngày $i');
  }

  if (!mounted) return;

  print('✅ Chuyển trang đến AdminTimelinePage');
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => AdminTimelinePage(
        tripId: docRef.id,
        locationId: _selectedLocationId!,
      ),
    ),
  );
  print('✅ Đã push xong'); // Sẽ không in vì pushReplacement chuyển trang luôn
}


  InputDecoration _customInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(MyColor.pr5)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(MyColor.pr5)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(MyColor.pr4), width: 2),
      ),
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(MyColor.pr3),
        title: const Text("Thêm hoạt động", style: TextStyle(color: Color(MyColor.white))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _imageUrlController,
                onChanged: (_) => setState(() {}),
                decoration: _customInput("URL ảnh (https://...)"),
                validator: (value) {
                  final url = value ?? '';
                  final isValid = Uri.tryParse(url)?.hasAbsolutePath == true &&
                      (url.endsWith('.jpg') || url.endsWith('.png') || url.endsWith('.jpeg'));
                  if (!isValid) return 'Vui lòng nhập URL ảnh hợp lệ (.jpg/.png)';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              if (_imageUrlController.text.isNotEmpty &&
                  Uri.tryParse(_imageUrlController.text)?.hasAbsolutePath == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrlController.text,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'Không tải được ảnh',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),

              DropdownButtonFormField<String>(
                decoration: _customInput("Địa điểm"),
                isExpanded: true,
                value: _selectedLocationId,
                items: _locations.map((location) {
                  return DropdownMenuItem<String>(
                    value: location['id'],
                    child: Text(location['name'], style: const TextStyle(color: Color(MyColor.pr5))),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocationId = value;
                  });
                },
                validator: (value) => value == null ? 'Chọn địa điểm' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: _customInput("Tên tour"),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                decoration: _customInput("Thời lượng tour"),
                isExpanded: true,
                value: _selectedSoNgay,
                items: _durationOptions.map((option) {
                  return DropdownMenuItem<int>(
                    value: option['so_ngay'],
                    child: Text(option['label'], style: const TextStyle(color: Color(MyColor.pr5))),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSoNgay = value),
                validator: (value) => value == null ? 'Chọn thời lượng' : null,
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(MyColor.pr3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(MyColor.pr5),
                            onPrimary: Colors.white,
                            onSurface: Color(MyColor.pr5),
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Color(MyColor.pr5),
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
                child: Text(
                  _startDate == null
                      ? "Chọn ngày bắt đầu"
                      : "Ngày: ${_startDate!.toLocal().toString().split(' ')[0]}",
                  style: const TextStyle(color: Color(MyColor.white)),
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(MyColor.pr5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _saveTrip,
                child: const Text("Lưu hoạt động", style: TextStyle(color: Color(MyColor.white))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
