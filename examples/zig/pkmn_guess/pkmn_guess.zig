const std = @import("std");
const pkmn = @import("pkmn");

const INPUT_ADDRESS: usize = 0xAA00_0000;

pub const ExecutionResult = enum(u32) {
    SUCCESS = 0,
    INPUT_ERROR = 2,
    UNEXPECTED = 1,
};

pub export fn main() u32 {
    const result = run();
    if (result) |value| {
        return value;
    } else |_| {
        return @intFromEnum(ExecutionResult.UNEXPECTED);
    }
}

pub fn run() !u32 {
    // parse input
    const input_ptr: *volatile u32 = @ptrFromInt(INPUT_ADDRESS);

    if (input_ptr.* != 0x0000_1234) {
        return @intFromEnum(ExecutionResult.INPUT_ERROR);
    }

    const winning_pokemon: pkmn.gen1.helpers.Pokemon = .{ .species = .Snorlax, .moves = &.{ .BodySlam, .Reflect, .Rest, .IceBeam } };

    // use random to pick choices and initialize battle_seed
    const seed = 51; // fixed seed makes the program deterministic
    var prng = (if (@hasDecl(std, "Random")) std.Random else std.rand).DefaultPrng.init(seed);
    var random = prng.random();

    // preallocate a small buffer for choices
    var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

    // one possible winning pokemon (by providing this pokemon we produces a victory for PlayerB)
    // technically there are more pokemons that will produce a PlayerB victory but for this small game we choose Snorlax
    var battle = pkmn.gen1.helpers.Battle.init(
        random.int(u64),
        &.{
            .{ .species = .Bulbasaur, .moves = &.{ .SleepPowder, .SwordsDance, .RazorLeaf, .BodySlam } },
            .{ .species = .Charmander, .moves = &.{ .FireBlast, .FireSpin, .Slash, .Counter } },
            .{ .species = .Squirtle, .moves = &.{ .Surf, .Blizzard, .BodySlam, .Rest } },
            .{ .species = .Pikachu, .moves = &.{ .Thunderbolt, .ThunderWave, .Surf, .SeismicToss } },
            .{ .species = .Rattata, .moves = &.{ .SuperFang, .BodySlam, .Blizzard, .Thunderbolt } },
            .{ .species = .Pidgey, .moves = &.{ .DoubleEdge, .QuickAttack, .WingAttack, .MirrorMove } },
        },
        &.{
            .{ .species = .Tauros, .moves = &.{ .BodySlam, .HyperBeam, .Blizzard, .Earthquake } },
            .{ .species = .Chansey, .moves = &.{ .Reflect, .SeismicToss, .SoftBoiled, .ThunderWave } },
            .{ .species = .Exeggutor, .moves = &.{ .SleepPowder, .Psychic, .Explosion, .DoubleEdge } },
            .{ .species = .Starmie, .moves = &.{ .Recover, .ThunderWave, .Blizzard, .Thunderbolt } },
            .{ .species = .Alakazam, .moves = &.{ .Psychic, .SeismicToss, .ThunderWave, .Recover } },
            winning_pokemon,
        },
    );

    // preallocate a buffer for the logging
    var buf: [pkmn.LOGS_SIZE]u8 = undefined;
    var stream = pkmn.protocol.ByteStream{ .buffer = &buf };

    // enable logging with using `-Dlog`
    var options = pkmn.battle.options(
        pkmn.protocol.FixedLog{ .writer = stream.writer() },
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    var c1 = pkmn.Choice{};
    var c2 = pkmn.Choice{};

    var result = try battle.update(c1, c2, &options);
    while (result.type == .None) : (result = try battle.update(c1, c2, &options)) {
        // `battle.choices` determines possible choices by using the system PRNG to pick one at random
        const n1 = random.uintLessThan(u8, battle.choices(.P1, result.p1, &choices));
        c1 = choices[n1];
        const n2 = random.uintLessThan(u8, battle.choices(.P2, result.p2, &choices));
        c2 = choices[n2];

        stream.reset();
    }

    // const msg = switch (result.type) {
    //     .Win => "won by Player A",
    //     .Lose => "won by Player B",
    //     .Tie => "ended in a tie",
    //     .Error => "encountered an error",
    //     else => unreachable,
    // };
    //
    // const out = std.io.getStdOut().writer();
    // try out.print("Battle {s} after {d} turns\n", .{ msg, battle.turn });

    return @intFromEnum(ExecutionResult.SUCCESS);
}
