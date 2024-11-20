const std = @import("std");
const CrossTarget = @import("std").zig.CrossTarget;
const Target = @import("std").Target;
const Feature = Target.Cpu.Feature;
// pub const featureSet = Target.Cpu.Feature.feature_set_fns(Feature).featureSet;

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    // define enabled features (only i and m)
    const features = Target.riscv.Feature;

    var enabled_features = Feature.Set.empty;
    enabled_features.addFeature(@intFromEnum(features.i));
    enabled_features.addFeature(@intFromEnum(features.m));

    // var disabled_features = Feature.Set.empty;
    // disabled_features.addFeature(@intFromEnum(features.a));
    // disabled_features.addFeature(@intFromEnum(features.c));
    // disabled_features.addFeature(@intFromEnum(features.d));
    // disabled_features.addFeature(@intFromEnum(features.e));
    // disabled_features.addFeature(@intFromEnum(features.f));

    // setup riscv32im target
    const riscv_target = CrossTarget{
        .cpu_arch = .riscv32,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.generic_rv32 },
        .abi = .gnu,
        // operating system to compile for, we specify
        // `freestanding` over here because this doesn't really run
        // on any operating system zig is aware of.
        // todo(fede) do we need freestanding?
        .os_tag = .freestanding,
        .cpu_features_add = enabled_features,
        // .cpu_features_sub = disabled_features,
    };
    const resolved_target = b.resolveTargetQuery(riscv_target);

    // pkmm engine configs
    const showdown =
        b.option(bool, "showdown", "Enable Pokémon Showdown compatibility mode") orelse false;
    const log = b.option(bool, "log", "Enable protocol message logging") orelse false;

    const exe = b.addExecutable(.{
        .name = "pkmn_battle",
        .root_source_file = if (@hasField(std.Build.LazyPath, "path"))
            .{ .path = "dummy_battle.zig" }
        else
            b.path("dummy_battle.zig"),
        .optimize = optimize,
        .target = resolved_target,
    });

    exe.addAssemblyFile(b.path("entrypoint.s"));
    exe.setLinkerScriptPath(b.path("link.ld"));

    const pkmn = b.dependency("pkmn", .{ .showdown = showdown, .log = log });
    exe.root_module.addImport("pkmn", pkmn.module("pkmn"));
    b.installArtifact(exe);
}
