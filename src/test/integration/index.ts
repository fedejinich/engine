import 'source-map-support/register';

import {Generations} from '@pkmn/data';
import {Dex, PRNG} from '@pkmn/sim';
import minimist from 'minimist';

import {run} from './common';

(async () => {
  const gens = new Generations(Dex as any);
  const argv = minimist(process.argv.slice(2), {default: {maxFailures: 5, cycles: 10}});
  const seed = argv.seed ? argv.seed.split(',').map((s: string) => Number(s)) : null;
  await run(gens, {prng: new PRNG(seed), log: process.stdout.isTTY, ...argv});
})().catch(err => {
  console.error(err);
  process.exit(1);
});