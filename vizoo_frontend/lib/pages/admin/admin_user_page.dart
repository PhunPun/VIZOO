import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart'; // bạn cần có file này để định nghĩa MyColor

class AdminUserPage extends StatelessWidget {
  const AdminUserPage({super.key});

  Future<void> _deleteUser(BuildContext context, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Xác nhận xóa người dùng",
              style: TextStyle(color: Color(MyColor.pr5)),
            ),
            content: Text(
              "Bạn có chắc muốn xóa người dùng này?",
              style: TextStyle(color: Color(MyColor.pr4)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Hủy"),
                style: TextButton.styleFrom(
                  foregroundColor: Color(MyColor.pr4),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Xóa"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(MyColor.pr5),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    }
  }

  Future<void> _editUserRole(
    BuildContext context,
    String userId,
    String currentRole,
  ) async {
    String? selectedRole = currentRole;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Chỉnh sửa quyền người dùng",
              style: TextStyle(color: Color(MyColor.pr5)),
            ),
            content: DropdownButtonFormField<String>(
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: 'user', child: Text('User')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                selectedRole = value;
              },
              decoration: InputDecoration(
                labelText: "Quyền",
                labelStyle: TextStyle(color: Color(MyColor.pr4)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(MyColor.pr3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(MyColor.pr5), width: 2),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
                style: TextButton.styleFrom(
                  foregroundColor: Color(MyColor.pr4),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedRole != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({'role': selectedRole});
                  }
                  Navigator.pop(context);
                },
                child: const Text("Lưu"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(MyColor.pr5),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  void _showUserOptions(
    BuildContext context,
    String userId,
    String currentRole,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.edit, color: Color(MyColor.pr5)),
                  title: const Text('Chỉnh sửa quyền'),
                  onTap: () {
                    Navigator.pop(context);
                    _editUserRole(context, userId, currentRole);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Xóa người dùng',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteUser(context, userId);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quản lý người dùng",
          style: TextStyle(color: Color(MyColor.white)),
        ),
        backgroundColor: Color(MyColor.pr5),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text("Không có người dùng nào."));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final name = data['username'] ?? 'Không tên';
              final email = data['email'] ?? 'Không email';
              final role = data['role'] ?? 'user';

              return Card(
                color: Color(MyColor.pr1),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    name,
                    style: TextStyle(
                      color: Color(MyColor.pr5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email: $email",
                        style: TextStyle(color: Color(MyColor.pr4)),
                      ),
                      Text(
                        "Quyền: $role",
                        style: TextStyle(color: Color(MyColor.pr4)),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: Color(MyColor.pr5)),
                    onPressed: () => _showUserOptions(context, userId, role),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
