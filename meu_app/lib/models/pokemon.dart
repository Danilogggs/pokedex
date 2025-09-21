class PokemonSummary {
  final int id;
  final String name;
  PokemonSummary({required this.id, required this.name});

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}

class PokemonDetail {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final List<String> abilities;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.abilities,
  });
}
