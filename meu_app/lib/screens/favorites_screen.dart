import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/pokemon_card.dart';
import 'details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  static const route = '/favorites';
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>().items;

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favs.isEmpty
          ? const Center(child: Text('Nenhum favorito ainda.'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: .78),
              itemCount: favs.length,
              itemBuilder: (_, i) => PokemonCard(
                p: favs[i],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailsScreen(summary: favs[i]),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
