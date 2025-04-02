import 'package:flutter/material.dart';
import 'personal_info_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
          Image.asset(
            'assets/icons/logo.svg', 
            height: 30,
            width:30, 
          ),
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
              icon: Icons.person,
              title: 'Thông tin cá nhân',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
              context: context,
              icon: Icons.check_circle_outline,
              title: 'Lịch trình đã hoàn thành',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
              context: context,
              icon: Icons.cancel_outlined,
              title: 'Lịch trình đã hủy',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
              context: context,
              icon: Icons.star_border,
              title: 'Đánh giá',
              onTap: () {},
            ),
            const Spacer(),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
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
            Icon(
              icon,
              size: 25,
              color: Colors.black.withOpacity(0.7),
            ),
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
  
  Widget _buildBottomNavBar() {
    return Container(
      height: 58,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE4C59E),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home, label: 'Home', isSelected: false),
          _buildNavItem(icon: Icons.map, label: 'Your trip', isSelected: false),
          _buildNavItem(icon: Icons.favorite_border, label: 'Love', isSelected: false),
          _buildNavItem(icon: Icons.person, label: 'Profile', isSelected: true),
        ],
      ),
    );
  }
  
  Widget _buildNavItem({
    required IconData icon, 
    required String label, 
    required bool isSelected
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF803D3B) : Colors.white,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF803D3B) : Colors.white,
            fontSize: 12,
            fontFamily: 'Inter',
            letterSpacing: -0.24,
          ),
        ),
      ],
    );
  }
}