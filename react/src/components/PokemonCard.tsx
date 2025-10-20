import React from "react";
import { View, Text, Image, TouchableOpacity, StyleSheet } from "react-native";
import { PokemonSummary } from "../types/pokemon";

type Props = {
  data: PokemonSummary;
  onPress: () => void;
};

export default function PokemonCard({ data, onPress }: Props) {
  return (
    <TouchableOpacity style={styles.card} onPress={onPress}>
      <Image source={{ uri: data.image }} style={styles.image} />
      <Text style={styles.name}>{data.name}</Text>
      <Text style={styles.id}>#{String(data.id).padStart(3, "0")}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    flex: 1,
    margin: 6,
    padding: 10,
    borderRadius: 8,
    backgroundColor: "#fff",
    alignItems: "center",
    elevation: 2
  },
  image: { width: 80, height: 80, marginBottom: 6 },
  name: { fontWeight: "600", textTransform: "capitalize" },
  id: { color: "#666", marginTop: 2, fontSize: 12 }
});
