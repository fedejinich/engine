import 'source-map-support/register';

import * as path from 'path';

import {Generations, PokemonSet} from '@pkmn/data';
import {Dex} from '@pkmn/sim';

import {Battle, Choice} from '../pkg';

import {Move, Species, pruneMove, pruneSpecies, render} from './display';

const ROOT = path.resolve(__dirname, '..', '..');
const showdown = true;
const gens = new Generations(Dex as any);

const gen = gens.get(process.argv[2]);
const TAUROS = {
  species: 'Tauros',
  moves: ['Body Slam', 'Hyper Beam', 'Blizzard', 'Earthquake'],
} as PokemonSet;
const [p1, p2] = (() => {
  switch (gen.num) {
    case 1: return [TAUROS, TAUROS];
    default: throw new Error(`Unsupported gen: ${gen.num}`);
  }
})();
const options = {
  p1: {name: 'Player A', team: [p1]},
  p2: {name: 'Player B', team: [p2]},
  seed: [1, 2, 3, 4],
  showdown,
  log: false,
};

const species: {[id: string]: Species} = {};
for (const s of gen.species) species[s.id] = pruneSpecies(gen, s);
const moves: {[id: string]: Move} = {};
for (const m of gen.moves) moves[m.id] = pruneMove(gen, m);

const battle = Battle.create(gen, options);
battle.update(Choice.pass, Choice.pass);
process.stdout.write(render(path.join(ROOT, 'build', 'tools', 'display', 'demo.jsx'), {
  gen: {num: gen.num, species, moves},
  buf: Buffer.from((battle as any).data.buffer).toString('base64'),
  showdown,
}));
