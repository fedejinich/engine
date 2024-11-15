const std = @import("std");
const CrossTarget = std.zig.CrossTarget;

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const riscv_target = CrossTarget{
        // the cpu architecture I intend to produce binaries for
        .cpu_arch = .riscv32,

        // the operating system to compile the code for, we specify
        // `freestanding` over here because this doesn't really run
        // on any operating system zig is aware of.
        .os_tag = .freestanding,

        // I still don't really understand this.
        // .abi = .gnueabihf,
        .abi = .gnu,

        // the cpu model includes the features of the cpu architecture
        // the hardware manufacturers added to their product.
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.generic_rv32 },
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

// pub fn build(b: *std.Build) void {
//     const target = std.zig.CrossTarget{
//         .cpu_arch = std.Target.Cpu.Arch.riscv32,
//         .os_tag = std.Target.Os.Tag.freestanding,
//     };
//
//     // Standard release options allow the person running `zig build` to select
//     // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
//     const mode = b.standardOptimizeOption(.{});
//
//     const exe = b.addExecutable(.{
//         .
//     }"nosering", "dummy_battle.zig");
//     exe.code_model = .medium;
//     // exe.addAssemblyFile("src/entry.S");
//     exe.setLinkerScriptPath(std.build.FileSource{ .path = "link.ld" });
//     exe.setTarget(target);
//     exe.setBuildMode(mode);
//     exe.install();
// }
