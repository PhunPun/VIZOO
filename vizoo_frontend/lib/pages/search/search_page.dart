import 'package:flutter/material.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  List<String> _suggestions = [
    'Vũng Tàu',
    'Phú Quốc',
    'Thành phố Hồ Chí Minh',
    'Đà Nẵng',
    'Hà Nội',
    'Nha Trang',
    'Huế',
    'Cần Thơ',
  ];

  void _performSearch(String query) {
    List<String> allItems = [
      'Vũng Tàu',
      'Phú Quốc',
      'Thành phố Hồ Chí Minh',
      'Đà Nẵng',
      'Hà Nội',
    ];

    setState(() {
      _searchResults = allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nhập từ khóa tìm kiếm...',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
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
            const SizedBox(height: 16),
            _searchController.text.isEmpty
                ? _buildSuggestions() 
                : _buildSearchResults(), 
          ],
        ),
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
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  color: Color(MyColor.pr1),
                  child: ListTile(
                    title: Text(_searchResults[index]),
                  ),
                );
              },
            ),
    );
  }
}
