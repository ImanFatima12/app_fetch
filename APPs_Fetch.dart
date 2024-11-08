import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ApiSearchListView(),
    );
  }
}


class ApiSearchListView extends StatefulWidget {
  const ApiSearchListView({super.key});

  @override
  _ApiSearchListViewState createState() => _ApiSearchListViewState();
}

class _ApiSearchListViewState extends State<ApiSearchListView> {
  List<dynamic> _data = []; // Original fetched data
  List<dynamic> _filteredData = []; // Filtered data for search
  bool _isLoading = true; // To show loading indicator

  // TextEditingController to get search query input
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Listen to search input and filter the data
    _searchController.addListener(() {
      _filterData(_searchController.text);
    });
  }

  // Function to fetch data from API
  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

    if (response.statusCode == 200) {
      setState(() {
        _data = json.decode(response.body);
        _filteredData = _data; // Initially show all data
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Function to filter data based on search query
  void _filterData(String query) {
    setState(() {
      _filteredData = _data
          .where((item) =>
              item['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Data with Search Filter'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Search TextField
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Displaying fetched data in ListView
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredData.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(_filteredData[index]['title']),
                            subtitle: Text(_filteredData[index]['body']),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controller to avoid memory leaks
    super.dispose();
  }
}
