import * as pkmn from '@pkmn/data';
import {Icons, Sprites} from '@pkmn/img';

import * as data from '../../pkg';
import {LAYOUT, LE} from '../../pkg/data';
import * as gen1 from '../../pkg/gen1';

import * as util from './util';

const POSITIONS = ['a', 'b', 'c', 'd', 'e', 'f'];
const STATS = ['hp', 'atk', 'def', 'spa', 'spd', 'spe'] as const;
const DISPLAY = {hp: 'HP', atk: 'Atk', def: 'Def', spa: 'SpA', spd: 'SpD', spe: 'Spe', spc: 'Spc'};
const VOLATILES: {[id in keyof data.Pokemon['volatiles']]: [string, 'good' | 'bad' | 'neutral']} = {
  bide: ['Bide', 'good'],
  thrashing: ['Thrashing', 'neutral'],
  flinch: ['Flinch', 'bad'],
  charging: ['Charging', 'good'],
  binding: ['Binding', 'bad'],
  invulnerable: ['Invulnerable', 'good'],
  confusion: ['Confusion', 'bad'],
  mist: ['Mist', 'good'],
  focusenergy: ['Focus Energy', 'good'],
  substitute: ['Substitute', 'good'],
  recharging: ['Recharging', 'bad'],
  rage: ['Rage', 'neutral'],
  leechseed: ['Leech Seed', 'bad'],
  lightscreen: ['Light Screen', 'good'],
  reflect: ['Reflect', 'good'],
  transform: ['Transformed', 'neutral'],
};

interface Generation {
  num: pkmn.GenerationNum;
  species: {
    get(id: pkmn.ID): Species & {id: pkmn.ID} | undefined;
    [Symbol.iterator](): Generator<Species & {id: pkmn.ID}, void>;
  };
  moves: {
    get(id: pkmn.ID): Move & {id: pkmn.ID} | undefined;
    [Symbol.iterator](): Generator<Move & {id: pkmn.ID}, void>;
  };
}

interface Species {
  name: pkmn.SpeciesName;
  num: number;
  genderRatio: {M: number; F: number};
  gender?: pkmn.GenderName;
}

interface Move {
  name: pkmn.MoveName;
  num: number;
  maxpp: number;
  basePower: number;
  type: pkmn.TypeName;
}

class Gen implements Generation {
  num: pkmn.GenerationNum;
  species: API<Species>;
  moves: API<Move>;

  constructor(json: {
    num: pkmn.GenerationNum;
    species: {[id: string]: Species};
    moves: {[id: string]: Move};
  }) {
    this.num = json.num;
    this.species = new API(json.species);
    this.moves = new API(json.moves);
  }
}

class API<T> {
  raw: {[id: string]: T};

  constructor(raw: {[id: string]: T}) {
    this.raw = raw;
  }

  get(id: pkmn.ID) {
    return {id, ...this.raw[id]};
  }

  *[Symbol.iterator]() {
    for (const id in this.raw) {
      yield this.get(id as pkmn.ID);
    }
  }
}

class SpeciesNames implements data.Info {
  gen: Generation;
  battle: data.Battle;

  constructor(gen: Generation, battle: data.Battle) {
    this.gen = gen;
    this.battle = battle;
  }

  get p1() {
    const [p1] = Array.from(this.battle.sides);
    const team = Array.from(p1.pokemon)
      .sort((a, b) => a.position - b.position)
      .map(p => ({species: p.stored.species}));
    return new data.SideInfo(this.gen, {name: 'Player 1', team});
  }

  get p2() {
    const [, p2] = Array.from(this.battle.sides);
    const team = Array.from(p2.pokemon)
      .sort((a, b) => a.position - b.position)
      .map(p => ({species: p.stored.species}));
    return new data.SideInfo(this.gen, {name: 'Player 2', team});
  }
}

interface Foo {
  result: data.Result;
  c1: data.Choice;
  c2: data.Choice;
  battle: data.Data<data.Battle>;
  parsed: data.ParsedLine[];
}

const App = ({gen, view, error, seed}: {
  gen: Generation;
  view: DataView;
  error?: string;
  seed?: bigint;
}) => {
  let offset = 0;
  const showdown = !!view.getUint8(offset += 2);
  const N = view.getUint16(offset, LE);
  offset += 2;

  const lookup = data.Lookup.get(gen);
  const size = LAYOUT[gen.num - 1].sizes.Battle;
  const deserialize = (d: DataView): data.Battle => {
    switch (gen.num) {
      case 1: return new gen1.Battle(lookup, d, {showdown});
      default: throw new Error(`Unsupported gen: ${gen.num}`);
    }
  };

  const battle = deserialize(new DataView(view.buffer, offset, offset += size));
  const names = new SpeciesNames(gen, battle);
  const log = new data.Log(gen, lookup, names);

  let partial: Partial<Foo> | undefined = undefined;
  const last: data.Data<data.Battle> | undefined = undefined;
  const frames: JSX.Element[] = [];
  while (offset < view.byteLength) {
    partial = {parsed: []};
    const it = log.parse(new DataView(view.buffer, offset))[Symbol.iterator]();
    let r = it.next();
    while (!r.done) {
      partial.parsed!.push(r.value);
      r = it.next();
    }
    offset += N || r.value;
    if (offset >= view.byteLength) break;

    partial.battle = deserialize(new DataView(view.buffer, offset, offset += size));
    if (offset >= view.byteLength) break;

    partial.result = data.Result.decode(view.getUint8(offset++));
    if (offset >= view.byteLength) break;

    partial.c1 = data.Choice.decode(view.getUint8(offset++));
    if (offset >= view.byteLength) break;

    partial.c2 = data.Choice.decode(view.getUint8(offset++));

    frames.push(<Frame frame={partial} gen={gen} showdown={showdown} last={last} />);
    partial = undefined;
  }
  frames.push(<Frame frame={partial || {}} gen={gen} showdown={showdown} last={last} />);

  return <div className='content'>
    {!!seed && <h1>0x{seed.toString(16).toUpperCase()}</h1>}
    {frames}
    {error && <pre className='error'><code>{error}</code></pre>}
  </div>;
};

const Frame = ({frame, gen, showdown, last}: {
  frame: Partial<Foo>;
  gen: Generation;
  showdown: boolean;
  last?: data.Data<data.Battle>;
}) => <div className='frame'>
  {frame.parsed && <div className='log'>
    <pre><code>${util.toText(frame.parsed)}</code></pre>
  </div>}
  {frame.battle && <Battle battle={frame.battle} gen={gen} showdown={showdown} last={last} />}
  {frame.result && <div className='sides' style={{textAlign: 'center'}}>
    <pre className='side'><code>${frame.result.p1} -&gt; ${util.pretty(frame.c1)}</code></pre>
    <pre className='side'><code>${frame.result.p2} -&gt; ${util.pretty(frame.c2)}</code></pre>
  </div>}
</div>;

const Battle = ({battle, gen, showdown, last}: {
  battle: data.Data<data.Battle>;
  gen: Generation;
  showdown: boolean;
  last?: data.Data<data.Battle>;
}) => {
  const [p1, p2] = Array.from(battle.sides);
  const [o1, o2] = last ? Array.from(last.sides) : [undefined, undefined];
  return <div className='battle'>
    {battle.turn && <div className='details'>
      <h2>Turn: {battle.turn}</h2>
      <div className="inner">
        <div><strong>Last Damage:</strong> {battle.lastDamage}</div>
        <div><strong>Seed:</strong> {battle.prng.join(', ')}</div>
      </div>
    </div>}
    <div className='sides'>
      <Side side={p1} battle={battle} player={'p1'} gen={gen} showdown={showdown} last={o1} />
      <Side side={p2} battle={battle} player={'p2'} gen={gen} showdown={showdown} last={o2} />
    </div>
  </div>;
};

const Side = ({side, battle, player, gen, showdown, last}: {
  side: data.Side;
  battle: data.Data<data.Battle>;
  player: 'p1' | 'p2';
  gen: Generation;
  showdown: boolean;
  last?: data.Side;
}) => {
  let header = undefined;
  if (battle.turn) {
    const used = side.lastUsedMove ? gen.moves.get(side.lastUsedMove)!.name : <em>None</em>;
    const selected = side.lastSelectedMove ? gen.moves.get(side.lastSelectedMove) : undefined;
    const move = selected?.name ?? <em>None</em>;
    const counterable = !!selected && selected.basePower > 0 && selected.id !== 'counter' &&
      (selected.type === 'Normal' || selected.type === 'Fighting');
    const mismatch = counterable !== side.lastMoveCounterable ? '*' : '';
    const index = side.lastMoveIndex ? ` (${side.lastMoveIndex})` : '';
    header = <div className='details'>
      <div><strong>Last Used</strong><br />{used}</div>
      <div><strong>Last Selected</strong><br />{move}{mismatch}{index}</div>
    </div>;
  }

  let active = undefined;
  if (side.active) {
    if (last) {
      for (const pokemon of last.pokemon) {
        if (pokemon.position === side.active.position) {
          active = <div className='active'>
            <Pokemon pokemon={side.active}
              battle={battle}
              active={true}
              gen={gen}
              showdown={showdown}
              last={pokemon}
            /></div>;
          break;
        }
      }
    }
  }

  let i = 0;
  let icons = [];
  const teamicons = [];
  for (const pokemon of side.pokemon) {
    if (i === 3) {
      teamicons.push(<div className='teamicons'>{icons}</div>);
      icons = [];
    }
    icons.push(<PokemonIcon pokemon={pokemon} side={player}/>);
    i++;
  }

  const party = [];
  for (const pokemon of side.pokemon) {
    party.push(<Pokemon pokemon={pokemon}
      battle={battle}
      active={false}
      gen={gen}
      showdown={showdown}
    />);
  }

  return <div className={`side ${player}`}>
    {header}
    {active}
    <details className='team'><summary>{teamicons}</summary>{party}</details>
  </div>;
};

const Pokemon = ({pokemon, battle, active, gen, showdown, last}: {
  pokemon: data.Pokemon;
  battle: data.Data<data.Battle>;
  active: boolean;
  gen: Generation;
  showdown: boolean;
  last?: data.Pokemon;
}) => {
  const ths = [];
  const tds = [];
  const stats = active ? pokemon.stats : pokemon.stored.stats;
  for (const stat of STATS) {
    if (gen.num === 1 && stat === 'spd') continue;
    ths.push(<th>{DISPLAY[gen.num === 1 && stat === 'spa' ? 'spc' : stat]}</th>);
    const boost = active ? pokemon.boosts[stat as pkmn.BoostID] : 0;
    tds.push(<td><Stat value={stats[stat as pkmn.StatID]} boost={boost} /></td>);
  }

  const boosts = active ? <div className='boosts'>
    {pokemon.boosts.accuracy &&
      <div><strong>Accuracy:</strong><Boost value={pokemon.boosts.accuracy} /></div>}
    {pokemon.boosts.evasion &&
      <div><strong>Evasion:</strong><Boost value={pokemon.boosts.evasion} /></div>}
  </div> : '';

  const lis = [];
  const moves = active ? pokemon.moves : pokemon.stored.moves;
  for (const move of moves) {
    const {name, maxpp} = gen.moves.get(move.id)!;
    const disabled = !move.pp || (move as any).disabled ? 'disabled' : '';
    const title = (move as any).disabled ? `Disabled: ${(move as any).disabled as number}` : '';
    lis.push(<li className={disabled} title={title}>{name} <small>({move.pp}/{maxpp})</small></li>);
  }

  const volatiles = [];
  for (const v in pokemon.volatiles) {
    const volatile = v as keyof data.Pokemon['volatiles'];
    const [name, type] = VOLATILES[volatile]!;
    let text = '';
    if (['binding', 'confusion', 'substitute'].includes(volatile)) {
      const narrowed = volatile as 'binding' | 'confusion' | 'substitute';
      text = (Object.values(pokemon.volatiles[narrowed]!)[0]).toString();
    } else if (volatile === 'bide') {
      const val = pokemon.volatiles[volatile]!;
      text = `${val.duration} (${val.damage})`;
    } else if (volatile === 'rage') {
      const val = pokemon.volatiles[volatile]!;
      text = val.accuracy ? val.accuracy.toString() : '';
    } else if (volatile === 'thrashing') {
      const val = pokemon.volatiles[volatile]!;
      text = `${val.duration}${val.accuracy ? ` (${val.accuracy})` : ''}`;
    } else if (volatile === 'transform') {
      const {player, slot} = pokemon.volatiles[volatile]!;
      const p = +player.charAt(1) - 1;
      let i = 0;
      for (const side of battle.sides) {
        if (i++ === p) {
          i = 1;
          for (const poke of side.pokemon) {
            if (i++ === slot) {
              text = `${player}${POSITIONS[poke.position - 1]}`;
              break;
            }
          }
          break;
        }
      }
    }
    text = (text ? `${name}: ${text}` : name).replace(' ', '&nbsp;');
    volatiles.push(<span className={`volatile ${type}`}>{text}</span>);
  }

  const position = active ? '' : <div className='position'>${POSITIONS[pokemon.position - 1]}</div>;
  return <div className='pokemon'>
    <div className='left' title={`${pokemon.hp}/${pokemon.stats.hp}`}>
      {position}
      <div className='statbar rstatbar' style={{display: 'block', opacity: 1}}>
        <PokemonNameStatus pokemon={pokemon} active={active} gen={gen} />
        <HPBar pokemon={pokemon} last={last} />
      </div>
      <PokemonSprite pokemon={pokemon} active={active} showdown={showdown} />
      <TypeIcons pokemon={pokemon} active={active} />
    </div>
    <div className='right'>
      {position}
      <div className='stats'><table><tr>{ths}</tr><tr>{tds}</tr></table>
        {boosts}
      </div>
      <div className='moves'><ul>{lis}</ul> </div>
      {active && <div className='volatiles'>{volatiles}</div>}
    </div>
  </div>;
};

const PokemonNameStatus = ({pokemon, active, gen}: {
  pokemon: data.Pokemon;
  active: boolean;
  gen: Generation;
}) => {
  const species = active ? pokemon.species : pokemon.stored.species;
  const n = gen.species.get(species)!.name;
  const name = <strong>{n}&nbsp;<small>L{pokemon.level}</small></strong>;
  return <span className='name'>
    <Status pokemon={pokemon} />
    {(active && pokemon.species !== pokemon.stored.species) ? <em>{name}</em> : name}
  </span>;
};

const HPBar = ({pokemon, last}: {pokemon: data.Pokemon; last?: data.Pokemon}) => {
  const {percent, color, style} = getHP(pokemon);
  let bar = <div className={`hp ${color}`} style={style}></div>;
  if (last && last.position === pokemon.position && pokemon.hp < last.hp) {
    const prev = getHP(last);
    bar = <div className={`prevhp ${prev.color ? 'prev' + prev.color : ''}`} style={prev.style}>
      {bar}
    </div>;
  }
  return <div className='hpbar'>{bar}<div className='hptext'>{percent}%</div></div>;
};

const Status = ({pokemon}: {pokemon: data.Pokemon}) => {
  if (!pokemon.status) return '';
  const classes = `status ${pokemon.status === 'tox' ? 'psn' : pokemon.status}`;
  let title = '';
  if (pokemon.statusData.sleep) title += `Sleep: ${pokemon.statusData.sleep}`;
  if (pokemon.status === 'tox' || pokemon.statusData.toxic) {
    title += `${title ? ' ' : ''}Toxic: ${pokemon.statusData.toxic}`;
  }
  return <span className={classes} title={title}>
    {pokemon.statusData.self ? 'slf' : pokemon.status}
  </span>;
};

const Stat = ({value, boost}: {value: number; boost: number}) => {
  if (!boost) return value.toString();
  if (boost > 0) return <span className='good'>{value} (+{boost})</span>;
  return <span className='bad'>{value} ({boost})</span>;
};

const Boost = ({value}: {value: number}) => {
  if (value > 0) return <span className='good'>+{value}</span>;
  return <span className='bad'>{value}</span>;
};

const PokemonIcon = ({pokemon, side}: {pokemon: data.Pokemon; side: 'p1' | 'p2'}) => {
  const fainted = pokemon.hp === 0;
  const i = Icons.getPokemon(pokemon.stored.species, {side, fainted, domain: 'pkmn.cc'});
  return <span style={i.css}></span>;
};

const PokemonSprite = ({pokemon, active, showdown}: {
  pokemon: data.Pokemon;
  active: boolean;
  showdown: boolean;
}) => {
  const species = active ? pokemon.species : pokemon.stored.species;
  const s = Sprites.getPokemon(species, {gen: showdown ? 'gen1' : 'gen1rb'});
  const fainted = pokemon.hp === 0;
  return <img className='sprite' src={s.url} width={s.w} height={s.h} style={{
    imageRendering: s.pixelated ? 'pixelated' : undefined,
    opacity: fainted ? 0.3 : undefined,
    filter: fainted ? 'grayscale(100%) brightness(.5)' : undefined,
  }} />;
};

const TypeIcons = ({pokemon, active}: {pokemon: data.Pokemon; active: boolean}) => {
  const types = active ? pokemon.types : pokemon.stored.types;
  const type1 = <TypeIcon type={types[0]} />;
  const type2 = types[0] !== types[1] ? <TypeIcon type={types[1]} /> : '';
  return <div className='types'>{type1}{type2}</div>;
};

const TypeIcon = ({type}: {type: pkmn.TypeName}) => {
  const i = Icons.getType(type);
  const style = {imageRendering: 'pixelated' as const};
  return <img className='icon' src={i.url} width={i.w} height={i.h} style={style} />;
};

function getHP(pokemon: data.Pokemon) {
  const ratio = pokemon.hp / pokemon.stats.hp;
  let percent = Math.ceil(ratio * 100);
  if ((percent === 100) && (ratio < 1.0)) {
    percent = 99;
  }
  const width = (pokemon.hp === 1 && pokemon.stats.hp > 45)
    ? '1px' : ratio === 1.0
      ? 'var(--hp-bar)' : `calc(${ratio} * var(--hp-bar))`;
  const color = ratio > 0.5 ? '' : ratio > 0.2 ? 'hp-yellow' : 'hp-red';
  const style = {width: width, borderRightWidth: `${percent === 100 ? 1 : 0}px;`};
  return {percent, color, style};
}

const json = JSON.parse(document.getElementById('data')!.textContent!);
const buf = Uint8Array.from(atob(json.buf), c => c.charCodeAt(0));
document.getElementById('content')!.appendChild(<App
  gen={new Gen(json.gen)}
  view={new DataView(buf.buffer, buf.byteOffset, buf.byteLength)}
  error={json.error}
  seed={json.seed && BigInt(json.seed)}
/>);
