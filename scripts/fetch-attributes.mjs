import fs from "fs";
import path from "path";
import { exec } from "child_process";
import fetch from "node-fetch";

const BASE_URL = "https://pokeapi.co/api/v2/pokemon";

const POKEMON_MAX = 151;
const DATA_FOLDER = path.resolve(process.cwd(), "data");

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
  const allTypes = [...new Set(attributes.flatMap((pk) => pk.types))].sort();

  fs.writeFileSync(
    `${DATA_FOLDER}/pokemon-attributes.json`,
    JSON.stringify(attributes)
  );
  fs.writeFileSync(`${DATA_FOLDER}/all-types.json`, JSON.stringify(allTypes));

  exec(`npx prettier -w ${DATA_FOLDER}/*.json`);
}

fetchAttributes();
