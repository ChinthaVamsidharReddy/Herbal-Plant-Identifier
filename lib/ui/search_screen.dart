import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import 'plant_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final Map<String, Map<String, dynamic>> plantInfo;

  const SearchScreen({super.key, required this.plantInfo});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = "";

  String _text(dynamic field, String lang) {
    if (field is Map) {
      return field[lang] ?? field["en"] ?? "";
    }
    return field?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>().currentLanguage;

    final results = widget.plantInfo.keys.where((key) {
      final name = _text(widget.plantInfo[key]?['name'], lang).toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Search Plant")),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: "Search plant...",
              contentPadding: EdgeInsets.all(12),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final plant = widget.plantInfo[results[i]];
                return ListTile(
                  title: Text(_text(plant?['name'], lang)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlantDetailScreen(
                          plantKey: results[i],
                          plantInfo: widget.plantInfo,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}