import React from "react";
import { createStackNavigator } from "@react-navigation/stack";
import HomeScreen from "../screens/HomeScreen";
import DetailsScreen from "../screens/DetailsScreen";
import FavoritesScreen from "../screens/FavoritesScreen";

export type RootStackParamList = {
  Home: undefined;
  Details: { nameOrId: string };
  Favorites: undefined;
};

const Stack = createStackNavigator<RootStackParamList>();

export const RootNavigator = () => (
  <Stack.Navigator>
    <Stack.Screen name="Home" component={HomeScreen} options={{ title: "Pokédex" }} />
    <Stack.Screen name="Details" component={DetailsScreen} options={{ title: "Detalhes" }} />
    <Stack.Screen name="Favorites" component={FavoritesScreen} options={{ title: "Favoritos" }} />
  </Stack.Navigator>
);
