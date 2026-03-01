import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/plant_info_card.dart';
import '../services/favorites_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _query = "";
  String _sort = "recent";

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesService>();

    // ⭐ SEARCH FILTER
    List<FavoritePlant> list = fav.favorites
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    // ⭐ SORTING
    if (_sort == "az") {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else {
      list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Favorite Plants")),
      body: Column(
        children: [
          // ⭐ SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search favorites...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // ⭐ SORT DROPDOWN
          DropdownButton<String>(
            value: _sort,
            items: const [
              DropdownMenuItem(value: "recent", child: Text("Recent")),
              DropdownMenuItem(value: "az", child: Text("A-Z")),
            ],
            onChanged: (v) => setState(() => _sort = v!),
          ),

          // ⭐ LIST
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text("No favorites yet"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final plant = list[i];

                      return Dismissible(
                        key: Key(plant.name + plant.imagePath),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) =>
                            fav.toggleFavorite(plant), // ⭐ REMOVE
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PlantInfoCard(
                            plantName: plant.name,
                            plantDescription: plant.description,
                            imagePath: plant.imagePath,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
