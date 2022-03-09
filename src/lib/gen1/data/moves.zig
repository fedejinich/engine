//! Code generated by `tools/generate` - manual edits will be overwritten

const std = @import("std");
const builtin = @import("builtin");

const gen1 = @import("../../gen1/data.zig");

const assert = std.debug.assert;

const Type = gen1.Type;

pub const Move = enum(u8) {
    None,
    Whirlwind,
    Roar,
    Supersonic,
    Mist,
    LeechSeed,
    PoisonPowder,
    StunSpore,
    ThunderWave,
    Toxic,
    Teleport,
    Mimic,
    Recover,
    ConfuseRay,
    LightScreen,
    Haze,
    Reflect,
    FocusEnergy,
    SoftBoiled,
    Glare,
    PoisonGas,
    Transform,
    Splash,
    Rest,
    Conversion,
    Substitute,
    SwordsDance,
    SandAttack,
    TailWhip,
    Leer,
    Growl,
    Sing,
    Growth,
    SleepPowder,
    StringShot,
    Hypnosis,
    Meditate,
    Agility,
    Screech,
    DoubleTeam,
    Harden,
    Minimize,
    Smokescreen,
    Withdraw,
    DefenseCurl,
    Barrier,
    Bide,
    Amnesia,
    Kinesis,
    LovelyKiss,
    Spore,
    Flash,
    AcidArmor,
    Sharpen,
    DoubleSlap,
    CometPunch,
    PayDay,
    RazorWind,
    Fly,
    Bind,
    DoubleKick,
    JumpKick,
    FuryAttack,
    Wrap,
    TakeDown,
    Thrash,
    DoubleEdge,
    PinMissile,
    SonicBoom,
    Submission,
    SeismicToss,
    Absorb,
    MegaDrain,
    SolarBeam,
    PetalDance,
    DragonRage,
    FireSpin,
    Dig,
    NightShade,
    SelfDestruct,
    Clamp,
    Swift,
    SkullBash,
    SpikeCannon,
    HighJumpKick,
    DreamEater,
    Barrage,
    LeechLife,
    SkyAttack,
    Psywave,
    Explosion,
    FurySwipes,
    Bonemerang,
    SuperFang,
    Struggle,
    Pound,
    KarateChop,
    MegaPunch,
    FirePunch,
    IcePunch,
    ThunderPunch,
    Scratch,
    ViseGrip,
    Guillotine,
    Cut,
    Gust,
    WingAttack,
    Slam,
    VineWhip,
    Stomp,
    MegaKick,
    RollingKick,
    Headbutt,
    HornAttack,
    HornDrill,
    Tackle,
    BodySlam,
    PoisonSting,
    Twineedle,
    Bite,
    Disable,
    Acid,
    Ember,
    Flamethrower,
    WaterGun,
    HydroPump,
    Surf,
    IceBeam,
    Blizzard,
    Psybeam,
    BubbleBeam,
    AuroraBeam,
    HyperBeam,
    Peck,
    DrillPeck,
    LowKick,
    Counter,
    Strength,
    RazorLeaf,
    ThunderShock,
    Thunderbolt,
    Thunder,
    RockThrow,
    Earthquake,
    Fissure,
    Confusion,
    Psychic,
    QuickAttack,
    Rage,
    Metronome,
    MirrorMove,
    EggBomb,
    Lick,
    Smog,
    Sludge,
    BoneClub,
    FireBlast,
    Waterfall,
    Constrict,
    Bubble,
    DizzyPunch,
    Crabhammer,
    RockSlide,
    HyperFang,
    TriAttack,
    Slash,

    // Sentinel used when Pokémon is being trapped by their opponent
    TRAPPED = 0xFF,

    pub const Data = packed struct {
        effect: Effect,
        bp: u8,
        acc: u4, // accuracy / 5 - 6
        type: Type,

        comptime {
            assert(@sizeOf(Data) == 3);
        }

        pub fn accuracy(self: Data) u8 {
            return (@as(u8, self.acc) + 6) * 5;
        }
    };

    const data = [_]Data{
        // Whirlwind
        .{
            .effect = .SwitchAndTeleport,
            .bp = 0,
            .type = .Normal,
            .acc = 11, // 85%
        },
        // Roar
        .{
            .effect = .SwitchAndTeleport,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Supersonic
        .{
            .effect = .Confusion,
            .bp = 0,
            .type = .Normal,
            .acc = 5, // 55%
        },
        // Mist
        .{
            .effect = .Mist,
            .bp = 0,
            .type = .Ice,
            .acc = 14, // 100%
        },
        // LeechSeed
        .{
            .effect = .LeechSeed,
            .bp = 0,
            .type = .Grass,
            .acc = 12, // 90%
        },
        // PoisonPowder
        .{
            .effect = .Poison,
            .bp = 0,
            .type = .Poison,
            .acc = 9, // 75%
        },
        // StunSpore
        .{
            .effect = .Paralyze,
            .bp = 0,
            .type = .Grass,
            .acc = 9, // 75%
        },
        // ThunderWave
        .{
            .effect = .Paralyze,
            .bp = 0,
            .type = .Electric,
            .acc = 14, // 100%
        },
        // Toxic
        .{
            .effect = .Poison,
            .bp = 0,
            .type = .Poison,
            .acc = 11, // 85%
        },
        // Teleport
        .{
            .effect = .SwitchAndTeleport,
            .bp = 0,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // Mimic
        .{
            .effect = .Mimic,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Recover
        .{
            .effect = .Heal,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // ConfuseRay
        .{
            .effect = .Confusion,
            .bp = 0,
            .type = .Ghost,
            .acc = 14, // 100%
        },
        // LightScreen
        .{
            .effect = .LightScreen,
            .bp = 0,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // Haze
        .{
            .effect = .Haze,
            .bp = 0,
            .type = .Ice,
            .acc = 14, // 100%
        },
        // Reflect
        .{
            .effect = .Reflect,
            .bp = 0,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // FocusEnergy
        .{
            .effect = .FocusEnergy,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // SoftBoiled
        .{
            .effect = .Heal,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Glare
        .{
            .effect = .Paralyze,
            .bp = 0,
            .type = .Normal,
            .acc = 9, // 75%
        },
        // PoisonGas
        .{
            .effect = .Poison,
            .bp = 0,
            .type = .Poison,
            .acc = 5, // 55%
        },
        // Transform
        .{
            .effect = .Transform,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Splash
        .{
            .effect = .Splash,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Rest
        .{
            .effect = .Heal,
            .bp = 0,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // Conversion
        .{
            .effect = .Conversion,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Substitute
        .{
            .effect = .Substitute,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // SwordsDance
        .{
            .effect = .AttackUp2,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // SandAttack
        .{
            .effect = .AccuracyDown1,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // TailWhip
        .{
            .effect = .DefenseDown1,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Leer
        .{
            .effect = .DefenseDown1,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Growl
        .{
            .effect = .AttackDown1,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Sing
        .{
            .effect = .Sleep,
            .bp = 0,
            .type = .Normal,
            .acc = 5, // 55%
        },
        // Growth
        .{
            .effect = .SpecialUp1,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // SleepPowder
        .{
            .effect = .Sleep,
            .bp = 0,
            .type = .Grass,
            .acc = 9, // 75%
        },
        // StringShot
        .{
            .effect = .SpeedDown1,
            .bp = 0,
            .type = .Bug,
            .acc = 13, // 95%
        },
        // Hypnosis
        .{
            .effect = .Sleep,
            .bp = 0,
            .type = .Psychic,
            .acc = 6, // 60%
        },
        // Meditate
        .{
            .effect = .AttackUp1,
            .bp = 0,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // Agility
        .{
            .effect = .SpeedUp2,
            .bp = 0,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // Screech
        .{
            .effect = .DefenseDown2,
            .bp = 0,
            .type = .Normal,
            .acc = 11, // 85%
        },
        // DoubleTeam
        .{
            .effect = .EvasionUp1,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Harden
        .{
            .effect = .DefenseUp1,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Minimize
        .{
            .effect = .EvasionUp1,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Smokescreen
        .{
            .effect = .AccuracyDown1,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Withdraw
        .{
            .effect = .DefenseUp1,
            .bp = 0,
            .type = .Water,
            .acc = 14, // 100%
        },
        // DefenseCurl
        .{
            .effect = .DefenseUp1,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Barrier
        .{
            .effect = .DefenseUp2,
            .bp = 0,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // Bide
        .{
            .effect = .Bide,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Amnesia
        .{
            .effect = .SpecialUp2,
            .bp = 0,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // Kinesis
        .{
            .effect = .AccuracyDown1,
            .bp = 0,
            .type = .Psychic,
            .acc = 10, // 80%
        },
        // LovelyKiss
        .{
            .effect = .Sleep,
            .bp = 0,
            .type = .Normal,
            .acc = 9, // 75%
        },
        // Spore
        .{
            .effect = .Sleep,
            .bp = 0,
            .type = .Grass,
            .acc = 14, // 100%
        },
        // Flash
        .{
            .effect = .AccuracyDown1,
            .bp = 0,
            .type = .Normal,
            .acc = 8, // 70%
        },
        // AcidArmor
        .{
            .effect = .DefenseUp2,
            .bp = 0,
            .type = .Poison,
            .acc = 14, // 100%
        },
        // Sharpen
        .{
            .effect = .AttackUp1,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // DoubleSlap
        .{
            .effect = .MultiHit,
            .bp = 15,
            .type = .Normal,
            .acc = 11, // 85%
        },
        // CometPunch
        .{
            .effect = .MultiHit,
            .bp = 18,
            .type = .Normal,
            .acc = 11, // 85%
        },
        // PayDay
        .{
            .effect = .PayDay,
            .bp = 40,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // RazorWind
        .{
            .effect = .Charge,
            .bp = 80,
            .type = .Normal,
            .acc = 9, // 75%
        },
        // Fly
        .{
            .effect = .Fly,
            .bp = 70,
            .type = .Flying,
            .acc = 13, // 95%
        },
        // Bind
        .{
            .effect = .Trapping,
            .bp = 15,
            .type = .Normal,
            .acc = 9, // 75%
        },
        // DoubleKick
        .{
            .effect = .DoubleHit,
            .bp = 30,
            .type = .Fighting,
            .acc = 14, // 100%
        },
        // JumpKick
        .{
            .effect = .JumpKick,
            .bp = 70,
            .type = .Fighting,
            .acc = 13, // 95%
        },
        // FuryAttack
        .{
            .effect = .MultiHit,
            .bp = 15,
            .type = .Normal,
            .acc = 11, // 85%
        },
        // Wrap
        .{
            .effect = .Trapping,
            .bp = 15,
            .type = .Normal,
            .acc = 11, // 85%
        },
        // TakeDown
        .{
            .effect = .Recoil,
            .bp = 90,
            .type = .Normal,
            .acc = 11, // 85%
        },
        // Thrash
        .{
            .effect = .Thrashing,
            .bp = 90,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // DoubleEdge
        .{
            .effect = .Recoil,
            .bp = 100,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // PinMissile
        .{
            .effect = .MultiHit,
            .bp = 14,
            .type = .Bug,
            .acc = 11, // 85%
        },
        // SonicBoom
        .{
            .effect = .SpecialDamage,
            .bp = 0,
            .type = .Normal,
            .acc = 12, // 90%
        },
        // Submission
        .{
            .effect = .Recoil,
            .bp = 80,
            .type = .Fighting,
            .acc = 10, // 80%
        },
        // SeismicToss
        .{
            .effect = .SpecialDamage,
            .bp = 1,
            .type = .Fighting,
            .acc = 14, // 100%
        },
        // Absorb
        .{
            .effect = .DrainHP,
            .bp = 20,
            .type = .Grass,
            .acc = 14, // 100%
        },
        // MegaDrain
        .{
            .effect = .DrainHP,
            .bp = 40,
            .type = .Grass,
            .acc = 14, // 100%
        },
        // SolarBeam
        .{
            .effect = .Charge,
            .bp = 120,
            .type = .Grass,
            .acc = 14, // 100%
        },
        // PetalDance
        .{
            .effect = .Thrashing,
            .bp = 70,
            .type = .Grass,
            .acc = 14, // 100%
        },
        // DragonRage
        .{
            .effect = .SpecialDamage,
            .bp = 1,
            .type = .Dragon,
            .acc = 14, // 100%
        },
        // FireSpin
        .{
            .effect = .Trapping,
            .bp = 15,
            .type = .Fire,
            .acc = 8, // 70%
        },
        // Dig
        .{
            .effect = .Charge,
            .bp = 100,
            .type = .Ground,
            .acc = 14, // 100%
        },
        // NightShade
        .{
            .effect = .SpecialDamage,
            .bp = 1,
            .type = .Ghost,
            .acc = 14, // 100%
        },
        // SelfDestruct
        .{
            .effect = .Explode,
            .bp = 130,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Clamp
        .{
            .effect = .Trapping,
            .bp = 35,
            .type = .Water,
            .acc = 9, // 75%
        },
        // Swift
        .{
            .effect = .Swift,
            .bp = 60,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // SkullBash
        .{
            .effect = .Charge,
            .bp = 100,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // SpikeCannon
        .{
            .effect = .MultiHit,
            .bp = 20,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // HighJumpKick
        .{
            .effect = .JumpKick,
            .bp = 85,
            .type = .Fighting,
            .acc = 12, // 90%
        },
        // DreamEater
        .{
            .effect = .DreamEater,
            .bp = 100,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // Barrage
        .{
            .effect = .MultiHit,
            .bp = 15,
            .type = .Normal,
            .acc = 11, // 85%
        },
        // LeechLife
        .{
            .effect = .DrainHP,
            .bp = 20,
            .type = .Bug,
            .acc = 14, // 100%
        },
        // SkyAttack
        .{
            .effect = .Charge,
            .bp = 140,
            .type = .Flying,
            .acc = 12, // 90%
        },
        // Psywave
        .{
            .effect = .SpecialDamage,
            .bp = 1,
            .type = .Psychic,
            .acc = 10, // 80%
        },
        // Explosion
        .{
            .effect = .Explode,
            .bp = 170,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // FurySwipes
        .{
            .effect = .MultiHit,
            .bp = 18,
            .type = .Normal,
            .acc = 10, // 80%
        },
        // Bonemerang
        .{
            .effect = .DoubleHit,
            .bp = 50,
            .type = .Ground,
            .acc = 12, // 90%
        },
        // SuperFang
        .{
            .effect = .SuperFang,
            .bp = 1,
            .type = .Normal,
            .acc = 12, // 90%
        },
        // Struggle
        .{
            .effect = .Recoil,
            .bp = 50,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Pound
        .{
            .effect = .None,
            .bp = 40,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // KarateChop
        .{
            .effect = .HighCritical,
            .bp = 50,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // MegaPunch
        .{
            .effect = .None,
            .bp = 80,
            .type = .Normal,
            .acc = 11, // 85%
        },
        // FirePunch
        .{
            .effect = .BurnChance1,
            .bp = 75,
            .type = .Fire,
            .acc = 14, // 100%
        },
        // IcePunch
        .{
            .effect = .FreezeChance,
            .bp = 75,
            .type = .Ice,
            .acc = 14, // 100%
        },
        // ThunderPunch
        .{
            .effect = .ParalyzeChance1,
            .bp = 75,
            .type = .Electric,
            .acc = 14, // 100%
        },
        // Scratch
        .{
            .effect = .None,
            .bp = 40,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // ViseGrip
        .{
            .effect = .None,
            .bp = 55,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Guillotine
        .{
            .effect = .OHKO,
            .bp = 0,
            .type = .Normal,
            .acc = 0, // 30%
        },
        // Cut
        .{
            .effect = .None,
            .bp = 50,
            .type = .Normal,
            .acc = 13, // 95%
        },
        // Gust
        .{
            .effect = .None,
            .bp = 40,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // WingAttack
        .{
            .effect = .None,
            .bp = 35,
            .type = .Flying,
            .acc = 14, // 100%
        },
        // Slam
        .{
            .effect = .None,
            .bp = 80,
            .type = .Normal,
            .acc = 9, // 75%
        },
        // VineWhip
        .{
            .effect = .None,
            .bp = 35,
            .type = .Grass,
            .acc = 14, // 100%
        },
        // Stomp
        .{
            .effect = .FlinchChance2,
            .bp = 65,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // MegaKick
        .{
            .effect = .None,
            .bp = 120,
            .type = .Normal,
            .acc = 9, // 75%
        },
        // RollingKick
        .{
            .effect = .FlinchChance2,
            .bp = 60,
            .type = .Fighting,
            .acc = 11, // 85%
        },
        // Headbutt
        .{
            .effect = .FlinchChance2,
            .bp = 70,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // HornAttack
        .{
            .effect = .None,
            .bp = 65,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // HornDrill
        .{
            .effect = .OHKO,
            .bp = 0,
            .type = .Normal,
            .acc = 0, // 30%
        },
        // Tackle
        .{
            .effect = .None,
            .bp = 35,
            .type = .Normal,
            .acc = 13, // 95%
        },
        // BodySlam
        .{
            .effect = .ParalyzeChance2,
            .bp = 85,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // PoisonSting
        .{
            .effect = .PoisonChance1,
            .bp = 15,
            .type = .Poison,
            .acc = 14, // 100%
        },
        // Twineedle
        .{
            .effect = .Twineedle,
            .bp = 25,
            .type = .Bug,
            .acc = 14, // 100%
        },
        // Bite
        .{
            .effect = .FlinchChance1,
            .bp = 60,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Disable
        .{
            .effect = .Disable,
            .bp = 0,
            .type = .Normal,
            .acc = 5, // 55%
        },
        // Acid
        .{
            .effect = .DefenseDownChance,
            .bp = 40,
            .type = .Poison,
            .acc = 14, // 100%
        },
        // Ember
        .{
            .effect = .BurnChance1,
            .bp = 40,
            .type = .Fire,
            .acc = 14, // 100%
        },
        // Flamethrower
        .{
            .effect = .BurnChance1,
            .bp = 95,
            .type = .Fire,
            .acc = 14, // 100%
        },
        // WaterGun
        .{
            .effect = .None,
            .bp = 40,
            .type = .Water,
            .acc = 14, // 100%
        },
        // HydroPump
        .{
            .effect = .None,
            .bp = 120,
            .type = .Water,
            .acc = 10, // 80%
        },
        // Surf
        .{
            .effect = .None,
            .bp = 95,
            .type = .Water,
            .acc = 14, // 100%
        },
        // IceBeam
        .{
            .effect = .FreezeChance,
            .bp = 95,
            .type = .Ice,
            .acc = 14, // 100%
        },
        // Blizzard
        .{
            .effect = .FreezeChance,
            .bp = 120,
            .type = .Ice,
            .acc = 12, // 90%
        },
        // Psybeam
        .{
            .effect = .ConfusionChance,
            .bp = 65,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // BubbleBeam
        .{
            .effect = .SpeedDownChance,
            .bp = 65,
            .type = .Water,
            .acc = 14, // 100%
        },
        // AuroraBeam
        .{
            .effect = .AttackDownChance,
            .bp = 65,
            .type = .Ice,
            .acc = 14, // 100%
        },
        // HyperBeam
        .{
            .effect = .HyperBeam,
            .bp = 150,
            .type = .Normal,
            .acc = 12, // 90%
        },
        // Peck
        .{
            .effect = .None,
            .bp = 35,
            .type = .Flying,
            .acc = 14, // 100%
        },
        // DrillPeck
        .{
            .effect = .None,
            .bp = 80,
            .type = .Flying,
            .acc = 14, // 100%
        },
        // LowKick
        .{
            .effect = .FlinchChance2,
            .bp = 50,
            .type = .Fighting,
            .acc = 12, // 90%
        },
        // Counter
        .{
            .effect = .None,
            .bp = 1,
            .type = .Fighting,
            .acc = 14, // 100%
        },
        // Strength
        .{
            .effect = .None,
            .bp = 80,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // RazorLeaf
        .{
            .effect = .HighCritical,
            .bp = 55,
            .type = .Grass,
            .acc = 13, // 95%
        },
        // ThunderShock
        .{
            .effect = .ParalyzeChance1,
            .bp = 40,
            .type = .Electric,
            .acc = 14, // 100%
        },
        // Thunderbolt
        .{
            .effect = .ParalyzeChance1,
            .bp = 95,
            .type = .Electric,
            .acc = 14, // 100%
        },
        // Thunder
        .{
            .effect = .ParalyzeChance1,
            .bp = 120,
            .type = .Electric,
            .acc = 8, // 70%
        },
        // RockThrow
        .{
            .effect = .None,
            .bp = 50,
            .type = .Rock,
            .acc = 7, // 65%
        },
        // Earthquake
        .{
            .effect = .None,
            .bp = 100,
            .type = .Ground,
            .acc = 14, // 100%
        },
        // Fissure
        .{
            .effect = .OHKO,
            .bp = 0,
            .type = .Ground,
            .acc = 0, // 30%
        },
        // Confusion
        .{
            .effect = .ConfusionChance,
            .bp = 50,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // Psychic
        .{
            .effect = .SpecialDownChance,
            .bp = 90,
            .type = .Psychic,
            .acc = 14, // 100%
        },
        // QuickAttack
        .{
            .effect = .None,
            .bp = 40,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Rage
        .{
            .effect = .Rage,
            .bp = 20,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Metronome
        .{
            .effect = .Metronome,
            .bp = 0,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // MirrorMove
        .{
            .effect = .MirrorMove,
            .bp = 0,
            .type = .Flying,
            .acc = 14, // 100%
        },
        // EggBomb
        .{
            .effect = .None,
            .bp = 100,
            .type = .Normal,
            .acc = 9, // 75%
        },
        // Lick
        .{
            .effect = .ParalyzeChance2,
            .bp = 20,
            .type = .Ghost,
            .acc = 14, // 100%
        },
        // Smog
        .{
            .effect = .PoisonChance2,
            .bp = 20,
            .type = .Poison,
            .acc = 8, // 70%
        },
        // Sludge
        .{
            .effect = .PoisonChance2,
            .bp = 65,
            .type = .Poison,
            .acc = 14, // 100%
        },
        // BoneClub
        .{
            .effect = .FlinchChance1,
            .bp = 65,
            .type = .Ground,
            .acc = 11, // 85%
        },
        // FireBlast
        .{
            .effect = .BurnChance2,
            .bp = 120,
            .type = .Fire,
            .acc = 11, // 85%
        },
        // Waterfall
        .{
            .effect = .None,
            .bp = 80,
            .type = .Water,
            .acc = 14, // 100%
        },
        // Constrict
        .{
            .effect = .SpeedDownChance,
            .bp = 10,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Bubble
        .{
            .effect = .SpeedDownChance,
            .bp = 20,
            .type = .Water,
            .acc = 14, // 100%
        },
        // DizzyPunch
        .{
            .effect = .None,
            .bp = 70,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Crabhammer
        .{
            .effect = .HighCritical,
            .bp = 90,
            .type = .Water,
            .acc = 11, // 85%
        },
        // RockSlide
        .{
            .effect = .None,
            .bp = 75,
            .type = .Rock,
            .acc = 12, // 90%
        },
        // HyperFang
        .{
            .effect = .FlinchChance1,
            .bp = 80,
            .type = .Normal,
            .acc = 12, // 90%
        },
        // TriAttack
        .{
            .effect = .None,
            .bp = 80,
            .type = .Normal,
            .acc = 14, // 100%
        },
        // Slash
        .{
            .effect = .HighCritical,
            .bp = 70,
            .type = .Normal,
            .acc = 14, // 100%
        },
    };

    pub const Effect = enum(u8) {
        None,
        AccuracyDown1,
        AttackDown1,
        AttackDownChance,
        AttackUp1,
        AttackUp2,
        Bide,
        BurnChance1,
        BurnChance2,
        Charge,
        Confusion,
        ConfusionChance,
        Conversion,
        DefenseDown1,
        DefenseDown2,
        DefenseDownChance,
        DefenseUp1,
        DefenseUp2,
        Disable,
        DoubleHit,
        DrainHP,
        DreamEater,
        EvasionUp1,
        Explode,
        FlinchChance1,
        FlinchChance2,
        Fly,
        FocusEnergy,
        FreezeChance,
        Haze,
        Heal,
        HighCritical,
        HyperBeam,
        JumpKick,
        LeechSeed,
        LightScreen,
        Metronome,
        Mimic,
        MirrorMove,
        Mist,
        MultiHit,
        OHKO,
        Paralyze,
        ParalyzeChance1,
        ParalyzeChance2,
        PayDay,
        Poison,
        PoisonChance1,
        PoisonChance2,
        Rage,
        Recoil,
        Reflect,
        Sleep,
        SpecialDamage,
        SpecialDownChance,
        SpecialUp1,
        SpecialUp2,
        SpeedDown1,
        SpeedDownChance,
        SpeedUp2,
        Splash,
        Substitute,
        SuperFang,
        Swift,
        SwitchAndTeleport,
        Thrashing,
        Transform,
        Trapping,
        Twineedle,

        comptime {
            assert(@sizeOf(Effect) == 1);
        }
    };

    // @test-only
    const pp_data = [_]u8{
        20, // Whirlwind
        20, // Roar
        20, // Supersonic
        30, // Mist
        10, // LeechSeed
        35, // PoisonPowder
        30, // StunSpore
        20, // ThunderWave
        10, // Toxic
        20, // Teleport
        10, // Mimic
        20, // Recover
        10, // ConfuseRay
        30, // LightScreen
        30, // Haze
        20, // Reflect
        30, // FocusEnergy
        10, // SoftBoiled
        30, // Glare
        40, // PoisonGas
        10, // Transform
        40, // Splash
        10, // Rest
        30, // Conversion
        10, // Substitute
        30, // SwordsDance
        15, // SandAttack
        30, // TailWhip
        30, // Leer
        40, // Growl
        15, // Sing
        40, // Growth
        15, // SleepPowder
        40, // StringShot
        20, // Hypnosis
        40, // Meditate
        30, // Agility
        40, // Screech
        15, // DoubleTeam
        30, // Harden
        20, // Minimize
        20, // Smokescreen
        40, // Withdraw
        40, // DefenseCurl
        30, // Barrier
        10, // Bide
        20, // Amnesia
        15, // Kinesis
        10, // LovelyKiss
        15, // Spore
        20, // Flash
        40, // AcidArmor
        30, // Sharpen
        10, // DoubleSlap
        15, // CometPunch
        20, // PayDay
        10, // RazorWind
        15, // Fly
        20, // Bind
        30, // DoubleKick
        25, // JumpKick
        20, // FuryAttack
        20, // Wrap
        20, // TakeDown
        20, // Thrash
        15, // DoubleEdge
        20, // PinMissile
        20, // SonicBoom
        25, // Submission
        20, // SeismicToss
        20, // Absorb
        10, // MegaDrain
        10, // SolarBeam
        20, // PetalDance
        10, // DragonRage
        15, // FireSpin
        10, // Dig
        15, // NightShade
        5, // SelfDestruct
        10, // Clamp
        20, // Swift
        15, // SkullBash
        15, // SpikeCannon
        20, // HighJumpKick
        15, // DreamEater
        20, // Barrage
        15, // LeechLife
        5, // SkyAttack
        15, // Psywave
        5, // Explosion
        15, // FurySwipes
        10, // Bonemerang
        10, // SuperFang
        10, // Struggle
        35, // Pound
        25, // KarateChop
        20, // MegaPunch
        15, // FirePunch
        15, // IcePunch
        15, // ThunderPunch
        35, // Scratch
        30, // ViseGrip
        5, // Guillotine
        30, // Cut
        35, // Gust
        35, // WingAttack
        20, // Slam
        10, // VineWhip
        20, // Stomp
        5, // MegaKick
        15, // RollingKick
        15, // Headbutt
        25, // HornAttack
        5, // HornDrill
        35, // Tackle
        15, // BodySlam
        35, // PoisonSting
        20, // Twineedle
        25, // Bite
        20, // Disable
        30, // Acid
        25, // Ember
        15, // Flamethrower
        25, // WaterGun
        5, // HydroPump
        15, // Surf
        10, // IceBeam
        5, // Blizzard
        20, // Psybeam
        20, // BubbleBeam
        20, // AuroraBeam
        5, // HyperBeam
        35, // Peck
        20, // DrillPeck
        20, // LowKick
        20, // Counter
        15, // Strength
        25, // RazorLeaf
        30, // ThunderShock
        15, // Thunderbolt
        10, // Thunder
        15, // RockThrow
        10, // Earthquake
        5, // Fissure
        25, // Confusion
        10, // Psychic
        30, // QuickAttack
        20, // Rage
        10, // Metronome
        20, // MirrorMove
        10, // EggBomb
        30, // Lick
        20, // Smog
        20, // Sludge
        20, // BoneClub
        5, // FireBlast
        15, // Waterfall
        35, // Constrict
        30, // Bubble
        10, // DizzyPunch
        10, // Crabhammer
        10, // RockSlide
        15, // HyperFang
        10, // TriAttack
        20, // Slash,
    };

    comptime {
        assert(@sizeOf(Move) == 1);
        assert(@sizeOf(@TypeOf(data)) == 495);
    }

    pub fn get(id: Move) Data {
        assert(id != .None);
        return data[@enumToInt(id) - 1];
    }

    pub fn residual1(id: Move) bool {
        assert(id != .None);
        return @enumToInt(id) > 0 and @enumToInt(id) <= 25;
    }

    pub fn residual2(id: Move) bool {
        assert(id != .None);
        return @enumToInt(id) > 25 and @enumToInt(id) <= 53;
    }

    pub fn special(id: Move) bool {
        assert(id != .None);
        return @enumToInt(id) > 53 and @enumToInt(id) <= 94;
    }

    // @test-only
    pub fn pp(id: Move) u8 {
        assert(builtin.is_test);
        assert(id != .None);
        return pp_data[@enumToInt(id) - 1];
    }
};
