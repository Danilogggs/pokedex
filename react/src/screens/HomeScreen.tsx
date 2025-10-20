import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  FlatList,
  ActivityIndicator,
  Button,
  TextInput,
  StyleSheet,
  Alert
} from "react-native";
import { StackScreenProps } from "@react-navigation/stack";
import { RootStackParamList } from "../navigation";
import { fetchPokemonPage, extractIdFromUrl, fetchPokemon } from "../api/pokeapi";
import PokemonCard from "../components/PokemonCard";
import { PokemonSummary } from "../types/pokemon";

type Props = StackScreenProps<RootStackParamList, "Home">;

export default function HomeScreen({ navigation }: Props) {
  const [items, setItems] = useState<PokemonSummary[]>([]);
  const [offset, setOffset] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [query, setQuery] = useState("");

  const pageSize = 20;

  async function loadPage(initial = false) {
    try {
      setLoading(true);
      setError(null);
      const data = await fetchPokemonPage(initial ? 0 : offset, pageSize);
      const mapped: PokemonSummary[] = data.results.map((r: any) => {
        const id = extractIdFromUrl(r.url);
        return {
          id,
          name: r.name,
          image: `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${id}.png`
        };
      });
      setItems((prev) => (initial ? mapped : [...prev, ...mapped]));
      setOffset((prev) => (initial ? pageSize : prev + pageSize));
    } catch (e: any) {
      setError(e.message ?? "Erro ao carregar.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadPage(true);
  }, []);

  async function handleSearch() {
    if (!query.trim()) return;
    try {
      setLoading(true);
      setError(null);
      const p = await fetchPokemon(query);
      navigation.navigate("Details", { nameOrId: String(p.id) });
    } catch (e: any) {
      Alert.alert("Ops!", e.message ?? "Pokémon não encontrado.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <View style={styles.container}>
      <View style={styles.row}>
        <TextInput
          value={query}
          onChangeText={setQuery}
          placeholder="Nome ou número"
          style={styles.input}
          autoCapitalize="none"
        />
        <Button title="Buscar" onPress={handleSearch} />
        <View style={{ width: 8 }} />
        <Button title="Favoritos" onPress={() => navigation.navigate("Favorites")} />
      </View>

      {loading && items.length === 0 ? (
        <ActivityIndicator size="large" />
      ) : error ? (
        <Text style={styles.error}>{error}</Text>
      ) : (
        <>
          <FlatList
            data={items}
            keyExtractor={(it) => String(it.id)}
            numColumns={3}
            renderItem={({ item }) => (
              <PokemonCard
                data={item}
                onPress={() => navigation.navigate("Details", { nameOrId: String(item.id) })}
              />
            )}
            contentContainerStyle={{ paddingHorizontal: 6, paddingBottom: 12 }}
          />

          {loading ? (
            <ActivityIndicator style={{ margin: 12 }} />
          ) : (
            <Button title="Carregar Mais" onPress={() => loadPage(false)} />
          )}
        </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 12, gap: 8 },
  row: { flexDirection: "row", alignItems: "center", gap: 8 },
  input: {
    flex: 1,
    borderWidth: 1,
    borderColor: "#ccc",
    borderRadius: 6,
    paddingHorizontal: 10,
    height: 40,
    backgroundColor: "#fff"
  },
  error: { color: "red", textAlign: "center", marginTop: 12 }
});
