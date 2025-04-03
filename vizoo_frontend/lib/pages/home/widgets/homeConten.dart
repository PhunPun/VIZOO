import 'package:flutter/material.dart';
import 'package:vizoo_frontend/apps/colors/colors.dart';
import 'package:vizoo_frontend/pages/home/widgets/home_body.dart';
import 'package:vizoo_frontend/pages/home/widgets/home_header.dart';
import 'package:vizoo_frontend/pages/home/widgets/home_hot_locations.dart';

class Homeconten extends StatefulWidget {
  const Homeconten({super.key});

  @override
  State<Homeconten> createState() => _HomecontenState();
}

class _HomecontenState extends State<Homeconten> {
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