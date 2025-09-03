import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
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

  List<PokemonSummary>? _filtered;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() { _loading = true; _error = null; _offset = 0; _items.clear(); _filtered = null; });
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
    if (_loadingMore || _filtered != null) return;
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

  Future<void> _searchContains() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();

    showDialog(context: context, barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final res = await _api.searchByNameContains(q);
      if (mounted) {
        Navigator.of(context).pop();
        setState(() { _filtered = res; });
        if (res.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum Pokémon encontrado.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na busca: $e')),
        );
      }
    }
  }

  void _clearFilter() {
    setState(() { _filtered = null; _searchCtrl.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    final favCount = context.watch<FavoritesProvider>().items.length;
    final theme = context.watch<ThemeProvider>();
    final list = _filtered ?? _items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex Explorer'),
        actions: [
          IconButton(
            tooltip: 'Tema: ${theme.isDark ? 'Escuro' : 'Claro'}',
            onPressed: () => theme.toggle(),
            icon: Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode),
          ),
          IconButton(
            tooltip: 'Favoritos ($favCount)',
            onPressed: () => Navigator.pushNamed(context, FavoritesScreen.route),
            icon: const Icon(Icons.star),
          ),
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
                        ElevatedButton(onPressed: _loadInitial, child: const Text('Tentar novamente')),
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
                                  labelText: 'Buscar por nome (contém...)',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _searchContains(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _searchContains,
                              child: const Text('Buscar'),
                            ),
                            const SizedBox(width: 8),
                            if (_filtered != null)
                              OutlinedButton(onPressed: _clearFilter, child: const Text('Limpar')),
                          ],
                        ),
                      ),
                      if (_filtered != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${list.length} resultado(s)'),
                        ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, // qntd de itens por linha
                            crossAxisSpacing: 8, // distancia das colunas
                            mainAxisSpacing: 8, // distancia das linhas
                            childAspectRatio: 2.5, // Aqui altera tamanho do quadrado de cada catalogo
                          ),
                          itemCount: list.length,
                          itemBuilder: (_, i) {
                            final p = list[i];
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
                      if (_filtered == null)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: ElevatedButton.icon(
                            onPressed: _loadingMore ? null : _loadMore,
                            icon: _loadingMore
                                ? const SizedBox(
                                    height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
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
