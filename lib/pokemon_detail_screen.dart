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
  List<String>? _evolutionChain;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final data = await PokemonService.fetchPokemonDetails(widget.pokemon.url);
      final evolutionData = await PokemonService.fetchEvolutionChain(data['species']['url']);
      setState(() {
        _pokemonDetails = data;
        _evolutionChain = evolutionData;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.pokemon.name.toUpperCase(), style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : _hasError
          ? Center(child: Text('Error al cargar los datos', style: TextStyle(color: Colors.white)))
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(widget.pokemon.imageUrl, height: 150),
            SizedBox(height: 12),
            Text(widget.pokemon.name.toUpperCase(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 20),
            _pokemonDetails != null
                ? Column(
              children: [
                Text("Tipo: ${_pokemonDetails!['types'][0]['type']['name'].toUpperCase()}",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                SizedBox(height: 10),
                Text("Peso: ${_pokemonDetails!['weight'] / 10} kg",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                SizedBox(height: 10),
                Text("Altura: ${_pokemonDetails!['height'] / 10} m",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                SizedBox(height: 20),
                Text("Evolución", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                _evolutionChain != null
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _evolutionChain!
                      .map((imageUrl) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(imageUrl, height: 80),
                  ))
                      .toList(),
                )
                    : CircularProgressIndicator(color: Colors.white),
              ],
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
