const BASE = "https://pokeapi.co/api/v2";

export async function fetchPokemonPage(offset = 0, limit = 20) {
  const res = await fetch(`${BASE}/pokemon?offset=${offset}&limit=${limit}`);
  if (!res.ok) throw new Error("Falha ao carregar lista.");
  return res.json();
}

export async function fetchPokemon(nameOrId: string) {
  const res = await fetch(`${BASE}/pokemon/${nameOrId.toLowerCase().trim()}`);
  if (!res.ok) throw new Error("Pokémon não encontrado.");
  return res.json();
}

export function extractIdFromUrl(url: string) {
  const parts = url.split("/").filter(Boolean);
  return Number(parts[parts.length - 1]);
}
