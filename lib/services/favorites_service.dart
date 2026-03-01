// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class FavoritePlant {
//   final String name;
//   final String description;
//   final String imagePath;
//   final DateTime dateAdded;

//   FavoritePlant({
//     required this.name,
//     required this.description,
//     required this.imagePath,
//     DateTime? dateAdded,
//   }) : dateAdded = dateAdded ?? DateTime.now();

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'description': description,
//       'imagePath': imagePath,
//       'dateAdded': dateAdded.toIso8601String(),
//     };
//   }

//   factory FavoritePlant.fromJson(Map<String, dynamic> json) {
//     return FavoritePlant(
//       name: json['name'],
//       description: json['description'],
//       imagePath: json['imagePath'],
//       dateAdded: DateTime.parse(json['dateAdded']),
//     );
//   }
// }

// class FavoritesService {
//   static const String _key = 'favorite_plants';

//   Future<List<FavoritePlant>> getFavorites() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? favoritesJson = prefs.getString(_key);

//     if (favoritesJson == null) return [];

//     final List<dynamic> favoritesList = json.decode(favoritesJson);
//     return favoritesList.map((json) => FavoritePlant.fromJson(json)).toList();
//   }

//   Future<void> addFavorite(FavoritePlant plant) async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<FavoritePlant> favorites = await getFavorites();

//     // Check if plant already exists
//     final exists = favorites.any(
//       (favorite) =>
//           favorite.name == plant.name && favorite.imagePath == plant.imagePath,
//     );

//     if (!exists) {
//       favorites.add(plant);
//       final favoritesJson = json.encode(
//         favorites.map((p) => p.toJson()).toList(),
//       );
//       await prefs.setString(_key, favoritesJson);
//     }
//   }

//   Future<void> removeFavorite(FavoritePlant plant) async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<FavoritePlant> favorites = await getFavorites();

//     favorites.removeWhere(
//       (favorite) =>
//           favorite.name == plant.name && favorite.imagePath == plant.imagePath,
//     );

//     final favoritesJson = json.encode(
//       favorites.map((p) => p.toJson()).toList(),
//     );
//     await prefs.setString(_key, favoritesJson);
//   }

//   Future<void> clearFavorites() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_key);
//   }

//   Future<bool> isFavorite(String name, String imagePath) async {
//     final favorites = await getFavorites();
//     return favorites.any((f) => f.name == name && f.imagePath == imagePath);
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
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

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'imagePath': imagePath,
    'dateAdded': dateAdded.toIso8601String(),
  };

  factory FavoritePlant.fromJson(Map<String, dynamic> json) => FavoritePlant(
    name: json['name'],
    description: json['description'],
    imagePath: json['imagePath'],
    dateAdded: DateTime.parse(json['dateAdded']),
  );
}

class FavoritesService extends ChangeNotifier {
  static const String _key = 'favorite_plants';

  List<FavoritePlant> _favorites = [];

  List<FavoritePlant> get favorites => _favorites;

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data != null) {
      final List decoded = json.decode(data);
      _favorites = decoded.map((e) => FavoritePlant.fromJson(e)).toList();
    }
    notifyListeners();
  }

  bool isFavorite(String name, String imagePath) {
    return _favorites.any((f) => f.name == name && f.imagePath == imagePath);
  }

  Future<void> toggleFavorite(FavoritePlant plant) async {
    if (isFavorite(plant.name, plant.imagePath)) {
      _favorites.removeWhere(
        (f) => f.name == plant.name && f.imagePath == plant.imagePath,
      );
    } else {
      _favorites.add(plant);
    }
    await _save();
    notifyListeners();
  }

  Future<void> removeFavorite(FavoritePlant plant) async {
    _favorites.removeWhere(
      (f) => f.name == plant.name && f.imagePath == plant.imagePath,
    );
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(_favorites.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonData);
  }
}
