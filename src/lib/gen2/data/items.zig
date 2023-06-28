//! Code generated by `tools/generate` - manual edits will be overwritten

const std = @import("std");

const data = @import("../../gen2/data.zig");

const assert = std.debug.assert;

const Type = data.Type;

/// Representation of a held item in Generation II Pokémon.
pub const Item = enum(u8) {
    None,
    PinkBow, // Normal
    BlackBelt, // Fighting
    SharpBeak, // Flying
    PoisonBarb, // Poison
    SoftSand, // Ground
    HardStone, // Rock
    SilverPowder, // Bug
    SpellTag, // Ghost
    MetalCoat, // Steel
    PolkadotBow, // ??? (Normal)
    Charcoal, // Fire
    MysticWater, // Water
    MiracleSeed, // Grass
    Magnet, // Electric
    TwistedSpoon, // Psychic
    NeverMeltIce, // Ice
    DragonScale, // Dragon
    BlackGlasses, // Dark
    BrightPowder, // BrightPowder
    MetalPowder, // MetalPowder
    QuickClaw, // QuickClaw
    KingsRock, // Flinch
    Stick,
    ThickClub,
    FocusBand, // FocusBand
    BerryJuice, // Berry
    ScopeLens, // CriticalUp
    Leftovers, // Leftovers
    BerserkGene,
    LightBall,
    PSNCureBerry, // HealPoison
    PRZCureBerry, // HealParalyze
    BurntBerry, // HealFreeze
    IceBerry, // HealBurn
    BitterBerry, // HealConfusion
    MintBerry, // HealSleep
    MiracleBerry, // HealStatus
    MysteryBerry, // RestorePP
    Berry, // Berry
    GoldBerry, // Berry
    MasterBall,
    UltraBall,
    GreatBall,
    PokeBall,
    MoonStone,
    FireStone,
    ThunderStone,
    WaterStone,
    LuckyPunch,
    LeafStone,
    DragonFang,
    HeavyBall,
    LevelBall,
    LureBall,
    FastBall,
    FriendBall,
    MoonBall,
    LoveBall,
    SunStone,
    UpGrade,
    // Pokémon Showdown excludes the following items (minus "Mail")
    FlowerMail,
    SurfMail,
    LightBlueMail,
    PortrailMail,
    LovelyMail,
    EonMail,
    MorphMail,
    BlueSkyMail,
    MusicMail,
    MirageMail,
    TownMap,
    Antidote,
    BurnHeal,
    IceHeal,
    Awakening,
    ParylzeHeal,
    FullRestore,
    MaxPotion,
    HyperPotion,
    SuperPotion,
    Potion,
    EscapeRope,
    Repel,
    MaxElixir,
    HPUp,
    Protein,
    Iron,
    Carbos,
    Calcium,
    RareCandy,
    XAccuracy,
    Nugget,
    PokeDoll,
    FullHeal,
    Revive,
    MaxRevive,
    GuardSpec,
    SuperRepel,
    MaxRepel,
    DireHit,
    FreshWater,
    SodaPop,
    Lemonade,
    XAttack,
    XDefend,
    XSpeed,
    XSpecial,
    PokeFlute,
    ExpShare,
    SilverLeaf,
    PPUp,
    Ether,
    MaxEther,
    Elixir,
    MoomooMilk,
    GoldLeaf,
    RedApricorn,
    TinyMushroom,
    BigMushroom,
    BlueApricorn,
    AmuletCoin,
    YellowApricorn,
    GreenApricorn,
    CleanseTag,
    WhiteApricorn,
    BlackApricorn,
    PinkApricorn,
    SlowpokeTail,
    SmokeBall,
    Pearl,
    BigPearl,
    Everstone,
    RageCandyBar,
    EnergyPowder,
    EnergyRoot,
    HealPowder,
    RevivalHerb,
    LuckyEgg,
    Stardust,
    StarPiece,
    SacredAsh,
    NormalBox,
    GorgeousBox,
    ParkBall,
    BrickPiece,
    TM01,
    TM02,
    TM03,
    TM04,
    TM05,
    TM06,
    TM07,
    TM08,
    TM09,
    TM10,
    TM11,
    TM12,
    TM13,
    TM14,
    TM15,
    TM16,
    TM17,
    TM18,
    TM19,
    TM20,
    TM21,
    TM22,
    TM23,
    TM24,
    TM25,
    TM26,
    TM27,
    TM28,
    TM29,
    TM30,
    TM31,
    TM32,
    TM33,
    TM34,
    TM35,
    TM36,
    TM37,
    TM38,
    TM39,
    TM40,
    TM41,
    TM42,
    TM43,
    TM44,
    TM45,
    TM46,
    TM47,
    TM48,
    TM49,
    TM50,

    comptime {
        assert(@sizeOf(Item) == 1);
    }

    /// The number of held items in this generation.
    pub const size = 196;

    /// Returns a `Type` boosted by this item or `null` if the item is not a type-boosting item.
    pub inline fn boost(item: Item) ?Type {
        assert(item != .None);
        if (item == .PolkadotBow) return .Normal;
        return if (@intFromEnum(item) <= 18) @enumFromInt(@intFromEnum(item) - 1) else null;
    }

    /// Whether or not this item is a Berry.
    pub inline fn berry(item: Item) bool {
        assert(item != .None);
        return @intFromEnum(item) > 30 and @intFromEnum(item) <= 40;
    }

    /// Whether or not this item is Mail.
    pub inline fn mail(item: Item) bool {
        assert(item != .None);
        return @intFromEnum(item) > 60 and @intFromEnum(item) <= 70;
    }
};
