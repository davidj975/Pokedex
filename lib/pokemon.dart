import 'package:flutter/material.dart';

class Pokemon {
  final String name;
  final String imageUrl;
  final int id;
  final List<String> types;
  final double height;
  final double weight;
  final Map<String, int> stats;

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.id,
    required this.types,
    required this.height,
    required this.weight,
    required this.stats,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      imageUrl: json['sprites']['front_default'] ?? '',
      id: json['id'],
      types: (json['types'] as List)
          .map((type) => type['type']['name'].toString())
          .toList(),
      height: json['height'] / 10.0,
      weight: json['weight'] / 10.0,
      stats: {
        'HP': json['stats'][0]['base_stat'],
        'Attack': json['stats'][1]['base_stat'],
        'Defense': json['stats'][2]['base_stat'],
        'Sp. Atk': json['stats'][3]['base_stat'],
        'Sp. Def': json['stats'][4]['base_stat'],
        'Speed': json['stats'][5]['base_stat'],
      },
    );
  }

  // Devuelve un color basado en el primer tipo del Pokémon
  Color getTypeColor() {
    Map<String, Color> typeColors = {
      'fire': Colors.red,
      'water': Colors.blue,
      'grass': Colors.green,
      'electric': Colors.yellow.shade700,
      'ice': Colors.cyan,
      'fighting': Colors.orange,
      'poison': Colors.purple,
      'ground': Colors.brown,
      'flying': Colors.indigo,
      'psychic': Colors.pink,
      'bug': Colors.lightGreen,
      'rock': Colors.grey,
      'ghost': Colors.deepPurple,
      'dragon': Colors.indigoAccent,
      'dark': Colors.black,
      'steel': Colors.blueGrey,
      'fairy': Colors.pinkAccent,
    };
    return typeColors[types.first] ?? Colors.grey;
  }
}
