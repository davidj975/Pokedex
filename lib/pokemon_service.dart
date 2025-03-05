import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pokemon.dart';

class PokemonService {
  static const String apiUrl = 'https://pokeapi.co/api/v2/pokemon?limit=1010';

  // Obtiene la lista de todos los Pokémon
  static Future<List<Pokemon>> fetchAllPokemon() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'].map<Pokemon>((item) {
        final id = item['url'].split('/')[6];
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

  // Obtiene detalles del Pokémon
  static Future<Map<String, dynamic>> fetchPokemonDetails(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener detalles del Pokémon');
    }
  }

  // Obtiene la cadena evolutiva del Pokémon
  static Future<List<String>> fetchEvolutionChain(String speciesUrl) async {
    final response = await http.get(Uri.parse(speciesUrl));
    if (response.statusCode != 200) throw Exception('Error al obtener datos de especie');

    final speciesData = json.decode(response.body);
    final evolutionUrl = speciesData['evolution_chain']['url'];
    final evolutionResponse = await http.get(Uri.parse(evolutionUrl));

    if (evolutionResponse.statusCode != 200) throw Exception('Error al obtener evolución');

    final evolutionData = json.decode(evolutionResponse.body);
    List<String> evolutionImages = [];

    var currentStage = evolutionData['chain'];
    while (currentStage != null) {
      final speciesName = currentStage['species']['name'];
      final id = currentStage['species']['url'].split('/')[6];
      evolutionImages.add('https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png');

      if (currentStage['evolves_to'].isNotEmpty) {
        currentStage = currentStage['evolves_to'][0];
      } else {
        break;
      }
    }
    return evolutionImages;
  }
}
