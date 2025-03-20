import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_service.dart';
import 'pokemon_detail_screen.dart';
import 'favorites_manager.dart';

class FavoritesScreen extends StatefulWidget {
  final bool isGridView;

  const FavoritesScreen({Key? key, required this.isGridView}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Pokemon> _favoritePokemon = [];
  List<Pokemon> _filteredPokemon = [];
  bool _isLoading = true;
  late bool _isGridView;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isGridView = widget.isGridView;
    _loadFavorites();
    _searchController.addListener(_filterPokemon);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPokemon() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPokemon = _favoritePokemon.where((pokemon) {
        return pokemon.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await FavoritesManager.getFavorites();
      final List<Pokemon> pokemonList = [];
      
      for (String name in favorites) {
        final response = await PokemonService.fetchPokemonByName(name);
        pokemonList.add(response);
      }

      setState(() {
        _favoritePokemon = pokemonList;
        _filteredPokemon = pokemonList;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          // Pokemon List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredPokemon.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No hay Pokémon favoritos'),
                          ],
                        ),
                      )
                    : _buildPokemonList(),
          ),
        ],
      ),
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
        itemCount: _filteredPokemon.length,
        itemBuilder: (context, index) {
          return _buildPokemonCard(_filteredPokemon[index]);
        },
      );
    } else {
      return ListView.builder(
        itemCount: _filteredPokemon.length,
        itemBuilder: (context, index) {
          return _buildPokemonCard(_filteredPokemon[index]);
        },
      );
    }
  }

  Widget _buildPokemonCard(Pokemon pokemon) {
    return Card(
      child: Stack(
        children: [
          ListTile(
            leading: Hero(
              tag: 'favorite_${pokemon.name}',
              child: Image.network(pokemon.imageUrl),
            ),
            title: Text(pokemon.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetailScreen(pokemon: pokemon),
                ),
              ).then((_) => _loadFavorites());
            },
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.favorite, color: Colors.red),
              onPressed: () async {
                await FavoritesManager.toggleFavorite(pokemon.name);
                _loadFavorites();
              },
            ),
          ),
        ],
      ),
    );
  }
}