import React, { createContext, useContext, useMemo, useState } from "react";
import { PokemonSummary } from "../types/pokemon";

type FavoritesContextType = {
  items: PokemonSummary[];
  isFavorite: (id: number) => boolean;
  toggle: (p: PokemonSummary) => void;
};

const FavoritesContext = createContext<FavoritesContextType | null>(null);

export const FavoritesProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [map, setMap] = useState<Record<number, PokemonSummary>>({});

  const isFavorite = (id: number) => !!map[id];
  const toggle = (p: PokemonSummary) =>
    setMap((prev) => {
      const clone = { ...prev };
      if (clone[p.id]) delete clone[p.id];
      else clone[p.id] = p;
      return clone;
    });

  const items = useMemo(
    () => Object.values(map).sort((a, b) => a.id - b.id),
    [map]
  );

  const value = useMemo(() => ({ items, isFavorite, toggle }), [items, map]);

  return <FavoritesContext.Provider value={value}>{children}</FavoritesContext.Provider>;
};

export const useFavorites = () => {
  const ctx = useContext(FavoritesContext);
  if (!ctx) throw new Error("useFavorites deve ser usado dentro de FavoritesProvider.");
  return ctx;
};
