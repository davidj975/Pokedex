import 'package:flutter/material.dart';
import 'pokedex_screen.dart';

void main() {
  runApp(PokedexApp());
}

class PokedexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex',
      theme: ThemeData(
        primaryColor: Colors.red[800],
        scaffoldBackgroundColor: Colors.red[700],
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // Cambié bodyText2 a bodyMedium
        ),
      ),
      home: PokedexScreen(),
    );
  }
}
