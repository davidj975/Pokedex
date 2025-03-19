import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_service.dart';

class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  PokemonDetailScreen({required this.pokemon});

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  Map<String, dynamic>? _pokemonDetails;
  Map<String, dynamic>? _evolutionChain;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final details = await PokemonService.fetchPokemonDetails(widget.pokemon.url);
      final speciesUrl = details['species']['url'];
      final evolutionChain = await PokemonService.fetchPokemonEvolutionChain(speciesUrl);
      setState(() {
        _pokemonDetails = details;
        _evolutionChain = evolutionChain;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Widget _buildEvolutionChain(Map<String, dynamic> evolutionChain) {
    List<Widget> evolutionWidgets = [];
    var chain = evolutionChain['chain'];
    // Iteramos sobre la cadena evolutiva
    while (chain != null) {
      final speciesName = chain['species']['name'];
      // Extraemos el id desde la URL de la especie
      final segments = chain['species']['url'].split('/');
      final id = segments[segments.length - 2];
      evolutionWidgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            children: [
              Image.network(
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
                height: 80,
              ),
              Text(speciesName.toUpperCase(), style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
      if (chain['evolves_to'] != null && (chain['evolves_to'] as List).isNotEmpty) {
        chain = chain['evolves_to'][0];
      } else {
        chain = null;
      }
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: evolutionWidgets),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemon.name.toUpperCase()),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(child: Text('Error al cargar los detalles'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.network(widget.pokemon.imageUrl, height: 150)),
            SizedBox(height: 20),
            Center(
              child: Text(widget.pokemon.name.toUpperCase(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
            if (_pokemonDetails != null) ...[
              Text("Tipo: ${_pokemonDetails!['types'][0]['type']['name'].toUpperCase()}",
                  style: TextStyle(fontSize: 18)),
              Text("Peso: ${_pokemonDetails!['weight'] / 10} kg", style: TextStyle(fontSize: 18)),
              Text("Altura: ${_pokemonDetails!['height'] / 10} m", style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
            ],
            if (_evolutionChain != null) ...[
              Text("Evolución:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildEvolutionChain(_evolutionChain!),
            ],
          ],
        ),
      ),
    );
  }
}
