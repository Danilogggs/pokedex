import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';
import '../providers/favorites_provider.dart';
import '../widgets/pokemon_card.dart';
import 'details_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = PokeApiService();
  final _items = <PokemonSummary>[];
  final _searchCtrl = TextEditingController();

  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _offset = 0;
  final int _pageSize = 24;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() { _loading = true; _error = null; _offset = 0; _items.clear(); });
    try {
      final page = await _api.fetchPage(limit: _pageSize, offset: _offset);
      setState(() {
        _items.addAll(page);
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() { _loadingMore = true; });
    try {
      _offset += _pageSize;
      final page = await _api.fetchPage(limit: _pageSize, offset: _offset);
      setState(() {
        _items.addAll(page);
        _loadingMore = false;
      });
    } catch (e) {
      setState(() { _loadingMore = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar mais: $e')),
        );
      }
    }
  }

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final detail = await _api.search(q);
      if (mounted) {
        Navigator.of(context).pop(); // fecha o diálogo
        final summary = PokemonSummary(id: detail.id, name: detail.name);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => DetailsScreen(summary: summary),
        ));
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não encontrado: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favCount = context.watch<FavoritesProvider>().items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex Explorer'),
        actions: [
          IconButton(
            tooltip: 'Favoritos ($favCount)',
            onPressed: () => Navigator.pushNamed(context, FavoritesScreen.route),
            icon: const Icon(Icons.star),
          )
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Erro: $_error'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadInitial,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nome ou número',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _search(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _search,
                            child: const Text('Buscar'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: .78,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final p = _items[i];
                          return PokemonCard(
                            p: p,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DetailsScreen(summary: p),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: ElevatedButton.icon(
                        onPressed: _loadingMore ? null : _loadMore,
                        icon: _loadingMore
                            ? const SizedBox(
                                height: 16, width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.expand_more),
                        label: const Text('Carregar mais'),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
