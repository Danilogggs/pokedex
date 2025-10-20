import React, { useEffect, useState } from "react";
import { View, Text, Image, ActivityIndicator, StyleSheet, TouchableOpacity } from "react-native";
import { StackScreenProps } from "@react-navigation/stack";
import { RootStackParamList } from "../navigation";
import { fetchPokemon } from "../api/pokeapi";
import { PokemonDetails, PokemonSummary } from "../types/pokemon";
import { useFavorites } from "../context/FavoritesContext";

type Props = StackScreenProps<RootStackParamList, "Details">;

export default function DetailsScreen({ route }: Props) {
  const { nameOrId } = route.params;
  const [data, setData] = useState<PokemonDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { isFavorite, toggle } = useFavorites();

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setError(null);
        const raw = await fetchPokemon(nameOrId);
        const payload: PokemonDetails = {
          id: raw.id,
          name: raw.name,
          image: raw.sprites?.other?.["official-artwork"]?.front_default ??
                 raw.sprites?.front_default,
          types: raw.types?.map((t: any) => t.type.name) ?? [],
          abilities: raw.abilities?.map((a: any) => a.ability.name) ?? []
        };
        setData(payload);
      } catch (e: any) {
        setError(e.message ?? "Falha ao carregar detalhes.");
      } finally {
        setLoading(false);
      }
    })();
  }, [nameOrId]);

  if (loading) return <ActivityIndicator style={{ marginTop: 24 }} size="large" />;
  if (error || !data) return <Text style={styles.error}>{error ?? "Sem dados."}</Text>;

  const summary: PokemonSummary = {
    id: data.id,
    name: data.name,
    image: data.image || `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${data.id}.png`
  };

  const fav = isFavorite(data.id);

  return (
    <View style={styles.container}>
      {data.image ? <Image source={{ uri: data.image }} style={styles.image} /> : null}
      <Text style={styles.title}>
        {data.name}  <Text style={styles.id}>#{String(data.id).padStart(3, "0")}</Text>
      </Text>

      <View style={styles.row}>
        <Text style={styles.label}>Tipos:</Text>
        <Text style={styles.value}>{data.types.join(", ") || "-"}</Text>
      </View>

      <View style={styles.row}>
        <Text style={styles.label}>Habilidades:</Text>
        <Text style={styles.value}>{data.abilities.join(", ") || "-"}</Text>
      </View>

      <TouchableOpacity
        accessibilityRole="button"
        style={[styles.favBtn, fav ? styles.favOn : styles.favOff]}
        onPress={() => toggle(summary)}
      >
        <Text style={styles.favText}>{fav ? "Desfavoritar" : "Favoritar"}</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16, alignItems: "center" },
  image: { width: 200, height: 200, resizeMode: "contain", marginBottom: 12 },
  title: { fontSize: 22, fontWeight: "700", textTransform: "capitalize" },
  id: { color: "#666", fontSize: 16, fontWeight: "400" },
  row: { flexDirection: "row", gap: 8, marginTop: 12, flexWrap: "wrap" },
  label: { fontWeight: "700" },
  value: { textTransform: "capitalize" },
  favBtn: {
    marginTop: 24,
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8
  },
  favOn: { backgroundColor: "#e74c3c" },
  favOff: { backgroundColor: "#2ecc71" },
  favText: { color: "#fff", fontWeight: "700" },
  error: { color: "red", textAlign: "center", marginTop: 24 }
});
