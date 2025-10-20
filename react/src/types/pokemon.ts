export type PokemonListItem = {
  name: string;
  url: string;
};

export type PokemonSummary = {
  id: number;
  name: string;
  image: string;
};

export type PokemonDetails = {
  id: number;
  name: string;
  image: string;
  types: string[];
  abilities: string[];
};
