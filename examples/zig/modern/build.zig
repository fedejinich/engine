const std = @import("std");
const CrossTarget = @import("std").zig.CrossTarget;
const Target = @import("std").Target;
const Feature = Target.Cpu.Feature;
// pub const featureSet = Target.Cpu.Feature.feature_set_fns(Feature).featureSet;

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const riscv_target = CrossTarget{
        .cpu_arch = .riscv32,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.generic_rv32 },
        .abi = .gnu,
        // operating system to compile for, we specify
        // `freestanding` over here because this doesn't really run
        // on any operating system zig is aware of.
        // todo(fede) do we need freestanding?
        .os_tag = .freestanding,
    };

    const resolved_target = b.resolveTargetQuery(riscv_target);

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
