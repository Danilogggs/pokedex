import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../services/pokeapi_service.dart';

class DetailsScreen extends StatefulWidget {
  final PokemonSummary summary;
  const DetailsScreen({super.key, required this.summary});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _api = PokeApiService();
  late Future<PokemonDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchDetail(widget.summary.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final isFav = favs.isFavorite(widget.summary.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.summary.name.toUpperCase()),
        actions: [
          IconButton(
            tooltip: isFav ? 'Desfavoritar' : 'Favoritar',
            icon: Icon(isFav ? Icons.star : Icons.star_border),
            onPressed: () => favs.toggle(widget.summary),
          ),
        ],
      ),
      body: FutureBuilder<PokemonDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Erro ao carregar: ${snap.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _future = _api.fetchDetail(widget.summary.id.toString());
                  }),
                  child: const Text('Tentar novamente'),
                )
              ]),
            );
          }
          final d = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 5, // altera tamanho da imagem
                  child: Image.network(
                    d.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 64),
                  ),
                ),
                const SizedBox(height: 12),
                Text('#${d.id}  ${d.name.toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: d.types
                      .map((t) => Chip(label: Text(t.toUpperCase())))
                      .toList(),
                ),
                const SizedBox(height: 16),
                const Text('Habilidades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...d.abilities.map((a) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.bolt),
                      title: Text(a),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
