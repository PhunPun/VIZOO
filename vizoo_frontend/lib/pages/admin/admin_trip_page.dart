import 'package:flutter/material.dart';
import 'package:vizoo_frontend/pages/admin/widgets/add_trip_page.dart';
import 'package:vizoo_frontend/pages/admin/widgets/admin_trip_body.dart';
import 'package:vizoo_frontend/pages/home/widgets/home_header.dart';
import 'package:vizoo_frontend/pages/home/widgets/home_hot_locations.dart';
import 'package:vizoo_frontend/pages/search/search_page.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/filter_drawer.dart';

class AdminTripPage extends StatefulWidget {
  const AdminTripPage({super.key});

  @override
  State<AdminTripPage> createState() => _AdminTripPageState();
}

class _AdminTripPageState extends State<AdminTripPage> {
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
          AdminTripBody(filters: _filters),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(MyColor.pr3),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTripPage()),
          );
          if (result == true) {
            setState(() {}); // cập nhật lại danh sách sau khi thêm
          }
        },
        label: const Text(
          "Thêm hoạt động",
          style: TextStyle(color: Color(MyColor.pr5)),
        ),
        icon: const Icon(Icons.add, color: Color(MyColor.pr5)),
      ),
    );
  }
}
