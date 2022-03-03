//! Code generated by `tools/generate` - manual edits will be overwritten

const std = @import("std");

const gen1 = @import("../../gen1/data.zig");

const assert = std.debug.assert;
const Effectiveness = gen1.Effectiveness;

const S = Effectiveness.Super;
const N = Effectiveness.Neutral;
const R = Effectiveness.Resisted;
const I = Effectiveness.Immune;

pub const Type = enum(u8) {
    Normal,
    Fighting,
    Flying,
    Poison,
    Ground,
    Rock,
    Bug,
    Ghost,
    Steel,
    @"???",
    Fire,
    Water,
    Grass,
    Electric,
    Psychic,
    Ice,
    Dragon,
    Dark,

    const chart = [18][18]Effectiveness{
        [_]Effectiveness{ N, N, N, N, N, R, N, I, R, N, N, N, N, N, N, N, N, N }, // Normal
        [_]Effectiveness{ S, N, R, R, N, S, R, I, S, N, N, N, N, N, R, S, N, S }, // Fighting
        [_]Effectiveness{ N, S, N, N, N, R, S, N, R, N, N, N, S, R, N, N, N, N }, // Flying
        [_]Effectiveness{ N, N, N, R, R, R, N, R, I, N, N, N, S, N, N, N, N, N }, // Poison
        [_]Effectiveness{ N, N, I, S, N, S, R, N, S, N, S, N, R, S, N, N, N, N }, // Ground
        [_]Effectiveness{ N, R, S, N, R, N, S, N, R, N, S, N, N, N, N, S, N, N }, // Rock
        [_]Effectiveness{ N, R, R, R, N, N, N, R, R, N, R, N, S, N, S, N, N, S }, // Bug
        [_]Effectiveness{ I, N, N, N, N, N, N, S, R, N, N, N, N, N, S, N, N, R }, // Ghost
        [_]Effectiveness{ N, N, N, N, N, S, N, N, R, N, R, R, N, R, N, S, N, N }, // Steel
        [_]Effectiveness{ N, N, N, N, N, N, N, N, N, N, N, N, N, N, N, N, N, N }, // ???
        [_]Effectiveness{ N, N, N, N, N, R, S, N, S, N, R, R, S, N, N, S, R, N }, // Fire
        [_]Effectiveness{ N, N, N, N, S, S, N, N, N, N, S, R, R, N, N, N, R, N }, // Water
        [_]Effectiveness{ N, N, R, R, S, S, R, N, R, N, R, S, R, N, N, N, R, N }, // Grass
        [_]Effectiveness{ N, N, S, N, I, N, N, N, N, N, N, S, R, R, N, N, R, N }, // Electric
        [_]Effectiveness{ N, S, N, S, N, N, N, N, R, N, N, N, N, N, R, N, N, I }, // Psychic
        [_]Effectiveness{ N, N, S, N, S, N, N, N, R, N, R, R, S, N, N, R, S, N }, // Ice
        [_]Effectiveness{ N, N, N, N, N, N, N, N, R, N, N, N, N, N, N, N, S, N }, // Dragon
        [_]Effectiveness{ N, R, N, N, N, N, N, S, R, N, N, N, N, N, S, N, N, R }, // Dark
    };

    comptime {
        assert(@bitSizeOf(Type) == 8);
        assert(@sizeOf(@TypeOf(chart)) == 324);
    }

    pub fn effectiveness(t1: Type, t2: Type) Effectiveness {
        return chart[@enumToInt(t1)][@enumToInt(t2)];
    }
};

pub const Types = packed struct {
    type1: Type = .Normal,
    type2: Type = .Normal,

    comptime {
        assert(@bitSizeOf(Types) == 16);
        // TODO: Safety check workaround for ziglang/zig#2627
        assert(@bitSizeOf(Types) == @sizeOf(Types) * 8);
    }
};
