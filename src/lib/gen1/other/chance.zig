const std = @import("std");

const expect = std.testing.expect;
const assert = std.debug.assert;

const enabled = @import("../../common/options.zig").chance;

const Player = @import("../../common/data.zig").Player;
const Optional = @import("../../common/optional.zig").Optional;

const Move = @import("../data.zig").Move;

/// TODO
pub fn Chance(comptime Rational: type) type {
    return struct {
        const Self = @This();

        /// TODO
        probability: Rational,
        /// TODO
        actions: Actions = .{},

        /// TODO
        pub const Error = Rational.Error;
    };
}

/// Actions taken by a hypothetical "chance player" that convey information about which RNG events
/// were observed during a battle `update`. This can additionally be provided as input to the
/// `update` call to override the normal behavior of the RNG in order to force specific outcomes.
pub const Actions = extern struct {
    /// Information about the RNG activity for Player 1
    p1: Action = .{},
    /// Information about the RNG activity for Player 2
    p2: Action = .{},

    comptime {
        assert(@sizeOf(Actions) == 16);
    }

    /// TODO
    pub inline fn get(self: *Actions, player: Player) *Action {
        return if (player == .P1) &self.p1 else &self.p2;
    }
};

/// Information about the RNG that was observed during a battle `update` for a single player.
pub const Action = packed struct {
    /// Observed values of various durations. Does not influence future RNG calls.
    durations: Durations = .{},

    /// If not None, the Move to return for Rolls.metronome.
    metronome: Move = .None,
    /// If not 0, psywave - 1 should be returned as the damage roll for Rolls.psywave.
    psywave: u8 = 0,

    /// If not None, the Player to be returned by Rolls.speedTie.
    speed_tie: Optional(Player) = .None,
    /// If not 0, the roll 216 + min_damage represents the minimum roll to be returned
    /// by Rolls.damage which results in the same damage as 216 + max_damage.
    min_damage: u6 = 0,

    /// If not 0, the roll 216 + max_damage represents the maximum roll to be returned
    /// by Rolls.damage which results in the same damage as 216 + min_damage.
    max_damage: u6 = 0,
    /// If not None, the value to return for Rolls.hit.
    hit: Optional(bool) = .None,

    /// If not 0, the move slot (1-4) to return in Rolls.moveSlot.
    move_slot: u3 = 0,
    /// If not 0, the value (2-5) to return for Rolls.distribution.
    distribution: u3 = 0,
    /// If not None, the value to be returned for
    /// Rolls.{confusionChance,secondaryChance,poisonChance}.
    secondary_chance: Optional(bool) = .None,

    /// If not 0, the value to be returned by
    /// Rolls.{disableDuration,sleepDuration,confusionDuration,bideThrashDuration}.
    duration: u4 = 0,
    /// If not None, the value to be returned by Rolls.criticalHit.
    critical_hit: Optional(bool) = .None,
    /// If not None, the value to return for Rolls.{confused,paralyzed}.
    cant: Optional(bool) = .None,

    comptime {
        assert(@sizeOf(Action) == 8);
    }
};

/// Observed values for various durations that need to be tracked in order to properly
/// deduplicate transitions with a primary key.
pub const Durations = packed struct {
    /// The number of turns a Pokémon has been observed to be disabled.
    disable: u4 = 0,
    /// The number of turns a Pokémon has been observed to be sleeping.
    sleep: u4 = 0,
    /// The number of turns a Pokémon has been observed to be confused.
    confusion: u4 = 0,
    /// The number of turns a Pokémon has been observed to be storing energy / thrashing.
    bide_thrash: u4 = 0,

    comptime {
        assert(@sizeOf(Durations) == 2);
    }
};
