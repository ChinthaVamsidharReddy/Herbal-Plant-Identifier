import 'package:flutter/material.dart';
import '../widgets/plant_info_card.dart';
import '../services/favorites_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<FavoritePlant>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = FavoritesService().getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Plants'),
      ),
      body: FutureBuilder<List<FavoritePlant>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return const Center(child: Text('No favorites yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final plant = favorites[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PlantInfoCard(
                  plantName: plant.name,
                  plantDescription: plant.description,
                  imagePath: plant.imagePath,
                ),
              );
            },
          );
        },
      ),
    );
  }
}