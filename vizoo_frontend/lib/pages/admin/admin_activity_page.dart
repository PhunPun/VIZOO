import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class AdminActivityPage extends StatefulWidget {
  const AdminActivityPage({super.key});

  @override
  State<AdminActivityPage> createState() => _AdminActivityPageState();
}

class _AdminActivityPageState extends State<AdminActivityPage> {
  String? _selectedLocationId;
  String? _selectedLocationName;

  final _formKey = GlobalKey<FormState>();
  String? _name, _address, _categories;
  int? _price;

  List<String> _categoriesFromFirestore = [];
  bool _isLoadingCategories = true;
  String? _selectedFilterCategory;

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromFirestore();
  }

  Future<void> _loadCategoriesFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('loai').get();
    setState(() {
      _categoriesFromFirestore = snapshot.docs
          .map((doc) => (doc.data()['name'] as String))
          .toList();
      _isLoadingCategories = false;
    });
  }

  Future<void> _addNewCategoryToFirestore(Function(String) onCategoryAdded) async {
    String? newCategory;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(MyColor.pr1),
        title: const Text("Thêm loại hoạt động mới"),
        content: TextFormField(
          decoration: const InputDecoration(labelText: "Tên loại"),
          onChanged: (value) => newCategory = value.trim(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Color(MyColor.pr5)),)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(MyColor.pr4)),
            onPressed: () async {
              if (newCategory != null &&
                  newCategory!.isNotEmpty &&
                  !_categoriesFromFirestore.contains(newCategory)) {
                await FirebaseFirestore.instance.collection('loai').add({'name': newCategory});
                Navigator.pop(context);
                await _loadCategoriesFromFirestore();
                onCategoryAdded(newCategory!);
              }
            },
            child: const Text("Thêm", style: TextStyle(color: Color(MyColor.white)),),
          ),
        ],
      ),
    );
  }

  Future<void> _addActivity() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance
          .collection('dia_diem')
          .doc(_selectedLocationId)
          .collection('activities')
          .add({
        'name': _name,
        'address': _address,
        'categories': _categories,
        'price': _price,
      });
      Navigator.pop(context);
      setState(() {});
    }
  }

  Future<void> _editActivity(String docId, Map<String, dynamic> data) async {
    final editFormKey = GlobalKey<FormState>();
    String? name = data['name'];
    String? address = data['address'];
    String? categories = data['categories'];
    int? price = data['price'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(MyColor.pr1),
        title: const Text("Sửa hoạt động"),
        content: Form(
          key: editFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Tên'),
                  onSaved: (value) => name = value,
                  validator: (value) => value!.isEmpty ? 'Nhập tên' : null,
                ),
                TextFormField(
                  initialValue: address,
                  decoration: const InputDecoration(labelText: 'Địa chỉ'),
                  onSaved: (value) => address = value,
                  validator: (value) => value!.isEmpty ? 'Nhập địa chỉ' : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Loại'),
                  value: _categoriesFromFirestore.contains(categories) ? categories : null,
                  items: [
                    ..._categoriesFromFirestore.map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    ),
                    const DropdownMenuItem(
                      value: 'add_new',
                      child: Text("➕ Tạo loại mới"),
                    )
                  ],
                  onChanged: (value) {
                    if (value == 'add_new') {
                      _addNewCategoryToFirestore((newCat) {
                        setState(() {
                          categories = newCat;
                        });
                      });
                    } else {
                      categories = value;
                    }
                  },
                  validator: (value) =>
                      value == null || value == 'add_new' ? 'Chọn loại' : null,
                ),
                TextFormField(
                  initialValue: price.toString(),
                  decoration: const InputDecoration(labelText: 'Giá'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => price = int.tryParse(value!),
                  validator: (value) => value!.isEmpty ? 'Nhập giá' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Color(MyColor.pr5)),)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(MyColor.pr4)),
            onPressed: () async {
              if (editFormKey.currentState!.validate()) {
                editFormKey.currentState!.save();
                await FirebaseFirestore.instance
                    .collection('dia_diem')
                    .doc(_selectedLocationId)
                    .collection('activities')
                    .doc(docId)
                    .update({
                  'name': name,
                  'address': address,
                  'categories': categories,
                  'price': price,
                });
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text("Lưu", style: TextStyle(color: Color(MyColor.white)),),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteActivity(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(MyColor.pr2),
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa hoạt động này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy", style: TextStyle(color: Color(MyColor.pr5)),)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(MyColor.pr5)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa", style: TextStyle(color: Color(MyColor.white)),),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('dia_diem')
          .doc(_selectedLocationId)
          .collection('activities')
          .doc(docId)
          .delete();
      setState(() {});
    }
  }

  void _showActivityOptions(BuildContext context, String docId, Map<String, dynamic> data) {
    showModalBottomSheet(
      backgroundColor: Color(MyColor.pr2),
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Sửa hoạt động'),
              onTap: () {
                Navigator.pop(context);
                _editActivity(docId, data);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa hoạt động', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteActivity(docId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(MyColor.pr1),
        title: Text("Thêm hoạt động cho $_selectedLocationName"),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tên'),
                  onSaved: (value) => _name = value,
                  validator: (value) => value!.isEmpty ? 'Nhập tên' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Địa chỉ'),
                  onSaved: (value) => _address = value,
                  validator: (value) => value!.isEmpty ? 'Nhập địa chỉ' : null,
                ),
                _isLoadingCategories
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Loại'),
                        value: _categoriesFromFirestore.contains(_categories) ? _categories : null,
                        items: [
                          ..._categoriesFromFirestore.map(
                            (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                          ),
                          const DropdownMenuItem(
                            value: 'add_new',
                            child: Text("➕ Tạo loại mới"),
                          )
                        ],
                        onChanged: (value) {
                          if (value == 'add_new') {
                            _addNewCategoryToFirestore((newCat) {
                              setState(() {
                                _categories = newCat;
                              });
                            });
                          } else {
                            setState(() {
                              _categories = value;
                            });
                          }
                        },
                        validator: (value) =>
                            value == null || value == 'add_new' ? 'Chọn loại' : null,
                      ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Giá'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _price = int.tryParse(value!),
                  validator: (value) => value!.isEmpty ? 'Nhập giá' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Color(MyColor.pr5)),)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(MyColor.pr3)),
            onPressed: _addActivity,
            child: const Text("Thêm", style: TextStyle(color: Color(MyColor.white)),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý hoạt động", style: TextStyle(color: Color(MyColor.white)),),
        backgroundColor: Color(MyColor.pr5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('dia_diem').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final locations = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Chọn địa điểm",
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(MyColor.pr3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(MyColor.pr5), width: 2),
                ),
                  ),
                  value: _selectedLocationId,
                  items: locations.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['ten'] ?? 'Không tên';
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocationId = value;
                      _selectedLocationName = locations
                          .firstWhere((doc) => doc.id == value!)
                          .get('ten');
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Lọc theo loại hoạt động",
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(MyColor.pr3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(MyColor.pr5), width: 2),
                ),
              ),
              value: _selectedFilterCategory,
              items: [
                const DropdownMenuItem(value: null, child: Text("Tất cả")),
                ..._categoriesFromFirestore.map(
                  (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                )
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilterCategory = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _selectedLocationId == null
                  ? const Center(child: Text("Vui lòng chọn địa điểm"))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('dia_diem')
                          .doc(_selectedLocationId)
                          .collection('activities')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();

                        final allDocs = snapshot.data!.docs;
                        final filteredDocs = _selectedFilterCategory == null
                            ? allDocs
                            : allDocs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return data['categories'] == _selectedFilterCategory;
                              }).toList();

                        if (filteredDocs.isEmpty) {
                          return const Center(child: Text("Không có hoạt động phù hợp"));
                        }

                        return ListView.builder(
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final data =
                                filteredDocs[index].data() as Map<String, dynamic>;
                            final docId = filteredDocs[index].id;
                            return Card(
                              color: Color(MyColor.pr5),
                              child: ListTile(
                                tileColor: Color(MyColor.pr1),
                                title: Text(data['name'] ?? '', style: TextStyle(color: Color(MyColor.pr5))),
                                subtitle: Text('${data['address']}\n• ${data['categories']}'),
                                trailing: IconButton(
                                  icon: Icon(Icons.more_vert, color: Color(MyColor.pr5)),
                                  onPressed: () => _showActivityOptions(context, docId, data),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedLocationId != null
          ? FloatingActionButton.extended(
              backgroundColor: Color(MyColor.pr3),
              onPressed: _showAddDialog,
              label: const Text("Thêm hoạt động", style: TextStyle(color: Color(MyColor.pr5)),),
              icon: const Icon(Icons.add, color: Color(MyColor.pr5),),
            )
          : null,
    );
  }
}
