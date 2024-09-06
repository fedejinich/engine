import * as fs from 'fs';

import {Generations} from '@pkmn/data';
import {Dex} from '@pkmn/sim';

import * as display from './display';

async function run(gens: Generations) {
  let input;
  if (process.argv.length > 2) {
    if (process.argv.length > 3) {
      console.error('Invalid input');
      process.exit(1);
    }
    input = fs.readFileSync(process.argv[2]);
  } else {
    let length = 0;
    const result: Uint8Array[] = [];
    for await (const chunk of process.stdin) {
      result.push(chunk);
      length += chunk.length;
    }
    input = Buffer.concat(result, length);
  }
  process.stdout.write(display.render(gens, input));
}

run(new Generations(Dex as any)).catch(err => {
  console.error(err.message);
  process.exit(1);
});
