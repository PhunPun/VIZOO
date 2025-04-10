import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/home/widgets/homeConten.dart';
import 'package:vizoo_frontend/pages/love/love_page.dart';
import 'package:vizoo_frontend/pages/profile/profile.dart';
import 'package:vizoo_frontend/pages/your_trip/your_trip_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final Map<int, ScrollController> _scrollControllers = {};
  bool _isBottomBarVisible = true;

  // Danh sách các tab
  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Image(
        image: AssetImage('assets/images/home.png'),
        width: 24,
        height: 24,
      ),
      activeIcon: Image(
        image: AssetImage('assets/images/homeTap.png'),
        width: 24,
        height: 24,
      ),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Image(
        image: AssetImage('assets/images/yourTrip.png'),
        width: 24,
        height: 24,
      ),
      activeIcon: Image(
        image: AssetImage('assets/images/yourTripTap.png'),
        width: 24,
        height: 24,
      ),
      label: 'Your trip',
    ),
    BottomNavigationBarItem(
      icon: Image(
        image: AssetImage('assets/images/love.png'),
        width: 24,
        height: 24,
      ),
      activeIcon: Image(
        image: AssetImage('assets/images/loveTap.png'),
        width: 24,
        height: 24,
      ),
      label: 'Love',
    ),
    BottomNavigationBarItem(
      icon: Image(
        image: AssetImage('assets/images/profile.png'),
        width: 24,
        height: 24,
      ),
      activeIcon: Image(
        image: AssetImage('assets/images/profileTap.png'),
        width: 24,
        height: 24,
      ),
      label: 'Profile',
    ),
  ];

  // Danh sách các trang tương ứng
  final List<Widget> _pages = [
    const Homeconten(),
    const YourTripPage(),
    const LovePage(),
    const ProfileScreen()
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Initialize scroll controllers for each page
    for (int i = 0; i < _pages.length; i++) {
      _scrollControllers[i] = ScrollController();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Reset bottom bar visibility when changing tabs
      _isBottomBarVisible = true;
      _animationController.reverse();
    });
  }

  void _handleScroll(int index) {
    final controller = _scrollControllers[index];
    if (controller != null && controller.hasClients) {
      final offset = controller.offset;
      final scrollDirection = controller.position.userScrollDirection;
      
      if (scrollDirection == ScrollDirection.forward) {
        // Scrolling up - show bottom bar
        if (!_isBottomBarVisible) {
          setState(() {
            _isBottomBarVisible = true;
          });
          _animationController.reverse();
        }
      } else if (scrollDirection == ScrollDirection.reverse) {
        // Scrolling down - hide bottom bar
        if (_isBottomBarVisible && offset > 100) {
          setState(() {
            _isBottomBarVisible = false;
          });
          _animationController.forward();
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildPageWithScroll(int index, Widget page) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          _handleScroll(index);
        }
        return false;
      },
      child: PrimaryScrollController(
        controller: _scrollControllers[index]!,
        child: page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Color(MyColor.white),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            for (int i = 0; i < _pages.length; i++)
              _buildPageWithScroll(i, _pages[i]),
          ],
        ),
        bottomNavigationBar: _isBottomBarVisible ? _buildBottomNavBar() : null,
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Color(MyColor.pr3),
      items: _bottomNavItems,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(MyColor.pr5),
      unselectedItemColor: Color(MyColor.white),
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }
}