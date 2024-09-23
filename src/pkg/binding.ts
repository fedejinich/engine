export interface Bindings<T extends boolean> {
  /**
   * The compile-time options the bindings were built with. showdown is special
   * cased because it changes the name of addon.
   */
  options: {showdown: T; log: boolean}; // TODO: {chance: boolean; calc: boolean; }
  /** Bindings are per-generation, Generation I is index 0. */
  bindings: Binding[];
}

interface Binding {
  CHOICES_SIZE: number;
  LOGS_SIZE: number;
  update(battle: ArrayBuffer, c1: number, c2: number, log: ArrayBuffer | undefined): number;
  choices(battle: ArrayBuffer, player: number, request: number, options: ArrayBuffer): number;
}

export function toBindings<T extends boolean>(w: WebAssembly.Exports): Bindings<T> {
  return {
    options: {
      showdown: w.SHOWDOWN.valueOf(),
      log: w.LOG.valueOf(),
      // chance: w.CHANCE.valueOf(),
      // calc: w.CALC.valueOf(),
    },
    bindings: [toBinding('GEN1', w)],
  };
}

function toBinding(prefix: string, w: WebAssembly.Exports) {
  return {
    CHOICES_SIZE: w[`${prefix}_CHOICES_SIZE`].valueOf(),
    LOGS_SIZE: w[`${prefix}_LOGS_SIZE`].valueOf(),
  } as unknown as Binding; // FIXME
}
