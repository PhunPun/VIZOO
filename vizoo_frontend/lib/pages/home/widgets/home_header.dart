import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/pages/search/search_page.dart';  // Import SearchPage

class HomeHeader extends StatelessWidget {
  final VoidCallback onFilterTap;
  final VoidCallback onSearchTap;

  const HomeHeader({
    super.key,
    required this.onFilterTap,
    required this.onSearchTap,  // Callback cho việc nhấn vào search icon
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 14),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 98.79,
                  height: 28.26,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onSearchTap,  // Khi nhấn vào biểu tượng search, điều hướng tới SearchPage
                      child: SvgPicture.asset('assets/icons/search.svg'),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: onFilterTap,
                      child: SvgPicture.asset('assets/icons/fillter.svg'),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
