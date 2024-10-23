const pkmn = @import("pkmn.zig");

pub const pkmn_options = pkmn.Options{ .internal = true };

const wasm = pkmn.bindings.wasm;

export const SHOWDOWN = pkmn.options.showdown;
export const LOG = pkmn.options.log;
export const CHANCE = pkmn.options.chance;
export const CALC = pkmn.options.calc;

export const GEN1_CHOICES_SIZE = wasm.gen1.CHOICES_SIZE;
export const GEN1_LOGS_SIZE = wasm.gen1.LOGS_SIZE;

export const GEN1_update = wasm.gen1.update;
export const GEN1_choices = wasm.gen1.choices;
