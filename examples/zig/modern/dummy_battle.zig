const std = @import("std");
const pkmn = @import("pkmn");
const common = @import("../../../src/lib/common/data.zig");

pub export fn main() u32 {
    const result = run_battle();
    if (result) |value| {
        return value;
    } else |_| {
        return 1;
    }
}

pub fn run_battle() !u32 {
    var battle = pkmn.gen1.helpers.Battle.init(
        42, // Arbitrary static seed
        &.{
            .{ .species = .Bulbasaur, .moves = &.{ .SleepPowder, .SwordsDance, .RazorLeaf, .BodySlam } },
        },
        &.{
            .{ .species = .Tauros, .moves = &.{ .BodySlam, .HyperBeam, .Blizzard, .Earthquake } },
        },
    );

    var buf: [pkmn.LOGS_SIZE]u8 = undefined;
    var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
    var options = pkmn.battle.options(
        pkmn.protocol.FixedLog{ .writer = stream.writer() },
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    // Predefined player choices
    const player1Choices = [_]pkmn.Choice{
        .{ .type = .Move, .data = 0 }, // Use Move 0
    };
    const player2Choices = [_]pkmn.Choice{
        .{ .type = .Move, .data = 2 }, // Use Move 2
    };

    _ = try battle.update(player1Choices[0], player2Choices[0], &options);

    return 0;
}
