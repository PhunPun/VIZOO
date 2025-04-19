import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vizoo_frontend/models/trip_models_json.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:vizoo_frontend/widgets/trip_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Trip> _searchResults = [];
  List<String> _suggestions = [];

  Future<void> _fetchSuggestions() async {
    final snapshot = await FirebaseFirestore.instance.collection('dia_diem').get();
    final suggestions = snapshot.docs.map((doc) => doc['ten'] as String).toList();

    setState(() {
      _suggestions = suggestions;
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final diaDiemRef = FirebaseFirestore.instance.collection('dia_diem');
      final diaDiemSnapshot = await diaDiemRef.get();

      List<Trip> results = [];

      for (var diaDiemDoc in diaDiemSnapshot.docs) {
        final tripSnapshot = await diaDiemRef
            .doc(diaDiemDoc.id)
            .collection('trips')
            .get();

        for (var tripDoc in tripSnapshot.docs) {
          final data = tripDoc.data();
          final name = data['name'] ?? '';

          if ((name as String).toLowerCase().contains(query.toLowerCase())) {
            results.add(Trip.fromJson(
              data,
              id: tripDoc.id,
              locationId: diaDiemDoc.id,
            ));
          }
        }
      }

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Lỗi tìm kiếm: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nhập từ khóa tìm kiếm...',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(MyColor.pr5)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _performSearch(_searchController.text);
                  },
                ),
              ),
              onChanged: (query) {
                _performSearch(query);
              },
            ),
          ),
          const SizedBox(height: 16),
          _searchController.text.isEmpty
              ? _buildSuggestions()
              : _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Expanded(
      child: ListView.builder(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            color: Color(MyColor.pr1),
            child: ListTile(
              title: Text(_suggestions[index]),
              onTap: () {
                _searchController.text = _suggestions[index];
                _performSearch(_suggestions[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: _searchResults.isEmpty
          ? const Center(child: Text('Không có kết quả phù hợp'))
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return TripCard(trip: _searchResults[index]);
              },
            ),
    );
  }
}
