import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_detail_screen.dart';
import 'pokemon_service.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  late Future<List<Pokemon>> _pokemonList;

  @override
  void initState() {
    super.initState();
    _pokemonList = PokemonService.fetchAllPokemon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex'),
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los Pokémon'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron Pokémon'));
          } else {
            final pokemonList = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: pokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = pokemonList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailScreen(pokemon: pokemon),
                      ),
                    );
                  },
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: PokemonService.fetchPokemonDetails(pokemon.url),
                    builder: (context, detailsSnapshot) {
                      if (detailsSnapshot.connectionState == ConnectionState.done &&
                          detailsSnapshot.hasData) {
                        var pokemonType = detailsSnapshot.data!['types'][0]['type']['name'];
                        return Card(
                          color: _getTypeColor(pokemonType),
                          elevation: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(pokemon.imageUrl, height: 100),
                              SizedBox(height: 10),
                              Text(pokemon.name.toUpperCase(), style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        );
                      } else {
                        return Card(
                          elevation: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
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
}
