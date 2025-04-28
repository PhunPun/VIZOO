import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';
import 'package:vizoo_frontend/pages/admin/admin_activity_page.dart';
import 'package:vizoo_frontend/pages/admin/admin_trip_page.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'admin_user_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String _selectedPage = 'user';

  String? _username;
  String? _photoURL;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _username = data['username'] ?? user.email;
          _photoURL = data['photoURL']?.toString().isNotEmpty == true ? data['photoURL'] : null;
        });
      }
    }
  }
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      context.goNamed(RouterName.login); // Quay về trang đăng nhập
    }
  }

  Widget getCurrentPage() {
    switch (_selectedPage) {
      case 'user':
        return const AdminUserPage();
      case 'activity':
        return const AdminActivityPage();
      case 'tour':
        return const AdminTripPage();
      default:
        return const Center(child: Text("Chọn chức năng từ menu"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_username ?? "Quản trị viên")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(MyColor.pr4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_photoURL != null)
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(_photoURL!),
                    )
                  else
                    const SizedBox(height: 30),
                  const SizedBox(height: 10),
                  Text(
                    _username ?? "Người dùng",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Quản lý người dùng'),
              onTap: () {
                setState(() => _selectedPage = 'user');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Quản lý hoạt động'),
              onTap: () {
                setState(() => _selectedPage = 'activity');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Quản lý tour'),
              onTap: () {
                setState(() => _selectedPage = 'tour');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: getCurrentPage(),
    );
  }
}
