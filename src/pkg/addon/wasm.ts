import type {Binding, Bindings} from '../addon';
import {LAYOUT} from '../data';

export function toBindings<T extends boolean>(w: WebAssembly.Exports): Bindings<T> {
  return {
    options: {
      showdown: w.SHOWDOWN.valueOf(),
      log: w.LOG.valueOf(),
      chance: w.CHANCE.valueOf(),
      calc: w.CALC.valueOf(),
    },
    bindings: [toBinding(1, w)],
  };
}

function toBinding(gen: number, w: WebAssembly.Exports): Binding {
  const prefix = `GEN${gen}`;
  const size = LAYOUT[gen - 1].sizes.Battle;
  const update = w[`${prefix}_update`] as CallableFunction;
  const choices = w[`${prefix}_choices`] as CallableFunction;
  const memory = new Uint8Array((w.memory as WebAssembly.Memory).buffer);

  return {
    CHOICES_SIZE: w[`${prefix}_CHOICES_SIZE`].valueOf(),
    LOGS_SIZE: w[`${prefix}_LOGS_SIZE`].valueOf(),
    update(battle: ArrayBuffer, c1: number, c2: number, log: ArrayBuffer | undefined): number {
      memory.set(battle as any);
      if (log) {
        memory.set(log as any, size);
        return update(0, c1, c2, size);
      } else {
        return update(0, c1, c2, 0);
      }
    },
    choices(battle: ArrayBuffer, player: number, request: number, options: Uint8Array): number {
      memory.set(battle as any);
      const n = choices(0, player, request, size);
      for (let i = 0; i < n; i++) options[i] = memory[size + i];
      return n;
    },
  };
}
