import {execFileSync} from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

import {Generation, Generations} from '@pkmn/data';
import {minify} from 'html-minifier';
import * as mustache from 'mustache';

import {Battle, Choice, Data, Info, Log, ParsedLine, Result, SideInfo} from '../../pkg';
import * as addon from '../../pkg/addon';
import * as data from '../../pkg/data';
import * as gen1 from '../../pkg/gen1';

const ROOT = path.resolve(__dirname, '..', '..', '..');
const ZIG = path.dirname(JSON.parse(execFileSync('zig', ['env'], {encoding: 'utf8'})).lib_dir);

class SpeciesNames implements Info {
  gen: Generation;
  battle: Battle;

  constructor(gen: Generation, battle: Battle) {
    this.gen = gen;
    this.battle = battle;
  }

  get p1() {
    const [p1] = Array.from(this.battle.sides);
    const team = Array.from(p1.pokemon)
      .sort((a, b) => a.position - b.position)
      .map(p => ({species: p.stored.species}));
    return new SideInfo(this.gen, {name: 'Player 1', team});
  }

  get p2() {
    const [, p2] = Array.from(this.battle.sides);
    const team = Array.from(p2.pokemon)
      .sort((a, b) => a.position - b.position)
      .map(p => ({species: p.stored.species}));
    return new SideInfo(this.gen, {name: 'Player 2', team});
  }
}

export interface Frame {
  result: Result;
  c1: Choice;
  c2: Choice;
  battle: Data<Battle>;
  parsed: ParsedLine[];
}

export function display(gens: Generations, buf: Buffer, err?: string, seed?: bigint) {
  if (!buf.length) throw new Error('Invalid input');

  const view = data.Data.view(buf);

  let offset = 0;
  const showdown = !!view.getUint8(offset++);
  const gen = gens.get(view.getUint8(offset++));
  const N = view.getUint16(offset, data.LE);
  offset += 2;

  const lookup = data.Lookup.get(gen);
  const size = data.LAYOUT[gen.num - 1].sizes.Battle;
  const deserialize = (b: Buffer): Battle => {
    // We don't care about the native addon, we just need to load it so other checks don't fail
    void addon.supports(true);
    switch (gen.num) {
      case 1: return new gen1.Battle(lookup, data.Data.view(b), {showdown});
      default: throw new Error(`Unsupported gen: ${gen.num}`);
    }
  };

  const battle = deserialize(buf.subarray(offset, offset += size));
  const names = new SpeciesNames(gen, battle);
  const log = new Log(gen, lookup, names);

  let partial: Partial<Frame> | undefined = undefined;
  const frames: Frame[] = [];
  while (offset < view.byteLength) {
    partial = {parsed: []};
    const it = log.parse(data.Data.view(buf.subarray(offset)))[Symbol.iterator]();
    let r = it.next();
    while (!r.done) {
      partial.parsed!.push(r.value);
      r = it.next();
    }
    offset += N || r.value;
    if (offset >= view.byteLength) break;

    partial.battle = deserialize(buf.subarray(offset, offset += size));
    if (offset >= view.byteLength) break;

    partial.result = Result.decode(buf[offset++]);
    if (offset >= view.byteLength) break;

    partial.c1 = Choice.decode(buf[offset++]);
    if (offset >= view.byteLength) break;

    partial.c2 = Choice.decode(buf[offset++]);

    frames.push(partial as Frame);
    partial = undefined;
  }

  return renderFrames(gen, showdown, err, seed, frames, partial);
}

export function renderFrames(
  gen: Generation,
  showdown: boolean,
  err: string | undefined,
  seed: bigint | undefined,
  frames: Iterable<Frame>,
  partial: Partial<Frame> = {},
) {
  const buf = [];
  if (seed) buf.push(`<h1>0x${seed.toString(16).toUpperCase()}</h1>`);

  let last: Data<Battle> | undefined = undefined;
  for (const frame of frames) {
    buf.push(displayFrame(gen, showdown, frame, last));
    last = frame.battle;
  }
  buf.push(displayFrame(gen, true, partial, last));

  if (err) buf.push(error(err));

  const template = fs.readFileSync(path.join(ROOT, 'src', 'tools', 'pkmn.html.tmpl'), 'utf8');
  return render(template, {content: buf.join('')});
}

/* eslint-disable @typescript-eslint/no-unused-vars */
function displayFrame(
  gen: Generation,
  showdown: boolean,
  partial: Partial<Frame>,
  last?: Data<Battle>,
) {
  // FIXME tsx
}

export function error(err: string) {
  const e = err
    .replaceAll(ROOT + path.sep, '')
    .replaceAll(ZIG, '$ZIG')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;')
    .replace(/\//g, '&#x2f;')
    .replace(/\n/g, '<br />')
    .split('\n').slice(0, -3).join('\n');
  return `<pre class="error"><code>${e}</pre></code>`;
}

export function render(template: string, args: any) {
  const fn = ('render' in mustache ? mustache : (mustache as any).default).render;
  return minify(fn(template, args), {minifyCSS: true, minifyJS: true});
}

export * from './util';
