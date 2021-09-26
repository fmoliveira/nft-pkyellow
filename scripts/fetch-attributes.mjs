import fs from "fs";
import fetch from "node-fetch";

const BASE_URL = "https://pokeapi.co/api/v2/pokemon";

const POKEMON_MAX = 151;

async function fetchAttributes() {
  const fetching = new Array(POKEMON_MAX).fill(0).map((_, index) => {
    const number = index + 1;
    return fetch(`${BASE_URL}/${number}`).then((res) => res.json());
  });
  const attributes = await (
    await Promise.all(fetching)
  ).map((pk) => ({
    id: 1,
    name: pk.name,
    types: pk.types.map((t) => t.type.name),
    moves: pk.moves.map((m) => m.move.name).slice(0, 10),
  }));

  fs.writeFileSync(
    "../data/pokemon-attributes.json",
    JSON.stringify(attributes)
  );
}

fetchAttributes();
