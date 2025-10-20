import React from "react";
import { View, FlatList, Text, StyleSheet } from "react-native";
import { useFavorites } from "../context/FavoritesContext";
import PokemonCard from "../components/PokemonCard";
import { StackScreenProps } from "@react-navigation/stack";
import { RootStackParamList } from "../navigation";

type Props = StackScreenProps<RootStackParamList, "Favorites">;

export default function FavoritesScreen({ navigation }: Props) {
  const { items } = useFavorites();

  return (
    <View style={styles.container}>
      {items.length === 0 ? (
        <Text style={styles.empty}>Você ainda não favoritou nenhum Pokémon.</Text>
      ) : (
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
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 12 },
  empty: { textAlign: "center", color: "#666", marginTop: 24 }
});
