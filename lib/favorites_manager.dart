import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _key = 'favorites';
  
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<bool> isFavorite(String pokemonName) async {
    final favorites = await getFavorites();
    return favorites.contains(pokemonName);
  }

  static Future<void> toggleFavorite(String pokemonName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    if (favorites.contains(pokemonName)) {
      favorites.remove(pokemonName);
    } else {
      favorites.add(pokemonName);
    }
    
    await prefs.setStringList(_key, favorites);
  }
}