import * as fs from 'fs';
import * as path from 'path';

import {Generations} from '@pkmn/data';
import {Dex} from '@pkmn/sim';

import * as addon from '../../pkg/addon';
import * as fuzz from '../fuzz';
import * as integration from '../integration';

const FIXTURES = path.join(__dirname, 'fixtures');
const SKIP: string[] = ['0xA99BCE90DBE18670']; // FIXME

(addon.supports(true, true) ? describe : describe.skip)('Gen 1', () => {
  const gens = new Generations(Dex as any);
  for (const file of fs.readdirSync(path.join(FIXTURES, 'gen1'))) {
    const name = file.slice(0, file.indexOf('.'));
    (SKIP.includes(name) ? test.skip : test)(`${name}`, async () => {
      if (file.endsWith('log')) {
        expect(await integration.run(gens, path.join(FIXTURES, 'gen1', file))).toBe(0);
      } else {
        const showdown = file.includes('showdown');
        expect(await fuzz.run(gens, path.join(FIXTURES, 'gen1', file), showdown, true)).toBe(true);
      }
    });
  }
});
