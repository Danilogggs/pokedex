import 'package:flutter/material.dart';
import '../models/pokemon.dart';

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class PokemonCard extends StatelessWidget {
  final PokemonSummary p;
  final VoidCallback? onTap;
  const PokemonCard({super.key, required this.p, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              SizedBox(
                height: 90, // aqui ajusta tamanho da imagem da home
                child: Image.network(
                  p.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                  loadingBuilder: (c, w, progress) {
                    if (progress == null) return w;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '#${p.id}  ${_cap(p.name)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
