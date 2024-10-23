const pkmn = @import("../pkmn.zig");
const std = @import("std");

const assert = std.debug.assert;

const Enum = if (@hasField(std.builtin.Type, "enum")) .@"enum" else .Enum;

pub const gen1 = struct {
    pub const CHOICES_SIZE = size(pkmn.gen1.CHOICES_SIZE);
    pub const LOGS_SIZE = size(pkmn.gen1.LOGS_SIZE);

    pub fn update(
        battle: *pkmn.gen1.Battle(pkmn.gen1.PRNG),
        c1: pkmn.Choice,
        c2: pkmn.Choice,
        options: ?[*]u8,
    ) callconv(.C) pkmn.Result {
        return (if (options) |o| result: {
            const buf = @as([*]u8, @ptrCast(o))[0..pkmn.gen1.LOGS_SIZE];
            var stream: pkmn.protocol.ByteStream = .{ .buffer = buf };
            // TODO: extract out
            var opts = pkmn.battle.options(
                pkmn.protocol.FixedLog{ .writer = stream.writer() },
                pkmn.gen1.chance.NULL,
                pkmn.gen1.calc.NULL,
            );
            break :result battle.update(c1, c2, &opts);
        } else battle.update(c1, c2, &pkmn.gen1.NULL)) catch unreachable;
    }

    pub fn choices(
        battle: *pkmn.gen1.Battle(pkmn.gen1.PRNG),
        player: u8,
        request: u8,
        buf: [*]u8,
    ) callconv(.C) u8 {
        assert(player <= @field(@typeInfo(pkmn.Player), @tagName(Enum)).fields.len);
        assert(request <= @field(@typeInfo(pkmn.Choice.Type), @tagName(Enum)).fields.len);

        const len = CHOICES_SIZE;
        return battle.choices(@enumFromInt(player), @enumFromInt(request), @ptrCast(buf[0..len]));
    }
};

fn size(n: usize) u32 {
    return std.math.ceilPowerOfTwo(u32, @as(u32, @intCast(n))) catch unreachable;
}
