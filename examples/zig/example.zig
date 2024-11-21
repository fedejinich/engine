const std = @import("std");
const pkmn = @import("pkmn");

pub fn main() !void {
    const out = std.io.getStdOut().writer();
    // Set up required to be able to parse command line arguments
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Expect that we have been given a decimal seed as our only argument
    const err = std.io.getStdErr().writer();
    if (args.len != 2) {
        try err.print("Usage: {s} <seed>\n", .{args[0]});
        std.process.exit(1);
    }

    const seed = std.fmt.parseUnsigned(u64, args[1], 10) catch {
        try err.print("Invalid seed: {s}\n", .{args[1]});
        try err.print("Usage: {s} <seed>\n", .{args[0]});
        std.process.exit(1);
    };

    // Use Zig's system PRNG (`pkmn.PSRNG` is another option with a slightly different API)
    var prng = (if (@hasDecl(std, "Random")) std.Random else std.rand).DefaultPrng.init(seed);
    var random = prng.random();
    // Preallocate a small buffer for the choice options throughout the battle
    var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

    // `pkmn.gen1.Battle` can be tedious to initialize - the helper constructor used here
    // fills in missing fields with intelligent defaults to cut down on boilerplate
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
            .{ .species = .Snorlax, .moves = &.{ .BodySlam, .Reflect, .Rest, .IceBeam } },
            .{ .species = .Exeggutor, .moves = &.{ .SleepPowder, .Psychic, .Explosion, .DoubleEdge } },
            .{ .species = .Starmie, .moves = &.{ .Recover, .ThunderWave, .Blizzard, .Thunderbolt } },
            .{ .species = .Alakazam, .moves = &.{ .Psychic, .SeismicToss, .ThunderWave, .Recover } },
        },
    );

    // Preallocate a buffer for the log and create a `Log` handler which will write to it.
    // `pkmn.LOGS_SIZE` is guaranteed to be large enough for a single update. This will only be
    // written to if `-Dlog` is enabled - `pkmn.protocol.NULL` can be used to turn all of the
    // logging into no-ops. Here we are using the optimized `pkmn.protocol.ByteStream` which should
    // be more efficient than `pkmn.protocol.Log(std.io.FixedBufferStream([]u8).Writer)`, though
    // that or a `Log` backed by some other `std.io.Writer` would also work. This example doesn't
    // demonstrate how to use `-Dchance` or `-Dcalc` so we just pass the no-op implementations here
    var buf: [pkmn.LOGS_SIZE]u8 = undefined;
    var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
    var options = pkmn.battle.options(
        pkmn.protocol.FixedLog{ .writer = stream.writer() },
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    var c1 = pkmn.Choice{};
    var c2 = pkmn.Choice{};

    var result = try battle.update(c1, c2, &options);
    while (result.type == .None) : (result = try battle.update(c1, c2, &options)) {
        // Here we would do something with the log data in buf if `-Dlog` were enabled
        // _ = buf;

        // `battle.choices` determines what the possible choices are - the simplest way to choose
        // an option here is to just use the system PRNG to pick one at random
        //
        // Technically due to Generation I's Transform + Mirror Move/Metronome PP error if the
        // battle contains Pokémon with a combination of Transform, Mirror Move/Metronome, and
        // Disable its possible that there are no available choices (softlock), though this is
        // impossible here given that our example battle involves none of these moves
        const n1 = random.uintLessThan(u8, battle.choices(.P1, result.p1, &choices));
        c1 = choices[n1];
        const n2 = random.uintLessThan(u8, battle.choices(.P2, result.p2, &choices));
        c2 = choices[n2];

        // Reset the stream to cause the buffer to get reused
        stream.reset();
    }

    // The result is from the perspective of P1
    const msg = switch (result.type) {
        .Win => "won by Player A",
        .Lose => "won by Player B",
        .Tie => "ended in a tie",
        .Error => "encountered an error",
        else => unreachable,
    };

    try out.print("Battle {s} after {d} turns\n", .{ msg, battle.turn });
}
