const c = @import("bindings/c.zig");
const std = @import("std");

export const PKMN_OPTIONS = c.OPTIONS;

export const PKMN_MAX_CHOICES = c.MAX_CHOICES;
export const PKMN_CHOICES_SIZE = c.CHOICES_SIZE;
export const PKMN_MAX_LOGS = c.MAX_LOGS;
export const PKMN_LOGS_SIZE = c.LOGS_SIZE;

const exportable = @hasDecl(std.zig, "Zir") and !@hasDecl(std.zig.Zir.Inst, "export_value");

usingnamespace if (exportable) struct {
    export const pkmn_choice_init = c.choice_init;
    export const pkmn_choice_type = c.choice_type;
    export const pkmn_choice_data = c.choice_data;

    export const pkmn_result_type = c.result_type;
    export const pkmn_result_p1 = c.result_p1;
    export const pkmn_result_p2 = c.result_p2;

    export const pkmn_error = c.err;

    export const pkmn_psrng_init = c.psrng_init;
    export const pkmn_psrng_next = c.psrng_next;

    export const pkmn_rational_init = c.rational_init;
    export const pkmn_rational_reduce = c.rational_reduce;
    export const pkmn_rational_numerator = c.rational_numerator;
    export const pkmn_rational_denominator = c.rational_denominator;
} else struct {
    comptime {
        @export(c.choice_init, .{ .name = "pkmn_choice_init", .linkage = .Strong });
        @export(c.choice_type, .{ .name = "pkmn_choice_type", .linkage = .Strong });
        @export(c.choice_data, .{ .name = "pkmn_choice_data", .linkage = .Strong });

        @export(c.result_type, .{ .name = "pkmn_result_type", .linkage = .Strong });
        @export(c.result_p1, .{ .name = "pkmn_result_p1", .linkage = .Strong });
        @export(c.result_p2, .{ .name = "pkmn_result_p2", .linkage = .Strong });

        @export(c.err, .{ .name = "pkmn_error", .linkage = .Strong });

        @export(c.psrng_init, .{ .name = "pkmn_psrng_init", .linkage = .Strong });
        @export(c.psrng_next, .{ .name = "pkmn_psrng_next", .linkage = .Strong });

        @export(c.rational_init, .{ .name = "pkmn_rational_init", .linkage = .Strong });
        @export(c.rational_reduce, .{ .name = "pkmn_rational_reduce", .linkage = .Strong });
        @export(c.rational_numerator, .{ .name = "pkmn_rational_numerator", .linkage = .Strong });
        @export(
            c.rational_denominator,
            .{ .name = "pkmn_rational_denominator", .linkage = .Strong },
        );
    }
};

export const PKMN_GEN1_MAX_CHOICES = c.gen(1).MAX_CHOICES;
export const PKMN_GEN1_CHOICES_SIZE = c.gen(1).CHOICES_SIZE;
export const PKMN_GEN1_MAX_LOGS = c.gen(1).MAX_LOGS;
export const PKMN_GEN1_LOGS_SIZE = c.gen(1).LOGS_SIZE;

usingnamespace if (exportable) struct {
    export const pkmn_gen1_battle_options_set =
        c.gen(1).battle_options_set;
    export const pkmn_gen1_battle_options_chance_probability =
        c.gen(1).battle_options_chance_probability;
    export const pkmn_gen1_battle_options_chance_actions =
        c.gen(1).battle_options_chance_actions;
    export const pkmn_gen1_battle_options_chance_durations =
        c.gen(1).battle_options_chance_durations;
    export const pkmn_gen1_battle_options_calc_summaries =
        c.gen(1).battle_options_calc_summaries;

    export const pkmn_gen1_battle_update = c.gen(1).battle_update;
    export const pkmn_gen1_battle_choices = c.gen(1).battle_choices;
} else struct {
    comptime {
        @export(
            c.gen(1).battle_options_set,
            .{ .name = "pkmn_gen1_battle_options_set", .linkage = .Strong },
        );
        @export(
            c.gen(1).battle_options_chance_probability,
            .{ .name = "pkmn_gen1_battle_options_chance_probability", .linkage = .Strong },
        );
        @export(
            c.gen(1).battle_options_chance_actions,
            .{ .name = "pkmn_gen1_battle_options_chance_actions", .linkage = .Strong },
        );
        @export(
            c.gen(1).battle_options_chance_durations,
            .{ .name = "pkmn_gen1_battle_options_chance_durations", .linkage = .Strong },
        );
        @export(
            c.gen(1).battle_options_calc_summaries,
            .{ .name = "pkmn_gen1_battle_options_calc_summaries", .linkage = .Strong },
        );

        @export(
            c.gen(1).battle_update,
            .{ .name = "pkmn_gen1_battle_update", .linkage = .Strong },
        );
        @export(
            c.gen(1).battle_choices,
            .{ .name = "pkmn_gen1_battle_choices", .linkage = .Strong },
        );
    }
};
