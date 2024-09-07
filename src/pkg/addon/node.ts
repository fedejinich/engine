
import * as fs from 'fs';
import * as path from 'path';

import type {Argument} from '../addon';

const ROOT = path.join(__dirname, '..', '..', '..');
const NODE = [
  path.join(ROOT, 'build', 'lib', 'pkmn.node'),
  path.join(ROOT, 'build', 'lib', 'pkmn-showdown.node'),
];
const WASM = [
  path.join(ROOT, 'build', 'lib', 'pkmn.wasm'),
  path.join(ROOT, 'build', 'lib', 'pkmn-showdown.wasm'),
];

export async function load(showdown: boolean, addon?: Argument) {
  if (addon === undefined || typeof addon === 'string' && addon !== 'wasm') {
    try {
      return require(!addon || addon === 'node' ? NODE[+showdown] : addon).engine;
    } catch (err) {
      if (!(err instanceof Error)) return err;
      if (addon && addon !== 'node') {
        throw new Error(`Unable to load native addon: '${addon}'\n${err.message}`);
      } else {
        throw error(NODE[+showdown], err);
      }
    }
  }

  let wasm: WebAssembly.Instance;
  if (addon === 'wasm') {
    try {
      wasm = (await WebAssembly.instantiate(fs.readFileSync(WASM[+showdown]))).instance;
    } catch (err) {
      throw error(WASM[+showdown], err);
    }
  } else if (addon instanceof WebAssembly.Module) {
    try {
      wasm = (await WebAssembly.instantiate(addon));
    } catch (err) {
      if (!(err instanceof Error)) throw err;
      throw new Error(`Could not instantiate WASM module!\n${err.message}`);
    }
  } else {
    try {
      const response = (addon as Promise<Response> | URL) instanceof Promise ? addon : fetch(addon);
      wasm = (await WebAssembly.instantiateStreaming(response)).instance;
    } catch (err) {
      if (!(err instanceof Error)) throw err;
      throw new Error(`Could not instantiate WASM module!\n${err.message}`);
    }
  }

  return wasm.exports;
}

export function loadSync(showdown: boolean) {
  try {
    return require(NODE[+showdown]).engine;
  } catch {
    return undefined;
  }
}

function error(file: string, err: unknown) {
  if (!(err instanceof Error)) return err;
  const message = `Could not find ${path.basename(file)} addon`;
  return new Error(`${message} - did you run \`npx install-pkmn-engine\`?\n${err.message}`);
}
