import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/pages/profile/widgets/personal_info_screen.dart';
import 'package:vizoo_frontend/pages/profile/widgets/completed_trip.dart';
import 'package:vizoo_frontend/pages/profile/widgets/reviews_screen.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(MyColor.white),
        elevation: 0,
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/logo.svg',
              width: 98.79,
              height: 28.26,
            )
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Icon(
              Icons.settings,
              color: Colors.black,
              size: 28,
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildProfileOption(
              context: context,
              icon: Image.asset('assets/images/information.png'),
              title: 'Thông tin cá nhân',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalInfoScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
              context: context,
              icon: Image.asset('assets/images/trip_complete.png'),
              title: 'Lịch trình đã hoàn thành',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompletedTripsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
              context: context,
              icon: Image.asset('assets/images/trip_false.png'),
              title: 'Lịch trình đã hủy',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
              context: context,
              icon: Image.asset('assets/images/complain.png'),
              title: 'Đánh giá',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReviewsScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(MyColor.pr5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.goNamed(RouterName.login);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE4C59E),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 16),
            icon,
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Roboto',
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
