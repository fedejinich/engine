const std = @import("std");
const pkmn = @import("pkmn");

const INPUT_ADDRESS: usize = 0xAA00_0000;
const SEED: u32 = 151;

const ExecutionResult = enum(u32) { WIN = 0, LOSE = 1, TIE = 2, BATTLE_ERROR = 3, INPUT_ERROR = 4, UNEXPECTED_ERROR = 5 };

pub export fn main() u32 {
    const result = run();
    if (result) |value| {
        return value;
    } else |_| {
        return @intFromEnum(ExecutionResult.UNEXPECTED_ERROR);
    }
}

pub fn run() !u32 {
    // parse input from INPUT_ADDRESS
    const input_ptr: *volatile u32 = @ptrFromInt(INPUT_ADDRESS);

    // this Pokemon that guarantees a victory for PlayerB in this scenario.
    // while other Pokemon could also lead to a PlayerB victory, we simplify the game logic
    // by using specific Pokemon (eg. Snorlax).
    var winning_pokemon: pkmn.gen1.helpers.Pokemon = undefined;
    if (input_ptr.* == 0x0000_1234) {
        winning_pokemon = .{ .species = .Snorlax, .moves = &.{ .BodySlam, .Reflect, .Rest, .IceBeam } };
    } else if (input_ptr.* == 0x0000_1235) {
        winning_pokemon = .{ .species = .Rattata, .moves = &.{ .SuperFang, .BodySlam, .Blizzard, .Thunderbolt } };
    } else if (input_ptr.* == 0x0000_1236) {
        winning_pokemon = .{ .species = .Exeggutor, .moves = &.{ .SleepPowder, .Psychic, .Explosion, .DoubleEdge } };
    } else {
        return @intFromEnum(ExecutionResult.INPUT_ERROR);
    }

    // use random to pick choices and initialize battle_seed
    var prng = (if (@hasDecl(std, "Random")) std.Random else std.rand).DefaultPrng.init(SEED);
    var random = prng.random();

    // preallocate a small buffer for choices
    var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

    // initialize battle
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

    var options = pkmn.battle.options(
        pkmn.protocol.NULL,
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    var c1 = pkmn.Choice{};
    var c2 = pkmn.Choice{};

    // pokemon battle
    var result = try battle.update(c1, c2, &options);
    while (result.type == .None) : (result = try battle.update(c1, c2, &options)) {
        // `battle.choices` determines possible choices by using the system PRNG to pick one at random
        const n1 = random.uintLessThan(u8, battle.choices(.P1, result.p1, &choices));
        c1 = choices[n1];
        const n2 = random.uintLessThan(u8, battle.choices(.P2, result.p2, &choices));
        c2 = choices[n2];
    }

    return switch (result.type) {
        .Win => @intFromEnum(ExecutionResult.LOSE), // won by playerA
        .Lose => @intFromEnum(ExecutionResult.WIN), // won by playerB
        .Tie => @intFromEnum(ExecutionResult.TIE),
        .Error => @intFromEnum(ExecutionResult.BATTLE_ERROR),
        else => unreachable,
    };
}
