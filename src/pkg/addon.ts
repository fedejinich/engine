import {load, loadSync} from './addon/node';

import {Choice, Player, Result} from '.';

export type Argument = string | URL | WebAssembly.Module | Promise<Response>;

export interface Bindings<T extends boolean> {
  /**
   * The compile-time options the bindings were built with. showdown is special
   * cased because it changes the name of addon.
   */
  options: {showdown: T; log: boolean; chance: boolean; calc: boolean};
  /** Bindings are per-generation, Generation I is index 0. */
  bindings: Binding[];
}

export interface Binding {
  CHOICES_SIZE: number;
  LOGS_SIZE: number;
  update(battle: ArrayBuffer, c1: number, c2: number, log: ArrayBuffer | undefined): number;
  choices(battle: ArrayBuffer, player: number, request: number, options: ArrayBuffer): number;
}

const ADDONS: [Bindings<false>?, Bindings<true>?] = [];
const loading: [Promise<Bindings<false>>?, Promise<Bindings<true>>?] = [];

export async function initialize(showdown: boolean, addon?: Argument) {
  if (loading[+showdown]) {
    throw new Error(`Cannot call initialize more than once with showdown=${showdown}`);
  }
  loading[+showdown] = load(showdown, addon);
  loading[+showdown]!.then(a => {
    ADDONS[+showdown] = a;
  }).catch(() => {
    loading[+showdown] = undefined;
  });
  return loading[+showdown]?.then(() => {});
}

export function check(showdown: boolean) {
  if (!addons(showdown)[+showdown]) {
    const opts = ADDONS[+!showdown]!.options.log ? ['-log'] : [];
    if (showdown) opts.push('-Dshowdown');
    throw new Error(
      `@pkmn/engine has ${showdown ? 'not' : 'only'} been configured to support Pokémon Showdown.` +
      `\n(running \`npx install-pkmn-engine --options='${opts.join(' ')}'\` can fix this issue).`
    );
  }
}

export function supports(showdown: boolean, log?: boolean) {
  if (!addons(showdown)[+showdown]) return false;
  if (log === undefined) return true;
  return ADDONS[+showdown]!.options.log === log;
}

function addons(showdown: boolean) {
  if (ADDONS[+showdown]) return ADDONS;
  // If we havem't been initialized attempt to autoload if we're on Node
  ADDONS[+showdown] = loadSync(showdown);
  return ADDONS;
}

export function update(
  index: number,
  showdown: boolean,
  battle: ArrayBuffer,
  c1?: Choice,
  c2?: Choice,
  log?: ArrayBuffer,
) {
  return Result.decode(ADDONS[+showdown]!.bindings[index]
    .update(battle, Choice.encode(c1), Choice.encode(c2), log));
}

export function choices(
  index: number,
  showdown: boolean,
  battle: ArrayBuffer,
  player: Player,
  choice: Choice['type'],
  buf: ArrayBuffer,
) {
  const request = choice[0] === 'p' ? 0 : choice[0] === 'm' ? 1 : 2;
  const n = ADDONS[+showdown]!.bindings[index].choices(battle, +(player !== 'p1'), request, buf);
  // The top-level API signature means our hands our tied with respect to
  // writing really fast bindings here. The simplest approach would be to return
  // the ArrayBuffer the bindings populate as well as its size and only decode a
  // Choice after the selection. However, given that we need to return
  // `Choices[]` we need to decode all of them even if they're not all being
  // used which is wasteful. This shouldn't be *that* bad as its a very small
  // list, but its still wasted work. Switching the top-level API to return an
  // Iterable<Choice> doesn't help as we need both the length and the ability to
  // randomly access it, so the best way to make the current API fast would be
  // to have the Zig bindings create Choice objects directly, only that won't
  // scale well as it would require us to basically rewrite the low-level
  // choices function for each generation within node.zig. We could do something
  // really galaxy-brained and return some sort of frankenstein subclass of
  // Array backed by ArrayBuffer which would lazily decode the Choice on access,
  // but thats ultimately not worth the effort. You can't have both a high-level
  // idiomatic API and performance here, hence why the choose function below
  // exists.
  const options = new Array<Choice>(n);
  const data = new Uint8Array(buf);
  for (let i = 0; i < n; i++) options[i] = Choice.decode(data[i]);
  return options;
}

export function choose(
  index: number,
  showdown: boolean,
  battle: ArrayBuffer,
  player: Player,
  choice: Choice['type'],
  buf: ArrayBuffer,
  fn: (n: number) => number,
) {
  const request = choice[0] === 'p' ? 0 : choice[0] === 'm' ? 1 : 2;
  const n = ADDONS[+showdown]!.bindings[index].choices(battle, +(player !== 'p1'), request, buf);
  const data = new Uint8Array(buf);
  return Choice.decode(data[fn(n)]);
}

export function size(index: number, type: 'choices' | 'log') {
  const bindings = (ADDONS[1] ?? ADDONS[0])!.bindings[index];
  return type[0] === 'c' ? bindings.CHOICES_SIZE : bindings.LOGS_SIZE;
}

