import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/search/search_page.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/pages/home/widgets/home_body.dart';
import 'package:vizoo_frontend/pages/home/widgets/home_header.dart';
import 'package:vizoo_frontend/pages/home/widgets/home_hot_locations.dart';
import 'package:vizoo_frontend/widgets/filter_drawer.dart';

class Homeconten extends StatefulWidget {
  const Homeconten({super.key});

  @override
  State<Homeconten> createState() => _HomecontenState();
}

class _HomecontenState extends State<Homeconten> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> _filters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: FilterDrawer(
        initialFilters: _filters,
        onApply: (filters) {
          setState(() {
            _filters = filters;
          });
        },
      ),
      backgroundColor: Color(MyColor.white),
      body: ListView(
        children: [
          HomeHeader(
            onFilterTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            onSearchTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          HomeHotLocations(
            onLocationSelected: (idDiaDiem) {
              setState(() {
                _filters['id_dia_diem'] = idDiaDiem;
              });
            },
          ),
          HomeBody(filters: _filters),
        ],
      ),
    );
  }
}
