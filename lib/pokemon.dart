class Pokemon {
  final String name;
  final String imageUrl;
  final String url;

  Pokemon({required this.name, required this.imageUrl, required this.url});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${json['id']}.png',
      url: json['species']['url'],
    );
  }
}
