import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/pages/profile/pages/personal_info_screen.dart';
import 'package:vizoo_frontend/pages/profile/pages/completed_trip.dart'; 
import 'package:vizoo_frontend/pages/profile/pages/reviews_screen.dart';
import 'package:vizoo_frontend/pages/profile/pages/cancelled_trip.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart'; 
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CancelledTripsScreen(),
                  ),
                );
              },
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
        builder: (context) => const ReviewListView(),
      ),
    );
  },
),

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
