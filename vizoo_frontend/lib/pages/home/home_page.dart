import 'package:flutter/material.dart';
import 'package:vizoo_frontend/apps/colors/colors.dart';
import 'package:vizoo_frontend/pages/home/widgets/home_body.dart';
import 'package:vizoo_frontend/pages/home/widgets/home_header.dart';
import 'package:vizoo_frontend/pages/home/widgets/home_hot_locations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(MyColor.white),
      body: ListView(
        children: [
          HomeHeader(),
          HomeHotLocations(),
          HomeBody(),
        ],
      ),
    );
  }
}
