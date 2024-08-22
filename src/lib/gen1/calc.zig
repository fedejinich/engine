const std = @import("std");

const pkmn = @import("../pkmn.zig");

const common = @import("../common/data.zig");
const DEBUG = @import("../common/debug.zig").print;
const optional = @import("../common/optional.zig");
const protocol = @import("../common/protocol.zig");
const rational = @import("../common/rational.zig");
const util = @import("../common/util.zig");

const chance = @import("chance.zig");
const data = @import("data.zig");
const helpers = @import("helpers.zig");

const assert = std.debug.assert;

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualSlices = std.testing.expectEqualSlices;

const enabled = pkmn.options.calc;

const Player = common.Player;
const Result = common.Result;
const Choice = common.Choice;

const Optional = optional.Optional;

const Rational = rational.Rational;

const PointerType = util.PointerType;

const Actions = chance.Actions;
const Action = chance.Action;
const Chance = chance.Chance;
const Durations = chance.Durations;

const tty = true; // DEBUG
const summary = false; // DEBUG

/// Information relevant to damage calculation that occured during a Generation I battle `update`.
pub const Summaries = extern struct {
    /// Relevant information for Player 1.
    p1: Summary = .{},
    /// Relevant information for Player 2.
    p2: Summary = .{},

    comptime {
        assert(@sizeOf(Summaries) == 12);
    }

    /// Returns the `Summary` for the given `player`.
    pub fn get(self: anytype, player: Player) PointerType(@TypeOf(self), Summary) {
        assert(@typeInfo(@TypeOf(self)).Pointer.child == Summaries);
        return if (player == .P1) &self.p1 else &self.p2;
    }
};

/// Information relevant to damage calculation that occured during a Generation I battle `update`
/// for a single player.
pub const Summary = extern struct {
    /// The computed raw damage values.
    damage: Damage = .{},

    /// Intermediate raw damage values computed during a calculation.
    pub const Damage = extern struct {
        /// The base computed damage before the damage roll is applied.
        base: u16 = 0,
        /// The final computed damage that gets applied to the Pokémon. May exceed the target's HP
        // (to determine the *actual* damage done compare the target's stored HP before and after).
        final: u16 = 0,
        /// Whether higher direct damage will saturate / result in the same outcome (e.g. additional
        /// direct damage gets ignored due to it already breaking a Substitute or causing the target
        /// to faint). Note that this field does not get set in scenarios where the target would
        /// only be guaranteed to faint due to some sort of subsequent recoil or residual damage.
        capped: bool = false,

        // NOTE: 15 bits padding

        comptime {
            assert(@sizeOf(Damage) == 6);
        }
    };

    comptime {
        assert(@sizeOf(Summary) == 6);
    }
};

/// TODO
pub const Overrides = extern struct {
    /// TODO
    actions: Actions = .{},

    comptime {
        assert(@sizeOf(Overrides) == 16);
    }
};

/// Allows for forcing the value of specific RNG events during a Generation I battle `update` via
/// `overrides` and tracks `summaries` of information relevant to damage calculation.
pub const Calc = struct {
    /// Overrides the normal behavior of the RNG during an `update` to force specific outcomes.
    overrides: Overrides = .{},
    /// Information relevant to damage calculation.
    summaries: Summaries = .{},

    pub fn overridden(
        self: Calc,
        player: Player,
        comptime field: Action.Field,
    ) ?std.meta.FieldType(Action, field) {
        if (!enabled) return null;

        const overrides =
            if (player == .P1) self.overrides.actions.p1 else self.overrides.actions.p2;
        const val = @field(overrides, @tagName(field));
        return if (switch (@typeInfo(@TypeOf(val))) {
            .Enum => val != .None,
            .Int => val != 0,
            else => unreachable,
        }) val else null;
    }

    pub fn base(self: *Calc, player: Player, val: u16) void {
        if (!enabled) return;

        self.summaries.get(player).damage.base = val;
    }

    pub fn final(self: *Calc, player: Player, val: u16) void {
        if (!enabled) return;

        self.summaries.get(player).damage.final = val;
    }

    pub fn capped(self: *Calc, player: Player) void {
        if (!enabled) return;

        self.summaries.get(player).damage.capped = true;
    }
};

/// Null object pattern implementation of Generation I `Calc` which does nothing, though damage
/// calculator support should additionally be turned off entirely via `options.calc`.
pub const NULL: Null = .{};

const Null = struct {
    pub fn overridden(
        self: Null,
        player: Player,
        comptime field: Action.Field,
    ) ?std.meta.FieldType(Action, field) {
        _ = .{ self, player };
        return null;
    }

    pub fn base(self: Null, player: Player, val: u16) void {
        _ = .{ self, player, val };
    }

    pub fn final(self: Null, player: Player, val: u16) void {
        _ = .{ self, player, val };
    }

    pub fn capped(self: Null, player: Player) void {
        _ = .{ self, player };
    }
};

pub const Stats = struct {
    frontier: usize = 0,
    updates: usize = 0,
    seen: usize = 0,
    saved: usize = 0,
};

pub const Options = struct {
    durations: Durations,
    seed: ?u64 = null,
    cap: bool = false,
    metronome: bool = false,
};

pub const MAX_FRONTIER = 19;

pub fn transitions(
    battle: anytype,
    c1: Choice,
    c2: Choice,
    allocator: std.mem.Allocator,
    writer: anytype,
    options: Options,
) !?Stats {
    var stats: Stats = .{};

    const cap = options.cap;

    var seen = std.AutoHashMap(Actions, void).init(allocator);
    defer seen.deinit();
    var frontier = std.ArrayList(Actions).init(allocator);
    defer frontier.deinit();

    var opts = pkmn.battle.options(
        protocol.NULL,
        Chance(Rational(u128)){ .probability = .{} },
        Calc{},
    );

    var b = battle;
    _ = try b.update(c1, c2, &opts);

    var d = options.durations;
    try d.update(&battle, &opts.chance.probability, opts.chance.actions);

    stats.updates += 1;

    const p1 = b.side(.P1);
    const p2 = b.side(.P2);

    var p: Rational(u128) = .{ .p = 0, .q = 1 };
    try frontier.append(opts.chance.actions);

    // zig fmt: off
    for (Rolls.metronome(frontier.items[0].p1)) |p1_move| {
    for (Rolls.metronome(frontier.items[0].p2)) |p2_move| {

    if (!options.metronome and (p1_move != .None or p2_move != .None)) return null;

    var i: usize = 0;
    assert(frontier.items.len == 1);
    while (i < frontier.items.len) : (i += 1) {
        const template = frontier.items[i];

        try debug(writer, template, .{
            .shape = true,
            .color = i,
            .bold = true,
            .background = true,
            .indent = false,
        });

        var a: Actions = .{ .p1 = .{ .metronome = p1_move }, .p2 = .{ .metronome = p2_move } };

        for (Rolls.speedTie(template.p1)) |tie| { a.p1.speed_tie = tie; a.p2.speed_tie = tie;
        for (Rolls.confused(template.p1)) |p1_cfzd| { a.p1.confused = p1_cfzd;
        for (Rolls.confused(template.p2)) |p2_cfzd| { a.p2.confused = p2_cfzd;
        for (Rolls.paralyzed(template.p1, p1_cfzd)) |p1_par| { a.p1.paralyzed = p1_par;
        for (Rolls.paralyzed(template.p2, p2_cfzd)) |p2_par| { a.p2.paralyzed = p2_par;
        for (Rolls.duration(template.p1, p1_par)) |p1_dur| { a.p1.duration = p1_dur;
        for (Rolls.duration(template.p2, p2_par)) |p2_dur| { a.p2.duration = p2_dur;
        for (Rolls.hit(template.p1, p1_par)) |p1_hit| { a.p1.hit = p1_hit;
        for (Rolls.hit(template.p2, p2_par)) |p2_hit| { a.p2.hit = p2_hit;
        for (Rolls.psywave(template.p1, p1, p1_hit)) |p1_psywave| { a.p1.psywave = p1_psywave;
        for (Rolls.psywave(template.p2, p2, p2_hit)) |p2_psywave| { a.p2.psywave = p2_psywave;
        for (Rolls.moveSlot(template.p1, p1_hit)) |p1_slot| { a.p1.move_slot = p1_slot;
        for (Rolls.moveSlot(template.p2, p2_hit)) |p2_slot| { a.p2.move_slot = p2_slot;
        for (Rolls.multiHit(template.p1, p1_hit)) |p1_multi| { a.p1.multi_hit = p1_multi;
        for (Rolls.multiHit(template.p2, p2_hit)) |p2_multi| { a.p2.multi_hit = p2_multi;
        for (Rolls.secondaryChance(template.p1, p1_hit)) |p1_sec| { a.p1.secondary_chance = p1_sec;
        for (Rolls.secondaryChance(template.p2, p2_hit)) |p2_sec| { a.p2.secondary_chance = p2_sec;
        for (Rolls.criticalHit(template.p1, p1_hit)) |p1_crit| { a.p1.critical_hit = p1_crit;
        for (Rolls.criticalHit(template.p2, p2_hit)) |p2_crit| { a.p2.critical_hit = p2_crit;

        var p1_dmg = Rolls.damage(template.p1, p1_hit);
        while (p1_dmg.min < p1_dmg.max) : (p1_dmg.min += 1) {
            a.p1.damage = @intCast(p1_dmg.min);

            var p2_dmg = Rolls.damage(template.p2, p2_hit);

            const p1_min: u9 = p1_dmg.min;
            const p2_min: u9 = p2_dmg.min;

            while (p2_dmg.min < p2_dmg.max) : (p2_dmg.min += 1) {
                a.p2.damage = @intCast(p2_dmg.min);

                opts.calc.overrides.actions = a;
                opts.calc.summaries = .{};
                opts.chance = .{ .probability = .{} };
                const q = &opts.chance.probability;

                b = battle;
                _ = try b.update(c1, c2, &opts);

                d = options.durations;
                try d.update(&b, &q, opts.chance.actions);

                stats.updates += 1;

                const summaries = &opts.calc.summaries;
                const p1_max: u9 = if (p2_dmg.min != p2_min)
                    p1_dmg.min
                else
                    try Rolls.coalesce(.P1, @as(u8, @intCast(p1_dmg.min)), summaries, cap);
                const p2_max: u9 =
                    try Rolls.coalesce(.P2, @as(u8, @intCast(p2_dmg.min)), summaries, cap);

                if (opts.chance.actions.matches(template)) {
                    if (!opts.chance.actions.eql(a)) {
                        if (!summary) {
                            try debug(writer, opts.chance.actions, .{
                                .p1_max = p1_max,
                                .p2_max = p2_max,
                                .color = i,
                                .dim = true,
                            });
                        }

                        p1_dmg.min = p1_max;
                        p2_dmg.min = p2_max;
                        continue;
                    }

                    if (!summary) {
                        try debug(writer, opts.chance.actions, .{
                            .p1_max = p1_max,
                            .p2_max = p2_max,
                            .color = i,
                        });
                    }

                    for (p1_min..p1_max + 1) |p1d| {
                        for (p2_dmg.min..p2_max + 1) |p2d| {
                            var acts = opts.chance.actions;
                            acts.p1.damage = @intCast(p1d);
                            acts.p2.damage = @intCast(p2d);
                            if ((try seen.getOrPut(acts)).found_existing) {
                                err("already seen {}", .{acts}, options.seed);
                                return error.TestUnexpectedResult;
                            }
                        }
                    }

                    if (p1_max != p1_min) try q.update(p1_max - p1_min + 1, 1);
                    if (p2_max != p2_dmg.min) try q.update(p2_max - p2_dmg.min + 1, 1);
                    try p.add(q);
                    stats.saved += 1;

                    if (p.q < p.p) {
                        err("improper fraction {}", .{p}, options.seed);
                        return error.TestUnexpectedResult;
                    }
                } else {
                    if (!matches(opts.chance.actions, i, frontier.items)) {
                        try frontier.append(opts.chance.actions);

                        try debug(writer, opts.chance.actions, .{
                            .p1_max = p1_max,
                            .p2_max = p2_max,
                            .dim = true,
                            .newline = false,
                        });
                        try writer.writeAll(" → ");
                        try debug(writer, opts.chance.actions, .{
                            .shape = true,
                            .color = frontier.items.len - 1,
                            .dim = true,
                            .background = true,
                            .indent = false,
                        });
                    } else if (!summary) {
                        try debug(writer, opts.chance.actions, .{
                            .p1_max = p1_max,
                            .p2_max = p2_max,
                            .dim = true,
                        });
                    }
                }

                p1_dmg.min = p1_max;
                p2_dmg.min = p2_max;
            }

        }}}}}}}}}}}}}}}}}}}}

        if (@TypeOf(writer) != @TypeOf(std.io.null_writer)) {
            p.reduce();
            try writer.print(
                "  = {s} ({d:.2}%)\n\n",
                .{p, 100 * @as(f128, @floatFromInt(p.p)) / @as(f128, @floatFromInt(p.q))},
            );
        }

    }

    assert(frontier.items.len == i);
    stats.frontier = @max(stats.frontier, i);
    frontier.shrinkRetainingCapacity(1);

    }}
    // zig fmt: on

    stats.seen = seen.count();

    p.reduce();
    if (p.p != 1 or p.q != 1) {
        err("expected 1, found {}", .{p}, options.seed);
        return error.TestExpectedEqual;
    }

    return stats;
}

pub fn update(
    battle: anytype,
    durations: *Durations,
    c1: Choice,
    c2: Choice,
    options: anytype,
    allocator: std.mem.Allocator,
    writer: anytype,
    transition: bool,
) !Result {
    options.chance.reset();

    if (!pkmn.options.chance or !pkmn.options.calc or @TypeOf(battle.rng) != data.PRNG) {
        return battle.update(c1, c2, options);
    }

    var copy = battle.*;
    const saved = durations.*;
    const actions = options.chance.actions;

    // Perfom the actual update
    const result = battle.update(c1, c2, options);
    try durations.update(&battle, actions, &options.chance.probability);

    // Ensure we can encode the diffs in less than MAX_DIFFS bytes.
    var buf: [helpers.MAX_DIFFS]u8 = undefined;
    var stream: protocol.ByteStream = .{ .buffer = &buf };
    const n = try helpers.diff(&copy, battle, stream.writer());

    // Applying the diff to the battle should take us back to the original copy
    // of the battle (ignoring the RNG).
    var patched = battle.*;
    patched.rng = copy.rng;
    helpers.patch(&patched, buf[0..n]);
    try expectEqual(copy, patched);

    if (!pkmn.options.chance or !pkmn.options.calc) return result;

    if (transition) {
        // Ensure we can generate all transitions from the same original state
        // (we must change the battle's RNG from a FixedRNG to a PRNG because
        // the transitions function relies on RNG for discovery of states)
        if (try transitions(unfix(copy), c1, c2, allocator, writer, .{
            .durations = saved,
            .cap = true,
        })) |stats| try expect(stats.frontier <= MAX_FRONTIER);
    }

    // Demonstrate that we can produce the same state by forcing the RNG to behave the
    // same as we observed.
    var override = pkmn.battle.options(
        protocol.NULL,
        Chance(Rational(u128)){ .probability = .{} },
        Calc{ .overrides = .{ .actions = actions } },
    );
    const overridden = copy.update(c1, c2, &override);
    try expectEqual(result, overridden);
    try expectEqual(override.chance.actions, actions);

    // The actual battle excluding its RNG field should match a copy updated with
    // overridden RNG (the copy RNG may have advanced because of no-ops)
    copy.rng = battle.rng;
    try expectEqual(copy, battle.*);

    return result;
}

fn unfix(actual: anytype) data.Battle(data.PRNG) {
    return .{
        .sides = actual.sides,
        .turn = actual.turn,
        .last_damage = actual.last_damage,
        .last_moves = actual.last_moves,
        .rng = .{ .src = .{
            .seed = if (pkmn.options.showdown)
                0x12345678
            else
                .{ 123, 234, 56, 78, 9, 101, 112, 131, 4 },
        } },
    };
}

fn matches(actions: Actions, i: usize, frontier: []Actions) bool {
    for (frontier, 0..) |f, j| {
        // TODO: is skipping this redundant check worth it?
        if (i == j) continue;
        if (f.matches(actions)) return true;
    }
    return false;
}

fn err(comptime fmt: []const u8, v: anytype, seed: ?u64) void {
    const w = std.io.getStdErr().writer();
    w.print(fmt, v) catch return;
    if (seed) |s| return w.print("{}\n", .{s}) catch return;
    return w.writeByte('\n') catch return;
}

const Style = struct {
    shape: bool = false,
    p1_max: u9 = 0,
    p2_max: u9 = 0,
    color: ?usize = null,
    bold: bool = false,
    background: bool = false,
    dim: bool = false,
    newline: bool = true,
    indent: bool = true,
};

fn debug(writer: anytype, actions: Actions, style: Style) !void {
    if (style.indent) try writer.writeAll("  ");
    if (tty) {
        const mod: usize = if (style.dim) 2 else 1;
        const background: usize = if (style.background) 4 else 3;
        const color: usize = if (style.color) |c| (c % 6) + 1 else 7;

        if (style.dim or style.bold) try writer.print("\x1b[{d}m", .{mod});
        try writer.print("\x1b[{d}{d}m", .{ background, color });
        const p1 = if (style.p1_max != 0 and style.p1_max != actions.p1.damage) style.p1_max else 0;
        const p2 = if (style.p2_max != 0 and style.p2_max != actions.p2.damage) style.p2_max else 0;
        if (p1 != 0 or p2 != 0) {
            assert(!style.shape);
            try format(writer, actions, p1, p2);
        } else {
            try actions.fmt(writer, style.shape);
        }
        try writer.writeAll("\x1b[0m");
    } else {
        if (style.dim) try writer.writeAll("  ");
        try actions.fmt(writer, style.shape);
    }
    if (style.newline) try writer.writeByte('\n');
}

fn format(writer: anytype, actions: Actions, p1: u9, p2: u9) !void {
    var input: [1024]u8 = undefined;
    var output: [1024]u8 = undefined;

    var stream = std.io.fixedBufferStream(&input);
    try actions.fmt(&stream.writer(), false);
    var len = stream.getWritten().len;
    @memcpy(output[0..len], input[0..len]);

    var find: [16]u8 = undefined;
    var repl: [22]u8 = undefined;
    if (p1 != 0 and actions.p1.damage != 0) {
        const n = try std.fmt.bufPrint(&find, "P1 = (damage:{d}", .{actions.p1.damage});
        const r = try std.fmt.bufPrint(&repl, "P1 = (damage:{d}…{d}", .{ actions.p1.damage, p1 });
        assert(std.mem.replace(u8, input[0..len], n, r, output[0 .. len + 6]) == 1);
        @memcpy(input[0 .. len + 6], output[0 .. len + 6]);
        len += 6;
    }
    if (p2 != 0 and actions.p2.damage != 0) {
        const n = try std.fmt.bufPrint(&find, "P2 = (damage:{d}", .{actions.p2.damage});
        const r = try std.fmt.bufPrint(&repl, "P2 = (damage:{d}…{d}", .{ actions.p2.damage, p2 });
        assert(std.mem.replace(u8, input[0..len], n, r, output[0 .. len + 6]) == 1);
        len += 6;
    }

    try writer.writeAll(output[0..len]);
}

const NONE = @intFromEnum(Optional(bool).None);

/// Helper functions that efficiently return valid ranges for various RNG events based on the
/// state of an `Action` and other events to be used to construct a "transitions" function.
pub const Rolls = struct {
    const PLAYER_NONE = [_]Optional(Player){.None};
    const PLAYERS = [_]Optional(Player){ .P1, .P2 };

    /// Returns a slice with the correct range of values for speed ties given the `action` state.
    pub fn speedTie(action: Action) []const Optional(Player) {
        return if (action.speed_tie == .None) &PLAYER_NONE else &PLAYERS;
    }

    const BOOL_NONE = [_]Optional(bool){.None};
    const BOOLS = [_]Optional(bool){ .false, .true };

    /// Returns a slice with the correct range of values for hits given the `action` state
    /// and the state of the `parent` (whether the player's Pokémon was fully paralyzed).
    pub fn hit(action: Action, parent: Optional(bool)) []const Optional(bool) {
        if (parent == .true) return &BOOL_NONE;
        return if (action.hit == .None) &BOOL_NONE else &BOOLS;
    }

    /// Returns a slice with the correct range of values for critical hits given the `action` state
    /// and the state of the `parent` (whether the player's Pokémon's move hit).
    pub fn criticalHit(action: Action, parent: Optional(bool)) []const Optional(bool) {
        if (parent == .false) return &BOOL_NONE;
        return if (action.critical_hit == .None) &BOOL_NONE else &BOOLS;
    }

    /// Returns a slice with the correct range of values for secondary chances hits given the
    /// `action` state and the state of the `parent` (whether the player's Pokémon's move hit).
    pub fn secondaryChance(action: Action, parent: Optional(bool)) []const Optional(bool) {
        if (parent == .false) return &BOOL_NONE;
        return if (@field(action, "secondary_chance") == .None) &BOOL_NONE else &BOOLS;
    }

    /// The min and max bounds on iteration over damage rolls.
    pub const Range = struct { min: u9, max: u9 };

    /// Returns the range bounding damage rolls given the `action` state and the state of
    /// the `parent` (whether the player's Pokémon's move hit).
    pub fn damage(action: Action, parent: Optional(bool)) Range {
        return if (parent == .false or action.damage == 0)
            .{ .min = 0, .max = 1 }
        else
            .{ .min = 217, .max = 256 };
    }

    /// Returns the max damage roll which will produce the same damage as `roll`
    /// given the base damage in `summaries`.
    pub fn coalesce(player: Player, roll: u8, summaries: *Summaries, cap: bool) !u8 {
        if (roll == 0) return roll;

        const dmg = summaries.get(player.foe()).damage;
        if (dmg.base == 0 or (cap and dmg.capped)) return 255;

        // Closed form solution for max damage roll provided by Orion Taylor (taylorott)
        return @min(255, roll + ((254 - ((@as(u32, dmg.base) * roll) % 255)) / dmg.base));
    }

    /// Returns a slice with the correct range of values for confused.
    pub fn confused(action: Action) []const Optional(bool) {
        return if (action.confused == .None) &BOOL_NONE else &BOOLS;
    }

    /// Returns a slice with the correct range of values for paralysis given the `action` state
    /// and the state of the `parent` (whether the player's Pokémon was confused).
    pub fn paralyzed(action: Action, parent: Optional(bool)) []const Optional(bool) {
        if (parent == .true) return &BOOL_NONE;
        return if (action.paralyzed == .None) &BOOL_NONE else &BOOLS;
    }

    const DURATION_NONE = [_]u2{0};
    // NB: DURATION must be at least 2 because that is the maximum of the minimums for all rolls
    const DURATION = [_]u2{2};

    /// Returns a slice with a range of values for duration given the `action` state
    /// and the state of the `parent` (whether the player's Pokémon's move hit).
    pub fn duration(action: Action, parent: Optional(bool)) []const u2 {
        if (parent == .false) return &DURATION_NONE;
        return if (action.duration == 0) &DURATION_NONE else &DURATION;
    }

    const SLOT_NONE = [_]u4{0};
    const SLOT = [_]u4{ 1, 2, 3, 4 };

    /// Returns a slice with a range of values for move slots given the `action` state
    /// and the state of the `parent` (whether the player's Pokémon's move hit).
    ///
    /// These slots may or **may not be valid** as slots may be unset / have 0 PP.
    pub fn moveSlot(action: Action, parent: Optional(bool)) []const u4 {
        if (parent == .false) return &SLOT_NONE;
        return if (action.move_slot == 0) &SLOT_NONE else &SLOT;
    }

    const MULTI_NONE = [_]u4{0};
    const MULTI = [_]u4{ 2, 3, 4, 5 };

    /// Returns a slice with the correct range of values for multi hit given the `action` state
    /// and the state of the `parent` (whether the player's Pokémon's move hit).
    pub fn multiHit(action: Action, parent: Optional(bool)) []const u4 {
        if (parent == .false) return &MULTI_NONE;
        return if (action.multi_hit == 0) &MULTI_NONE else &MULTI;
    }

    const PSYWAVE_NONE = [_]u8{0};
    const PSYWAVE = init: {
        var rolls: [150]u8 = undefined;
        for (0..150) |i| rolls[i] = i + 1;
        break :init rolls;
    };

    /// Returns a slice with the correct range of values for psywave given the `action` state,
    /// the `side`, and the state of the `parent` (whether the player's Pokémon's move hit).
    pub fn psywave(
        action: Action,
        side: *data.Side,
        parent: Optional(bool),
    ) []const u8 {
        if (parent == .false) return &PSYWAVE_NONE;
        return if (action.psywave == 0)
            &PSYWAVE_NONE
        else
            PSYWAVE[0 .. @as(u16, side.stored().level) * 3 / 2];
    }

    const MOVE_NONE = [_]data.Move{.None};

    /// Returns a slice with the correct range of values for metronome given the `action` state.
    pub fn metronome(action: Action) []const data.Move {
        return if (action.metronome == .None) &MOVE_NONE else &data.Move.METRONOME;
    }
};

test "Rolls.speedTie" {
    const actions: Actions = .{ .p1 = .{ .speed_tie = .P2 } };
    try expectEqualSlices(Optional(Player), &.{ .P1, .P2 }, Rolls.speedTie(actions.p1));
    try expectEqualSlices(Optional(Player), &.{.None}, Rolls.speedTie(actions.p2));
}

test "Rolls.damage" {
    const actions: Actions = .{ .p2 = .{ .damage = 221 } };
    try expectEqual(Rolls.Range{ .min = 0, .max = 1 }, Rolls.damage(actions.p1, .None));
    try expectEqual(Rolls.Range{ .min = 217, .max = 256 }, Rolls.damage(actions.p2, .None));
    try expectEqual(Rolls.Range{ .min = 0, .max = 1 }, Rolls.damage(actions.p2, .false));
}

test "Rolls.coalesce" {
    var summaries = Summaries{ .p1 = .{ .damage = .{ .base = 74, .final = 69, .capped = true } } };
    try expectEqual(0, try Rolls.coalesce(.P2, 0, &summaries, false));
    try expectEqual(241, try Rolls.coalesce(.P2, 238, &summaries, false));
    try expectEqual(255, try Rolls.coalesce(.P2, 238, &summaries, true));
    summaries.p1.damage.final = 74;
    try expectEqual(217, try Rolls.coalesce(.P2, 217, &summaries, false));
    try expectEqual(255, try Rolls.coalesce(.P2, 217, &summaries, true));
}

test "Rolls.hit" {
    const actions: Actions = .{ .p2 = .{ .hit = .true } };
    try expectEqualSlices(Optional(bool), &.{.None}, Rolls.hit(actions.p1, .None));
    try expectEqualSlices(Optional(bool), &.{ .false, .true }, Rolls.hit(actions.p2, .None));
    try expectEqualSlices(Optional(bool), &.{.None}, Rolls.hit(actions.p2, .true));
    try expectEqualSlices(Optional(bool), &.{ .false, .true }, Rolls.hit(actions.p2, .false));
}

test "Rolls.secondaryChance" {
    const actions: Actions = .{ .p1 = .{ .secondary_chance = .true } };
    try expectEqualSlices(
        Optional(bool),
        &.{ .false, .true },
        Rolls.secondaryChance(actions.p1, .None),
    );
    try expectEqualSlices(Optional(bool), &.{.None}, Rolls.secondaryChance(actions.p1, .false));
    try expectEqualSlices(Optional(bool), &.{.None}, Rolls.secondaryChance(actions.p2, .None));
}

test "Rolls.criticalHit" {
    const actions: Actions = .{ .p1 = .{ .critical_hit = .true } };
    try expectEqualSlices(
        Optional(bool),
        &.{ .false, .true },
        Rolls.criticalHit(actions.p1, .None),
    );
    try expectEqualSlices(Optional(bool), &.{.None}, Rolls.criticalHit(actions.p1, .false));
    try expectEqualSlices(Optional(bool), &.{.None}, Rolls.criticalHit(actions.p2, .None));
}

test "Rolls.confused" {
    const actions: Actions = .{ .p2 = .{ .confused = .true } };
    try expectEqualSlices(Optional(bool), &.{.None}, Rolls.confused(actions.p1));
    try expectEqualSlices(Optional(bool), &.{ .false, .true }, Rolls.confused(actions.p2));
}

test "Rolls.paralyzed" {
    const actions: Actions = .{ .p2 = .{ .paralyzed = .true } };
    try expectEqualSlices(Optional(bool), &.{.None}, Rolls.paralyzed(actions.p1, .None));
    try expectEqualSlices(Optional(bool), &.{ .false, .true }, Rolls.paralyzed(actions.p2, .None));
    try expectEqualSlices(Optional(bool), &.{ .false, .true }, Rolls.paralyzed(actions.p2, .false));
    try expectEqualSlices(Optional(bool), &.{.None}, Rolls.paralyzed(actions.p2, .true));
}

test "Rolls.duration" {
    const actions: Actions = .{ .p2 = .{ .duration = 3 } };
    try expectEqualSlices(u2, &.{0}, Rolls.duration(actions.p1, .None));
    try expectEqualSlices(u2, &.{2}, Rolls.duration(actions.p2, .None));
    try expectEqualSlices(u2, &.{0}, Rolls.duration(actions.p2, .false));
}

test "Rolls.moveSlot" {
    const actions: Actions = .{ .p2 = .{ .move_slot = 3 } };
    try expectEqualSlices(u4, &.{0}, Rolls.moveSlot(actions.p1, .None));
    try expectEqualSlices(u4, &.{ 1, 2, 3, 4 }, Rolls.moveSlot(actions.p2, .None));
    try expectEqualSlices(u4, &.{0}, Rolls.moveSlot(actions.p2, .false));
}

test "Rolls.multiHit" {
    const actions: Actions = .{ .p2 = .{ .multi_hit = 3 } };
    try expectEqualSlices(u4, &.{0}, Rolls.multiHit(actions.p1, .None));
    try expectEqualSlices(u4, &.{ 2, 3, 4, 5 }, Rolls.multiHit(actions.p2, .None));
    try expectEqualSlices(u4, &.{0}, Rolls.multiHit(actions.p2, .false));
}

test "Rolls.metronome" {
    const actions: Actions = .{ .p2 = .{ .metronome = .Surf } };
    try expectEqualSlices(data.Move, &.{.None}, Rolls.metronome(actions.p1));
    try expectEqual(@as(data.Move, @enumFromInt(24)), Rolls.metronome(actions.p2)[23]);
}

test "Rolls.psywave" {
    const actions: Actions = .{ .p2 = .{ .psywave = 79 } };
    var side = helpers.Side.init(&[_]helpers.Pokemon{.{
        .species = .Bulbasaur,
        .level = 100,
        .moves = &[_]data.Move{.Tackle},
    }});

    try expectEqualSlices(u8, &.{0}, Rolls.psywave(actions.p1, &side, .None));
    var rolls = Rolls.psywave(actions.p2, &side, .None);
    try expectEqual(150, rolls[rolls.len - 1]);
    side.stored().level = 81;
    rolls = Rolls.psywave(actions.p2, &side, .None);
    try expectEqual(121, rolls[rolls.len - 1]);
    try expectEqualSlices(u8, &.{0}, Rolls.psywave(actions.p2, &side, .false));
}
