const std = @import("std");

const pkmn = @import("pkmn");

const move = pkmn.gen1.helpers.move;
const swtch = pkmn.gen1.helpers.swtch;

pub const pkmn_options = pkmn.Options{ .internal = true };

pub fn main() !void {
    std.debug.assert(pkmn.options.calc and pkmn.options.chance);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len < 2 or args.len > 3) usageAndExit(args[0]);

    const gen = std.fmt.parseUnsigned(u8, args[1], 10) catch
        errorAndExit("gen", args[1], args[0]);
    if (gen < 1 or gen > 9) errorAndExit("gen", args[1], args[0]);

    const seed = if (args.len > 2) try std.fmt.parseUnsigned(u64, args[2], 0) else 0x1234568;

    var battle = switch (gen) {
        1 => pkmn.gen1.helpers.Battle.init(
            seed,
            // ALREADY PARALYZED
            &.{.{ .species = .Dratini, .moves = &.{.Teleport} }},
            &.{.{ .species = .Koffing, .moves = &.{ .ConfuseRay, .Teleport } }},

            // ONE DAMAGE
            // &.{.{ .species = .Wartortle, .level = 33, .moves = &.{.Scratch} }},
            // &.{.{ .species = .Rhyhorn, .moves = &.{.Flamethrower} }},

            // MAX_FRONTIER
            // &.{.{ .species = .Hitmonlee, .hp = 118, .status = PAR, .moves = &.{.RollingKick} }},
            // &.{.{ .species = .Hitmonlee, .hp = 118, .status = PAR, .moves = &.{.RollingKick} }},
        ),
        else => unreachable,
    };

    var buf: [pkmn.LOGS_SIZE]u8 = undefined;
    var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
    var options = switch (gen) {
        1 => blk: {
            var chance = pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{} };
            break :blk pkmn.battle.options(
                pkmn.protocol.FixedLog{ .writer = stream.writer() },
                &chance,
                pkmn.gen1.calc.NULL,
            );
        },
        else => unreachable,
    };
    var durations = switch (gen) {
        1 => pkmn.gen1.chance.Durations{},
        else => unreachable,
    };
    _ = try battle.update(.{}, .{}, &options);
    format(&stream);

    _ = try battle.update(move(1), move(1), &options);
    try durations.update(&battle, &options.chance.probability, options.chance.actions);
    format(&stream);
    std.debug.print("\x1b[41m{} {}\x1b[K\x1b[0m\n", .{ options.chance.actions, durations });
    options.chance.reset();

    _ = try battle.update(move(1), move(2), &options);
    try durations.update(&battle, &options.chance.probability, options.chance.actions);
    format(&stream);
    std.debug.print("\x1b[41m{} {}\x1b[K\x1b[0m\n", .{ options.chance.actions, durations });

    _ = try battle.update(move(1), move(1), &options);
    try durations.update(&battle, &options.chance.probability, options.chance.actions);
    format(&stream);
    std.debug.print("\x1b[41m{} {}\x1b[K\x1b[0m\n", .{ options.chance.actions, durations });

    _ = try battle.update(move(1), move(2), &options);
    try durations.update(&battle, &options.chance.probability, options.chance.actions);
    format(&stream);
    std.debug.print("\x1b[41m{} {}\x1b[K\x1b[0m\n", .{ options.chance.actions, durations });

    // const out = std.io.getStdOut().writer();
    // const out = std.io.null_writer;
    // const stats = try pkmn.gen1.calc.transitions(battle, move(1), move(1), allocator, out, .{
    //     .durations = durations,
    //     .cap = true,
    //     .seed = seed,
    // });
    // try out.print("{}\n", .{stats.?});
}

fn format(stream: *pkmn.protocol.ByteStream) void {
    if (!pkmn.options.log) return;
    pkmn.protocol.format(pkmn.gen1, stream.buffer[0..stream.pos], null, false); // TODO
    stream.reset();
}

fn errorAndExit(msg: []const u8, arg: []const u8, cmd: []const u8) noreturn {
    const err = std.io.getStdErr().writer();
    err.print("Invalid {s}: {s}\n", .{ msg, arg }) catch {};
    usageAndExit(cmd);
}

fn usageAndExit(cmd: []const u8) noreturn {
    const err = std.io.getStdErr().writer();
    err.print("Usage: {s} <GEN> <SEED?>\n", .{cmd}) catch {};
    std.process.exit(1);
}
