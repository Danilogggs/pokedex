import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const String _base = 'https://pokeapi.co/api/v2';
  static final RegExp _idRx = RegExp(r'/pokemon/(\d+)/?$');

  static List<PokemonSummary>? _allCache; // cache de todos os nomes/ids

  PokemonSummary _toSummary(Map<String, dynamic> e) {
    final url = e['url'] as String;
    final m = _idRx.firstMatch(url);
    final id = int.parse(m!.group(1)!);
    return PokemonSummary(id: id, name: e['name']);
  }

  Future<List<PokemonSummary>> fetchPage({int limit = 24, int offset = 0}) async {
    final uri = Uri.parse('$_base/pokemon?limit=$limit&offset=$offset');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Falha ao carregar lista (${res.statusCode}).');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    return results.map(_toSummary).toList();
  }

  Future<PokemonDetail> fetchDetail(String idOrName) async {
    final uri = Uri.parse('$_base/pokemon/$idOrName');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Pokémon não encontrado (${res.statusCode}).');
    }
    final j = jsonDecode(res.body) as Map<String, dynamic>;

    final String image = (j['sprites']?['other']?['official-artwork']?['front_default']) ??
        (j['sprites']?['front_default']) ?? '';

    final types = (j['types'] as List).map((t) => (t['type']['name'] as String)).toList();
    final abilities = (j['abilities'] as List).map((a) => (a['ability']['name'] as String)).toList();

    return PokemonDetail(
      id: j['id'] as int,
      name: j['name'] as String,
      imageUrl: image,
      types: types,
      abilities: abilities,
    );
  }

  // Carrega todos os nomes/ids uma única vez e usa cache.
  Future<List<PokemonSummary>> _getAllSummaries() async {
    if (_allCache != null) return _allCache!;
    final uri = Uri.parse('$_base/pokemon?limit=100000&offset=0');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Falha ao carregar índice (${res.statusCode}).');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    _allCache = results.map(_toSummary).toList();
    return _allCache!;
  }

  // Busca por "contém" no nome (case-insensitive).
  Future<List<PokemonSummary>> searchByNameContains(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    final all = await _getAllSummaries();
    return all.where((p) => p.name.contains(q)).toList();
  }

  // Mantive a busca exata por id/nome, se precisar:
  Future<PokemonDetail> searchExact(String query) => fetchDetail(query.trim().toLowerCase());
}
