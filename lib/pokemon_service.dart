import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pokemon.dart';

class PokemonService {
  static const String apiUrl = 'https://pokeapi.co/api/v2/pokemon?limit=1025';

  static Future<List<Pokemon>> fetchAllPokemon() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Extraer id de la URL para construir la imagen
      return (data['results'] as List).map<Pokemon>((item) {
        final segments = item['url'].split('/');
        final id = segments[segments.length - 2];
        return Pokemon(
          name: item['name'],
          imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
          url: item['url'],
        );
      }).toList();
    } else {
      throw Exception('Error al cargar los Pokémon');
    }
  }

  static Future<Map<String, dynamic>> fetchPokemonDetails(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener detalles del Pokémon');
    }
  }

  static Future<Map<String, dynamic>> fetchPokemonEvolutionChain(String speciesUrl) async {
    // Primero obtenemos los detalles de la especie
    final speciesResponse = await http.get(Uri.parse(speciesUrl));
    if (speciesResponse.statusCode != 200) {
      throw Exception('Error al obtener la especie del Pokémon');
    }
    final speciesData = json.decode(speciesResponse.body);
    final evolutionChainUrl = speciesData['evolution_chain']['url'];

    final evolutionResponse = await http.get(Uri.parse(evolutionChainUrl));
    if (evolutionResponse.statusCode == 200) {
      return json.decode(evolutionResponse.body);
    } else {
      throw Exception('Error al obtener la cadena evolutiva del Pokémon');
    }
  }
}
