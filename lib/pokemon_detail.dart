import 'package:flutter/material.dart';
import 'pokemon.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  // Retorna un degradado basado en el color del Pokémon y adaptado al brillo del tema
  LinearGradient getGradient(BuildContext context) {
    final baseColor = pokemon.getTypeColor();
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return LinearGradient(
        colors: [
          baseColor.withOpacity(0.9),
          baseColor.withOpacity(0.6),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      return LinearGradient(
        colors: [
          baseColor.withOpacity(0.7),
          baseColor.withOpacity(0.3),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  // Barra de progreso personalizada para las estadísticas
  Widget buildStatBar(BuildContext context, String label, int value) {
    final width = MediaQuery.of(context).size.width * 0.5;
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: textStyle),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: (value / 200) * width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        pokemon.getTypeColor().withOpacity(0.8),
                        pokemon.getTypeColor().withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text('$value', style: textStyle),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar los tipos con su color correspondiente
  Widget buildTypeChips() {
    return Wrap(
      spacing: 8,
      children: pokemon.types.map((type) {
        final typeColor = getTypeColor(type);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: typeColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: typeColor.withOpacity(0.8),
              width: 1,
            ),
          ),
          child: Text(
            type.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Mapeo de colores según el tipo
  Color getTypeColor(String type) {
    Map<String, Color> typeColors = {
      'fire': Colors.red,
      'water': Colors.blue,
      'grass': Colors.green,
      'electric': Colors.yellow.shade700,
      'ice': Colors.cyan,
      'fighting': Colors.orange,
      'poison': Colors.purple,
      'ground': Colors.brown,
      'flying': Colors.indigo,
      'psychic': Colors.pink,
      'bug': Colors.lightGreen,
      'rock': Colors.grey,
      'ghost': Colors.deepPurple,
      'dragon': Colors.indigoAccent,
      'dark': Colors.black,
      'steel': Colors.blueGrey,
      'fairy': Colors.pinkAccent,
    };
    return typeColors[type] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: pokemon.getTypeColor(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                pokemon.name.toUpperCase(),
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: getGradient(context),
                ),
                child: Center(
                  child: Hero(
                    tag: 'pokemon-${pokemon.id}', // Match the tag from the list
                    child: Image.network(
                      pokemon.imageUrl,
                      fit: BoxFit.contain,
                      height: 200,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: getGradient(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Datos básicos
                  Card(
                    color: theme.cardColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: pokemon.getTypeColor(), width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed from spaceEvenly to spaceBetween
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'ID',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text('${pokemon.id}', style: theme.textTheme.titleMedium),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Altura',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text('${pokemon.height} m', style: theme.textTheme.titleMedium),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Peso',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text('${pokemon.weight} kg', style: theme.textTheme.titleMedium),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          buildTypeChips(), // Tipos con su color correspondiente
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Estadísticas
                  Card(
                    color: theme.cardColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: pokemon.getTypeColor(), width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estadísticas Base',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...pokemon.stats.entries.map((entry) => buildStatBar(context, entry.key, entry.value)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
