import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'pokemon.dart';
import 'pokemon_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PokemonList extends StatefulWidget {
  final VoidCallback toggleDarkMode;
  const PokemonList({super.key, required this.toggleDarkMode});

  @override
  _PokemonListState createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<Pokemon> allPokemon = [];
  List<Pokemon> filteredPokemon = [];
  List<Pokemon> favoritePokemon = [];
  String searchQuery = '';
  bool isGridView = false;
  bool showFavorites = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Parámetros para lazy loading
  final int _limit = 20;
  int _offset = 0;
  final int _maxPokemon = 1025;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String selectedType = 'All'; // Added for type filtering
  bool sortByAlphabet = false; // Added for sorting
  Map<int, Pokemon> pokemonCache = {};  // Add cache

  @override
  void initState() {
    super.initState();
    initNotifications();
    fetchPokemon();
    loadFavorites();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore &&
          !showFavorites &&
          searchQuery.isEmpty) {
        fetchPokemon();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> fetchPokemon() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final batch = List.generate(
        _limit,
        (i) => _offset + i + 1,
      ).where((id) => id <= _maxPokemon && !pokemonCache.containsKey(id));

      final futures = batch.map((id) => fetchSinglePokemon(id));
      final pokemons = await Future.wait(futures);

      setState(() {
        for (var pokemon in pokemons) {
          if (pokemon != null) {
            pokemonCache[pokemon.id] = pokemon;
          }
        }
        allPokemon = pokemonCache.values.toList()..sort((a, b) => a.id.compareTo(b.id));
        filteredPokemon = allPokemon;
        _offset += _limit;
        if (_offset >= _maxPokemon) _hasMore = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los Pokémon: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Pokemon?> fetchSinglePokemon(int id) async {
    try {
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));
      if (response.statusCode == 200) {
        return Pokemon.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Error loading Pokemon $id: $e');
    }
    return null;
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      favoritePokemon =
          allPokemon.where((pokemon) => favorites.contains(pokemon.name)).toList();
    });
  }

  Future<void> toggleFavorite(Pokemon pokemon) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    if (favorites.contains(pokemon.name)) {
      favorites.remove(pokemon.name);
    } else {
      favorites.add(pokemon.name);
    }

    await prefs.setStringList('favorites', favorites);
    loadFavorites();

    if (favorites.contains(pokemon.name)) {
      Future.delayed(const Duration(seconds: 3), () {
        flutterLocalNotificationsPlugin.show(
          0,
          'Pokémon Favorito',
          '¡${pokemon.name} ahora es tu favorito!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'favoritos_channel',
              'Favoritos',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      });
    }
  }

  Future<void> searchPokemon(String query) async {
    setState(() {
      searchQuery = query.toLowerCase();
      _isLoading = true;
    });

    if (query.isEmpty) {
      setState(() {
        filteredPokemon = allPokemon;
        _isLoading = false;
      });
      return;
    }

    try {

      try {
        final response = await http.get(
          Uri.parse('https://pokeapi.co/api/v2/pokemon/${searchQuery}/'),
        );
        if (response.statusCode == 200) {
          final pokemonData = json.decode(response.body);
          final pokemon = Pokemon.fromJson(pokemonData);
          setState(() {
            if (!pokemonCache.containsKey(pokemon.id)) {
              pokemonCache[pokemon.id] = pokemon;
              allPokemon = pokemonCache.values.toList()..sort((a, b) => a.id.compareTo(b.id));
            }
            filteredPokemon = [pokemon];
          });
          setState(() => _isLoading = false);
          return;
        }
      } catch (e) {
        print('No exact match found, trying ID search');
      }


      final id = int.tryParse(query);
      if (id != null && id > 0 && id <= _maxPokemon) {
        final pokemon = await fetchSinglePokemon(id);
        if (pokemon != null) {
          setState(() {
            pokemonCache[pokemon.id] = pokemon;
            allPokemon = pokemonCache.values.toList()..sort((a, b) => a.id.compareTo(b.id));
            filteredPokemon = [pokemon];
          });
          setState(() => _isLoading = false);
          return;
        }
      }


      setState(() {
        filteredPokemon = allPokemon
            .where((pokemon) =>
                pokemon.name.toLowerCase().contains(searchQuery) ||
                pokemon.id.toString() == query)
            .toList();
      });
    } catch (e) {
      print('Search error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void filterPokemon(String query) {
    setState(() {
      searchQuery = query;
      if (query.isNotEmpty) {
        filteredPokemon = allPokemon
            .where((pokemon) =>
                pokemon.name.toLowerCase().contains(query.toLowerCase()) ||
                pokemon.id.toString() == query)
            .toList();
      } else {
        filteredPokemon = allPokemon;
      }
    });
  }

  void filterByType(String type) {
    setState(() {
      selectedType = type;
      filteredPokemon = allPokemon.where((pokemon) {
        return type == 'All' || pokemon.types.contains(type.toLowerCase());
      }).toList();
      sortPokemon();
    });
  }

  void toggleSortOrder() {
    setState(() {
      sortByAlphabet = !sortByAlphabet;
      sortPokemon();
    });
  }

  void sortPokemon() {
    filteredPokemon.sort((a, b) {
      if (sortByAlphabet) {
        return a.name.compareTo(b.name);
      } else {
        return a.id.compareTo(b.id);
      }
    });
  }

  void toggleView() {
    setState(() {
      isGridView = !isGridView;
    });
  }

  void toggleFavorites() {
    setState(() {
      showFavorites = !showFavorites;
    });
  }

  //pokémon aleatorio
  void showRandomPokemon() {
    if (allPokemon.isNotEmpty) {
      final randomIndex = Random().nextInt(allPokemon.length);
      final randomPokemon = allPokemon[randomIndex];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PokemonDetailScreen(pokemon: randomPokemon),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadMoreIndicator = _isLoading
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          )
        : const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(

        title: TextField(
          controller: _searchController,
          onChanged: searchPokemon,
          decoration: const InputDecoration(
            hintText: 'Buscar Pokémon',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(fontSize: 18),
        ),
        actions: [

          DropdownButton<String>(
            value: selectedType,
            items: ['All', 'Fire', 'Water', 'Grass', 'Electric', 'Ice', 'Fighting', 'Poison', 'Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost', 'Dragon', 'Dark', 'Steel', 'Fairy']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (type) => filterByType(type!),
          ),
          IconButton(
            icon: Icon(sortByAlphabet ? Icons.sort_by_alpha : Icons.numbers),
            onPressed: toggleSortOrder,
          ),
          IconButton(
            icon: Icon(showFavorites ? Icons.list : Icons.favorite),
            onPressed: toggleFavorites,
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleDarkMode,
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_on),
            onPressed: toggleView,
          ),
          // botón aleatorio
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: showRandomPokemon,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: showFavorites
                ? buildList(favoritePokemon)
                : Stack(
                    children: [
                      buildList(filteredPokemon),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: loadMoreIndicator,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildList(List<Pokemon> pokemonList) {
    return isGridView ? buildGridView(pokemonList) : buildListView(pokemonList);
  }

  Widget buildListView(List<Pokemon> pokemonList) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: pokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = pokemonList[index];
        final isFavorite = favoritePokemon.contains(pokemon);
        return Card(
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: pokemon.getTypeColor(), width: 2),
          ),
          elevation: 5,
          child: ListTile(
            leading: Image.network(
              pokemon.imageUrl,
            ),
            title: Text(pokemon.name),
            trailing: IconButton(
              icon: Icon(
                Icons.favorite,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () => toggleFavorite(pokemon),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetailScreen(pokemon: pokemon),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildGridView(List<Pokemon> pokemonList) {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: pokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = pokemonList[index];
        final isFavorite = favoritePokemon.contains(pokemon);
        return Card(
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: pokemon.getTypeColor(), width: 2),
          ),
          elevation: 5,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetailScreen(pokemon: pokemon),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(pokemon.imageUrl),
                Text(pokemon.name),
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => toggleFavorite(pokemon),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
