import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_detail_screen.dart';
import 'pokemon_service.dart';
import 'favorites_manager.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  late Future<List<Pokemon>> _pokemonList;
  Map<String, bool> _favoritesMap = {};

  @override
  void initState() {
    super.initState();
    _pokemonList = PokemonService.fetchAllPokemon();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesManager.getFavorites();
    setState(() {
      for (var name in favorites) {
        _favoritesMap[name] = true;
      }
    });
  }

  Future<void> _toggleFavorite(Pokemon pokemon) async {
    await FavoritesManager.toggleFavorite(pokemon.name);
    await _loadFavorites();
  }

  Widget _buildPokemonCard(Pokemon pokemon) {
    final isFavorite = _favoritesMap[pokemon.name] ?? false;
    
    return Card(
      child: Stack(
        children: [
          // Existing Pokemon card content
          ListTile(
            leading: Image.network(pokemon.imageUrl),
            title: Text(pokemon.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetailScreen(pokemon: pokemon),
                ),
              ).then((_) => _loadFavorites()); // Refresh favorites when returning
            },
          ),
          // Favorite button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(pokemon),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildPokemonCard(snapshot.data![index]);
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
