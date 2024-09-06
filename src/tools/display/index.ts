
import {execFileSync} from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

import * as pkmn from '@pkmn/data';
import * as esbuild from 'esbuild';
import {minify} from 'html-minifier';

import * as data from '../../pkg/data';

export * from './util';

const ROOT = path.resolve(__dirname, '..', '..', '..');
const ZIG = path.dirname(JSON.parse(execFileSync('zig', ['env'], {encoding: 'utf8'})).lib_dir);

export function error(err: string) {
  return (err
    .replaceAll(ROOT + path.sep, '')
    .replaceAll(ZIG, '$ZIG')
    .split('\n').slice(0, -3).join('\n'));
}

export function render(gens: pkmn.Generations, buf: Buffer, err?: string, seed?: bigint) {
  if (!buf.length) throw new Error('Invalid input');

  const view = data.Data.view(buf);
  const gen = gens.get(view.getUint8(1));

  const json: {
    num: pkmn.GenerationNum;
    species: {[id: string]: {
      name: pkmn.SpeciesName;
      num: number;
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

  // metronome and forme changes fuck us

  for (const species of gen.species) {
    json.species[species.id] = {
      name: species.name,
      num: species.num,
      genderRatio: species.genderRatio,
      gender: species.gender,
    };
  }
  for (const move of gen.moves) {
    json.moves[move.id] = {
      name: move.name,
      num: move.num,
      maxpp: Math.min(move.pp / 5 * 8, gen.num === 1 ? 61 : 64),
      basePower: move.basePower,
      type: move.type,
    };
  }

  // we want to use the transform API but also want to bundle
  // cant write to tmp bc then all the paths will be fucked
  const result = esbuild.buildSync({
    jsx: 'transform',
    jsxFactory: 'h',
    jsxFragment: 'Fragment',
    // inject: ['import {h, Fragment} from \'dom\''],
    entryPoints: [path.join(ROOT, 'src', 'tools', 'display', 'ui.tsx')],
    bundle: true,
    external: ['path'],
    // platform: 'node', // TODO
    write: false,
  });

  // TODO smaller data without JSON quotes
  return minify(`<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="https://pkmn.cc/favicon.ico">
    <title>@pkmn/engine</title>
    <script>
    window.DATA = ${JSON.stringify({
    gen: json,
    buf: buf.toString('base64'),
    error: err && error(err),
    seed: seed && `${seed}n`,
  })};
  ${result.outputFiles[0].text}</script>
    <style>${fs.readFileSync(path.join(ROOT, 'src', 'tools', 'display', 'ui.css'), 'utf8')}</style>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="content"></div>
    <script>
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
