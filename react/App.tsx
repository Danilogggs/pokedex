import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { RootNavigator } from "./src/navigation";
import { FavoritesProvider } from "./src/context/FavoritesContext";

export default function App() {
  return (
    <FavoritesProvider>
      <NavigationContainer>
        <RootNavigator />
      </NavigationContainer>
    </FavoritesProvider>
  );
}
