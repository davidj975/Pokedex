import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_service.dart';
import 'pokemon_detail_screen.dart';
import 'favorites_screen.dart';

class PokedexScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const PokedexScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  _PokedexScreenState createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> with SingleTickerProviderStateMixin {
  List<Pokemon> _pokemonList = [];
  List<Pokemon> _filteredPokemonList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _isGridView = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _fetchPokemonData();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  Future<void> _fetchPokemonData() async {
    try {
      final pokemonList = await PokemonService.fetchAllPokemon();
      setState(() {
        _pokemonList = pokemonList;
        _filteredPokemonList = pokemonList;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterPokemon(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredPokemonList = _pokemonList
          .where((pokemon) => pokemon.name.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      case 'bug':
        return Colors.greenAccent;
      case 'normal':
        return Colors.grey;
      case 'psychic':
        return Colors.purple;
      default:
        return Colors.white;
    }
  }

  Widget _buildPokemonCard(Pokemon pokemon) {
    return FadeTransition(
      opacity: _animationController,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: FutureBuilder<Map<String, dynamic>>(
          future: PokemonService.fetchPokemonDetails(pokemon.url),
          builder: (context, snapshot) {
            String type = 'normal';
            if (snapshot.hasData) {
              try {
                type = snapshot.data!['types'][0]['type']['name'];
              } catch (e) {
                type = 'normal';
              }
            }
            return ListTile(
              contentPadding: EdgeInsets.all(8),
              tileColor: _getTypeColor(type),
              leading: Image.network(pokemon.imageUrl, height: 50, width: 50),
              title: Text(
                pokemon.name.toUpperCase(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PokemonDetailScreen(pokemon: pokemon)),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex'),
        centerTitle: false, // Move title to left
        actions: [
          // View toggle button
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          // Favorites button
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen(isGridView: _isGridView)),
              );
            },
          ),
          // Theme toggle
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildPokemonList(),
    );
  }

  Widget _buildPokemonList() {
    if (_isGridView) {
      return GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _filteredPokemonList.length,
        itemBuilder: (context, index) {
          return _buildPokemonCard(_filteredPokemonList[index]);
        },
      );
    } else {
      return ListView.builder(
        itemCount: _filteredPokemonList.length,
        itemBuilder: (context, index) {
          return _buildPokemonCard(_filteredPokemonList[index]);
        },
      );
    }
  }
}
