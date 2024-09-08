import * as fs from 'fs';

import {Generations} from '@pkmn/data';

import * as display from './display';

export async function run(gens: Generations) {
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

if (require.main === module) {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  run(new Generations(require('@pkmn/sim').Dex)).catch(err => {
    console.error(err.message);
    process.exit(1);
  });
}
