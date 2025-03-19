import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_service.dart';
import 'pokemon_detail_screen.dart';

class PokedexScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  PokedexScreen({required this.toggleTheme, required this.isDarkMode});

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
        title: Text('Pokédex', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6, color: Colors.white),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: Colors.white),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.search, color: Colors.red),
              ),
              onChanged: _filterPokemon,
            ),
          ),
          Expanded(
            child: _isGridView
                ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _filteredPokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = _filteredPokemonList[index];
                return _buildPokemonCard(pokemon);
              },
            )
                : ListView.builder(
              itemCount: _filteredPokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = _filteredPokemonList[index];
                return _buildPokemonCard(pokemon);
              },
            ),
          ),
        ],
      ),
    );
  }
}
