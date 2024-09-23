import type {Binding, Bindings} from '../addon';

export function toBindings<T extends boolean>(w: WebAssembly.Exports): Bindings<T> {
  return {
    options: {
      showdown: w.SHOWDOWN.valueOf(),
      log: w.LOG.valueOf(),
      chance: w.CHANCE.valueOf(),
      calc: w.CALC.valueOf(),
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
