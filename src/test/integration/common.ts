import {strict as assert} from 'assert';

import {Generations, Generation, GenerationNum} from '@pkmn/data';
import {Protocol} from '@pkmn/protocol';
import {PRNG, PRNGSeed, BattleStreams, ID} from '@pkmn/sim';
import {
  AIOptions, ExhaustiveRunner, ExhaustiveRunnerOptions,
  ExhaustiveRunnerPossibilites, RunnerOptions,
} from '@pkmn/sim/tools';

import * as engine from '../../pkg';
import {PatchedBattleStream, patch} from '../showdown/common';

import blocklistJSON from '../blocklist.json';

const FORMATS = ['gen1customgame'];
const BLOCKLIST = blocklistJSON as {[gen: number]: Partial<ExhaustiveRunnerPossibilites>};

class Runner {
  private readonly gen: Generation;
  private readonly format: string;
  private readonly prng: PRNG;
  private readonly p1options: AIOptions;
  private readonly p2options: AIOptions;

  constructor(gen: Generation, options: RunnerOptions) {
    this.gen = gen;
    this.format = options.format;

    this.prng = (options.prng && !Array.isArray(options.prng))
      ? options.prng : new PRNG(options.prng);

    this.p1options = fixTeam(gen, options.p1options!);
    this.p2options = fixTeam(gen, options.p2options!);
  }

  async run() {
    const rawBattleStream = new RawBattleStream(this.format);
    const streams = BattleStreams.getPlayerStreams(rawBattleStream);

    const spec = {formatid: this.format, seed: this.prng.seed};
    const p1spec = {name: 'Bot 1', ...this.p1options};
    const p2spec = {name: 'Bot 2', ...this.p2options};

    const p1 = this.p1options.createAI(streams.p2, {
      seed: this.newSeed(), move: 0.7, mega: 0.6, ...this.p1options,
    }).start();
    const p2 = this.p2options.createAI(streams.p1, {
      seed: this.newSeed(), move: 0.7, mega: 0.6, ...this.p2options,
    }).start();

    const start = streams.omniscient.write(
      `>start ${JSON.stringify(spec)}\n` +
      `>player p1 ${JSON.stringify(p1spec)}\n` +
      `>player p2 ${JSON.stringify(p2spec)}`
    );

    const buf = [];
    for await (const chunk of streams.omniscient) {
      buf.push(chunk);
    }

    await Promise.all([streams.p2.writeEnd(), p1, p2, start]);

    const options = {
      p1: {name: 'Bot 1', team: this.p1options.team!},
      p2: {name: 'Bot 2', team: this.p2options.team!},
      seed: spec.seed,
      showdown: true,
      log: true,
    };
    const battle = engine.Battle.create(this.gen, options);
    const log = new engine.Log(this.gen, engine.Lookup.get(this.gen), options);

    let c1 = engine.Choice.pass();
    let c2 = engine.Choice.pass();

    let input = 0;

    let result: engine.Result = {type: undefined, p1: 'pass', p2: 'pass'};
    for (const chunk of buf) {
      assert.equal(result.type, undefined);
      result = battle.update(c1, c2);
      if (result.type === 'win') {
        assert.equal(rawBattleStream.battle!.winner, options.p1.name);
      } else if (result.type === 'lose') {
        assert.equal(rawBattleStream.battle!.winner, options.p2.name);
      } else if (result.type === 'tie') {
        assert.equal(rawBattleStream.battle!.winner, '');
      } else if (result.type) {
        throw new Error('Battle ended in error which should be impossible with -Dshowdown');
      } else {
        assert.deepStrictEqual(parse(chunk), Array.from(log.parse(battle.log!)));
      }
      [c1, c2, input] = nextChoices(battle, result, rawBattleStream.rawInputLog, input);
    }

    assert.equal(rawBattleStream.rawInputLog.length, input);
    assert.notEqual(result.type, undefined);
  }

  // Same as PRNG#generatedSeed, only deterministic.
  // NOTE: advances this.prng's seed by 4.
  newSeed(): PRNGSeed {
    return [
      this.prng.next(0x10000),
      this.prng.next(0x10000),
      this.prng.next(0x10000),
      this.prng.next(0x10000),
    ];
  }
}

class RawBattleStream extends PatchedBattleStream {
  readonly format: string;
  readonly rawInputLog: string[];

  constructor(format: string) {
    super();
    this.format = format;
    this.rawInputLog = [];
  }

  _write(message: string) {
    this.rawInputLog.push(message);
    super._write(message);
  }
}

// TODO: can we always infer done/start/upkeep?
const SKIP = new Set([
  't:', 'gametype', 'player', 'teamsize', 'gen', 'tier',
  'rule', 'done', 'start', 'upkeep', 'debug',
]);

function parse(chunk: string) {
  const buf: Array<{args: Protocol.ArgType; kwArgs: Protocol.KWArgType}> = [];
  for (const {args, kwArgs} of Protocol.parse(chunk)) {
    if (SKIP.has(args[0])) continue;
    buf.push({args, kwArgs});
  }
  return buf;
}

const IGNORE = /^>(version|start|player)/;
const MATCH = /^>(p1|p2) (?:(pass)|((move) ([1-4]))|((switch) ([2-6])))/;
function nextChoices(battle: engine.Battle, result: engine.Result, input: string[], index: number) {
  const choices: {p1: engine.Choice | undefined; p2: engine.Choice | undefined} =
    {p1: undefined, p2: undefined};

  while (index < input.length && !(choices.p1 && choices.p2)) {
    const m = MATCH.exec(input[index]);
    if (!m) {
      if (!IGNORE.test(input[index])) {
        throw new Error(`Unexpected input ${index}: '${input[index]}'`);
      } else {
        index++;
        continue;
      }
    }
    const player = m[1] as engine.Player;
    const type = (m[2] ?? m[4] ?? m[7]) as engine.Choice['type'];
    const data = +(m[5] ?? m[8] ?? 0);

    const choice = choices[player];
    if (choice) {
      throw new Error(`Already have choice for ${player}: ` +
      `'${choice.type === 'pass' ? choice.type : `${choice.type} ${choice.data}`}' vs. ` +
      `'${type === 'pass' ? type : `${type} ${data}`}' `);
    }

    for (const choice of battle.choices(player, result)) {
      if (choice.type === type && choice.data === data) {
        choices[player] = choice;
        break;
      }
      // The RandomPlayerAI made an "unavailable" choice, in which case we simply
      // continue to the next input to determine what the *actual* choice was
    }

    index++;
  }

  const unresolved = [];
  if (!choices.p1) unresolved.push('p1');
  if (!choices.p2) unresolved.push('p2');

  if (unresolved.length) {
    throw new Error(`Unable to resolve choices for ${unresolved.join(', ')}`);
  }

  return [choices.p1!, choices.p2!, index] as const;
}

function fixTeam(gen: Generation, options: AIOptions) {
  for (const pokemon of options.team!) {
    if (gen.num === 1) {
      pokemon.ivs.spd = pokemon.ivs.spa;
      pokemon.evs.spd = pokemon.evs.spa;
      pokemon.nature = '';
    }
  }
  return options;
}
function possibilities(gen: Generation) {
  const blocked = BLOCKLIST[gen.num] || {};
  const pokemon = Array.from(gen.species).filter(p => !blocked.pokemon?.includes(p.id as ID) &&
    (p.name !== 'Pichu-Spiky-eared' && p.name.slice(0, 8) !== 'Pikachu-'));
  const items = gen.num < 2
    ? [] : Array.from(gen.items).filter(i => !blocked.items?.includes(i.id as ID));
  const abilities = gen.num < 3
    ? [] : Array.from(gen.abilities).filter(a => !blocked.abilities?.includes(a.id as ID));
  const moves = Array.from(gen.moves).filter(m => !blocked.moves?.includes(m.id as ID) &&
    (!['struggle', 'revivalblessing'].includes(m.id) &&
      (m.id === 'hiddenpower' || m.id.slice(0, 11) !== 'hiddenpower')));
  return {
    pokemon: pokemon.map(p => p.id as ID),
    items: items.map(i => i.id as ID),
    abilities: abilities.map(a => a.id as ID),
    moves: moves.map(m => m.id as ID),
  };
}

type Options = Pick<ExhaustiveRunnerOptions, 'log' | 'maxFailures' | 'cycles'> & {
  prng: PRNG | PRNGSeed;
  gen?: GenerationNum;
  duration?: number;
};

export async function run(gens: Generations, options: Options) {
  const opts: ExhaustiveRunnerOptions = {
    cycles: 1, maxFailures: 1, log: false, ...options, format: '',
  };

  let failures = 0;
  const start = Date.now();
  do {
    for (const format of FORMATS) {
      const gen = gens.get(format.charAt(3));
      if (options.gen && gen.num !== options.gen) continue;
      patch.generation(gen);
      opts.format = format;
      opts.possible = possibilities(gen);
      failures +=
        await (new ExhaustiveRunner({...opts, runner: o => new Runner(gen, o).run()}).run());
      if (opts.log) process.stdout.write('\n');
      if (failures >= opts.maxFailures!) return failures;
    }
  } while (Date.now() - start < (options.duration || 0));

  return failures;
}
