import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const String _base = 'https://pokeapi.co/api/v2';

  Future<List<PokemonSummary>> fetchPage({int limit = 24, int offset = 0}) async {
    final uri = Uri.parse('$_base/pokemon?limit=$limit&offset=$offset');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Falha ao carregar lista (${res.statusCode}).');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List).cast<Map<String, dynamic>>();

    // results[i] = { name, url } — extraímos o ID a partir de .../pokemon/{id}/
    final idRegex = RegExp(r'/pokemon/(\d+)/?$');
    return results.map((e) {
      final url = e['url'] as String;
      final m = idRegex.firstMatch(url);
      final id = int.parse(m!.group(1)!);
      return PokemonSummary(id: id, name: e['name']);
    }).toList();
  }

  Future<PokemonDetail> fetchDetail(String idOrName) async {
    final uri = Uri.parse('$_base/pokemon/$idOrName');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Pokémon não encontrado (${res.statusCode}).');
    }
    final j = jsonDecode(res.body) as Map<String, dynamic>;

    final String image = (j['sprites']?['other']?['official-artwork']?['front_default']) ??
        (j['sprites']?['front_default']) ??
        '';

    final List<String> types = (j['types'] as List)
        .map((t) => (t['type']['name'] as String))
        .toList();

    final List<String> abilities = (j['abilities'] as List)
        .map((a) => (a['ability']['name'] as String))
        .toList();

    return PokemonDetail(
      id: j['id'] as int,
      name: j['name'] as String,
      imageUrl: image,
      types: types,
      abilities: abilities,
    );
  }

  // Útil para o RF06 (busca). Aceita nome ou número.
  Future<PokemonDetail> search(String query) => fetchDetail(query.trim().toLowerCase());
}
