
import {execFileSync} from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

import * as pkmn from '@pkmn/data';
import * as esbuild from 'esbuild';
import {minify} from 'html-minifier';

import * as addon from '../../pkg/addon';
import * as data from '../../pkg/data';
import * as gen1 from '../../pkg/gen1';

export * from './util';

const ROOT = path.resolve(__dirname, '..', '..', '..');
const ZIG = path.dirname(JSON.parse(execFileSync('zig', ['env'], {encoding: 'utf8'})).lib_dir);

export function error(err: string) {
  return (err
    .replaceAll(ROOT + path.sep, '')
    .replaceAll(ZIG, '$ZIG')
    .split('\n').slice(0, -3).join('\n'));
}

export function render(gens: pkmn.Generations, buffer: Buffer, err?: string, seed?: bigint) {
  if (!buffer.length) throw new Error('Invalid input');

  const view = data.Data.view(buffer);

  let offset = 0;
  const showdown = !!view.getUint8(offset++);
  const gen = gens.get(view.getUint8(offset++));
  offset += 2;

  const lookup = data.Lookup.get(gen);
  const size = data.LAYOUT[gen.num - 1].sizes.Battle;
  const deserialize = (buf: Buffer) => {
    switch (gen.num) {
      case 1: return new gen1.Battle(lookup, data.Data.view(buf), {inert: true, showdown});
      default: throw new Error(`Unsupported gen: ${gen.num}`);
    }
  };

  const battle = deserialize(buffer.subarray(offset, offset += size));

  const json: {
    num: pkmn.GenerationNum;
    species: {[id: string]: {
      name: pkmn.SpeciesName;
      num: number;
      // TODO: technically these gender fields are useless in gen 1
      genderRatio: {M: number; F: number};
      gender?: pkmn.GenderName;
    };};
    moves: {[id: string]: {
      name: pkmn.MoveName;
      num: number;
      maxpp: number;
      basePower: number;
      type: pkmn.TypeName;
    };};
  } = {num: gen.num, species: {}, moves: {}};

  let metronome = false;
  for (const side of battle.sides) {
    for (const pokemon of side.pokemon) {
      const s = gen.species.get(pokemon.species)!;
      for (const forme of [s.id, ...(s.formes ?? [])]) {
        const species = gen.species.get(forme)!;
        json.species[species.id] = {
          name: species.name,
          num: species.num,
          genderRatio: species.genderRatio,
          gender: species.gender,
        };
      }
      if (!metronome) {
        for (const ms of pokemon.moves) {
          if (ms.id === 'metronome') {
            metronome = true;
            break;
          }
          const move = gen.moves.get(ms.id)!;
          json.moves[move.id] = {
            name: move.name,
            num: move.num,
            maxpp: Math.min(move.pp / 5 * 8, gen.num === 1 ? 61 : 64),
            basePower: move.basePower,
            type: move.type,
          };
        }
      }
    }
  }
  if (metronome) {
    for (const move of gen.moves) {
      json.moves[move.id] = {
        name: move.name,
        num: move.num,
        maxpp: Math.min(move.pp / 5 * 8, gen.num === 1 ? 61 : 64),
        basePower: move.basePower,
        type: move.type,
      };
    }
  }

  // we want to use the transform API but also want to bundle
  // cant write to tmp bc then all the paths will be fucked
  const result = esbuild.buildSync({
    jsx: 'transform',
    jsxFactory: 'h',
    jsxFragment: 'Fragment',
    inject: [path.join(ROOT, 'src', 'tools', 'display', 'dom.ts')],
    entryPoints: [path.join(ROOT, 'build', 'tools', 'display', 'ui.jsx')],
    bundle: true,
    write: false,
  });

  return minify(`<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="https://pkmn.cc/favicon.ico">
    <title>@pkmn/engine</title>
    <style>${fs.readFileSync(path.join(ROOT, 'src', 'tools', 'display', 'ui.css'), 'utf8')}</style>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="content"></div>
    <script>
     window.DATA = ${JSON.stringify({
    gen: json,
    buf: buffer.toString('base64'),
    error: err && error(err),
    seed: seed?.toString(),
  })};

  ${result.outputFiles[0].text}

      for (const details of document.getElementsByTagName('details')) {
        details.addEventListener('toggle', e => {
          for (const d of details.parentElement.parentElement.getElementsByTagName('details')) {
            if (d.open !== details.open) d.open = details.open;
          }
        });
      }
    </script>
  </body>
</html>`, {minifyCSS: true, minifyJS: true});
}
