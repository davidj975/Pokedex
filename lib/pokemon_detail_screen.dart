import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_service.dart';
import 'favorites_manager.dart';

class PokemonDetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  Map<String, dynamic>? _pokemonDetails;
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
    _checkFavoriteStatus();
  }

  Future<void> _fetchDetails() async {
    try {
      final details = await PokemonService.fetchPokemonDetails(widget.pokemon.url);
      setState(() {
        _pokemonDetails = details;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await FavoritesManager.isFavorite(widget.pokemon.name);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    await FavoritesManager.toggleFavorite(widget.pokemon.name);
    await _checkFavoriteStatus();
  }

  Widget _buildStatBar(String statName, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(statName, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value / 255,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getStatColor(value),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatColor(int value) {
    if (value < 50) return Colors.red;
    if (value < 100) return Colors.orange;
    if (value < 150) return Colors.yellow;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemon.name.toUpperCase()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pokemonDetails == null
              ? Center(child: Text('Error al cargar los detalles'))
              : Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 600), // Limit max width
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch, // Make cards full width
                        children: [
                          // Pokemon Image - Centered
                          Center(
                            child: Hero(
                              tag: widget.pokemon.name,
                              child: Image.network(
                                widget.pokemon.imageUrl,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          
                          // Types Card
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    'Tipos:', 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Center(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: (_pokemonDetails!['types'] as List)
                                          .map((type) => Chip(
                                                label: Text(
                                                  type['type']['name'],
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                backgroundColor: _getTypeColor(type['type']['name']),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Physical characteristics card
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    'Características Físicas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildCharacteristic(
                                        'Altura',
                                        '${_pokemonDetails!['height'] / 10} m'
                                      ),
                                      _buildCharacteristic(
                                        'Peso',
                                        '${_pokemonDetails!['weight'] / 10} kg'
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Stats card
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    'Estadísticas base:', 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  ..._pokemonDetails!['stats'].map<Widget>((stat) {
                                    return _buildStatBar(
                                      stat['stat']['name'],
                                      stat['base_stat'],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildCharacteristic(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    final typeColors = {
      'normal': Colors.brown[400],
      'fire': Colors.red,
      'water': Colors.blue,
      'electric': Colors.yellow,
      'grass': Colors.green,
      'ice': Colors.cyan,
      'fighting': Colors.orange[800],
      'poison': Colors.purple,
      'ground': Colors.brown,
      'flying': Colors.indigo[200],
      'psychic': Colors.pink,
      'bug': Colors.lightGreen,
      'rock': Colors.grey,
      'ghost': Colors.indigo,
      'dragon': Colors.indigo[800],
      'dark': Colors.grey[800],
      'steel': Colors.blueGrey,
      'fairy': Colors.pinkAccent[100],
    };
    return typeColors[type] ?? Colors.grey;
  }
}