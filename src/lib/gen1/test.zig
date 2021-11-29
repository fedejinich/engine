const std = @import("std");

const rng = @import("../common/rng.zig");
const util = @import("../common/util.zig");

const data = @import("data.zig");

const assert = std.debug.assert;

const Escapes = util.Escapes;

const Species = data.Species;
const Stats = data.Stats;
const Moves = data.Moves;
const MoveSlot = data.MoveSlot;

pub fn debug(value: anytype) void {
    std.debug.getStderrMutex().lock();
    defer std.debug.getStderrMutex().unlock();
    const stderr = std.io.getStdErr().writer();
    nosuspend stderr.writeByte('\n') catch return;
    nosuspend format(value, stderr) catch return;
}

fn format(value: anytype, writer: anytype) !void {
    const indent = " " ** 4;
    const T = @TypeOf(value);
    switch (T) {
        data.Battle => {
            try formatType(T, writer);
            try writer.writeAll("{\n");
            try writer.writeAll(indent ++ ".seed = ");
            try format(value.rng, writer);
            try writer.writeAll(",\n" ++ indent ++ ".turn = ");
            try formatNumber(value.turn, writer);
            if (value.last_damage != 0) {
                try writer.writeAll(",\n" ++ indent ++ ".last_damage = ");
                try formatNumber(value.last_damage, writer);
            }
            try writer.writeAll(",\n" ++ indent ++ ".sides = {\n");
            try format(value.sides[0], writer); // FIXME indent...

            // TODO sides
            // try format(value.sides, writer);

            try writer.writeAll(indent ++ "}\n}");

        },
        rng.Gen12 => {
            try formatType(T, writer);
            try writer.writeAll("{ .seed = ");
            try formatNumber(value.seed, writer);
            try writer.writeAll(" }");
        },
        else => try std.fmt.formatType(value, "any", .{}, writer, 10),
    }
}

fn formatType(comptime T: type, writer: anytype) !void {
    try writer.writeAll(Escapes.Dim);
    try writer.writeAll(@typeName(T));
    try writer.writeAll(Escapes.Reset);
}

fn formatNumber(value: anytype, writer: anytype) !void {
    try writer.writeAll(Escapes.Yellow);
    try std.fmt.format(writer, "{d}", .{value});
    try writer.writeAll(Escapes.Reset);
}

pub const Battle = struct {
    pub fn init(seed: u8, p1: []const Pokemon, p2: []const Pokemon) data.Battle {
        return .{
            .rng = rng.Gen12{ .seed = seed },
            .sides = .{ Side.init(p1), Side.init(p2) },
        };
    }

    // pub fn random(seed: u8) data.Battle {
    //     const r = rng.Gen12(seed);
    //     return .{
    //         .rng = r,
    //         .turn = 0, // TODO 0 - 1000
    //         .last_damage = 0, //TODO  1...704
    //         .sides = .{ Side.random(r.next()), Side.random(r.next()) },
    //     };
    // }
};

pub const Side = struct {
    pub fn init(ps: []const Pokemon) data.Side {
        assert(ps.len > 0 and ps.len <= 6);
        var side = data.Side{};

        var i: u4 = 0;
        while (i < ps.len) : (i += 1) {
            const p = ps[i];
            var pokemon = &side.team[i];
            pokemon.species = p.species;
            const specie = Species.get(p.species);
            inline for (comptime std.meta.fieldNames(@TypeOf(pokemon.stats))) |name| {
                @field(pokemon.stats, name) =
                    Stats(u12).calc(name, @field(specie.stats, name), 0xF, 0xFFFF, p.level);
            }
            pokemon.position = i + 1;
            assert(p.moves.len > 0 and p.moves.len <= 4);
            for (p.moves) |move, j| {
                pokemon.moves[j].id = move;
                pokemon.moves[j].pp = @truncate(u6, Moves.pp(move) / 5 * 8);
                pokemon.moves[j].pp_ups = 3;
            }
            if (p.hp) |hp| pokemon.hp = hp;
            pokemon.status = p.status;
            pokemon.types = specie.types;
            pokemon.level = p.level;
            if (i == 0) {
                var active = &side.pokemon;
                inline for (comptime std.meta.fieldNames(@TypeOf(active.stats))) |name| {
                    @field(active.stats, name) = @field(pokemon.stats, name);
                }
                active.level = pokemon.level;
                active.hp = pokemon.hp;
                active.status = pokemon.status;
                active.species = pokemon.species;
                active.types = pokemon.types;
                for (pokemon.moves) |move, j| {
                    active.moves[j] = move;
                }
            }
        }
        while (i < side.team.len) : (i += 1) {
            side.team[i].position = i + 1;
        }
        return side;
    }

    // pub fn random(seed: u8) data.Side {
    //     const r = rng.Gen12(seed);
    //     // TODO
    // }
};

pub const Pokemon = struct {
    species: Species,
    moves: []const Moves,
    hp: ?u16 = null,
    status: u8 = 0,
    level: u8 = 100,
};

test "Battle" {
    const p1 = &.{.{ .species = .Gengar, .moves = &.{ .Absorb, .Pound, .DreamEater, .Psychic } }};
    const p2 = &.{.{ .species = .Mew, .moves = &.{ .HydroPump, .Surf, .Bubble, .WaterGun } }};
    const battle = Battle.init(0, p1, p2);
    debug(battle);
}

comptime {
    _ = @import("data.zig");
}
