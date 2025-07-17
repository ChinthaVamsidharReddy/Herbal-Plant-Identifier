import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePlant {
  final String name;
  final String description;
  final String imagePath;
  final DateTime dateAdded;

  FavoritePlant({
    required this.name,
    required this.description,
    required this.imagePath,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory FavoritePlant.fromJson(Map<String, dynamic> json) {
    return FavoritePlant(
      name: json['name'],
      description: json['description'],
      imagePath: json['imagePath'],
      dateAdded: DateTime.parse(json['dateAdded']),
    );
  }
}

class FavoritesService {
  static const String _key = 'favorite_plants';

  Future<List<FavoritePlant>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_key);
    
    if (favoritesJson == null) return [];
    
    final List<dynamic> favoritesList = json.decode(favoritesJson);
    return favoritesList.map((json) => FavoritePlant.fromJson(json)).toList();
  }

  Future<void> addFavorite(FavoritePlant plant) async {
    final prefs = await SharedPreferences.getInstance();
    final List<FavoritePlant> favorites = await getFavorites();
    
    // Check if plant already exists
    final exists = favorites.any((favorite) => 
      favorite.name == plant.name && favorite.imagePath == plant.imagePath);
    
    if (!exists) {
      favorites.add(plant);
      final favoritesJson = json.encode(favorites.map((p) => p.toJson()).toList());
      await prefs.setString(_key, favoritesJson);
    }
  }

  Future<void> removeFavorite(FavoritePlant plant) async {
    final prefs = await SharedPreferences.getInstance();
    final List<FavoritePlant> favorites = await getFavorites();
    
    favorites.removeWhere((favorite) => 
      favorite.name == plant.name && 
      favorite.imagePath == plant.imagePath);
    
    final favoritesJson = json.encode(favorites.map((p) => p.toJson()).toList());
    await prefs.setString(_key, favoritesJson);
  }

  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
} 