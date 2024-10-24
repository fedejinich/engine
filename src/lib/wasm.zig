const wasm = @import("bindings/wasm.zig");

export const SHOWDOWN = wasm.options.showdown;
export const LOG = wasm.options.log;
export const CHANCE = wasm.options.chance;
export const CALC = wasm.options.calc;

export const GEN1_CHOICES_SIZE = wasm.gen1.CHOICES_SIZE;
export const GEN1_LOGS_SIZE = wasm.gen1.LOGS_SIZE;

export const GEN1_update = wasm.gen1.update;
export const GEN1_choices = wasm.gen1.choices;
