import 'package:flutter/foundation.dart';
import '../models/pokemon.dart';

class FavoritesProvider extends ChangeNotifier {
  final Map<int, PokemonSummary> _favorites = {};

  List<PokemonSummary> get items =>
      _favorites.values.toList()..sort((a, b) => a.id.compareTo(b.id));

  bool isFavorite(int id) => _favorites.containsKey(id);

  void toggle(PokemonSummary p) {
    if (_favorites.containsKey(p.id)) {
      _favorites.remove(p.id);
    } else {
      _favorites[p.id] = p;
    }
    notifyListeners();
  }
}
