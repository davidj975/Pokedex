class Pokemon {
  final String name;
  final String imageUrl;
  final String url;

  Pokemon({required this.name, required this.imageUrl, required this.url});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      imageUrl: json['sprites']['front_default'],
      url: json['species']['url'],
    );
  }
}
