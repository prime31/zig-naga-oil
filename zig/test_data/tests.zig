const std = @import("std");
const oil = @import("naga_oil");

const Composer = oil.Composer;
const Module = oil.Module;
const ShaderDefs = oil.ShaderDefs;
const Source = oil.Source;

fn testAddBevyPbrModules(composer: Composer, skip_adding_one: bool) !void {
    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/utils.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/utils.wgsl",
    });

    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/mesh_view_types.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/mesh_view_types.wgsl",
    });

    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/mesh_view_bindings.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/mesh_view_bindings.wgsl",
    });

    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/pbr_types.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/pbr_types.wgsl",
    });

    if (!skip_adding_one) {
        try composer.addComposableModule(.{
            .source = @embedFile("../test_data/bevy_pbr_wgsl/pbr_bindings.wgsl"),
            .file_path = "test_data/bevy_pbr_wgsl/pbr_bindings.wgsl",
        });
    }

    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/skinning.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/skinning.wgsl",
    });

    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/mesh_types.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/mesh_types.wgsl",
    });

    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/mesh_bindings.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/mesh_bindings.wgsl",
    });

    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/mesh_vertex_output.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/mesh_vertex_output.wgsl",
    });

    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/clustered_forward.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/clustered_forward.wgsl",
    });

    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/pbr_lighting.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/pbr_lighting.wgsl",
    });

    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/shadows.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/shadows.wgsl",
    });

    try composer.addComposableModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/pbr_functions.wgsl"),
        .file_path = "test_data/bevy_pbr_wgsl/pbr_functions.wgsl",
    });
}

test "bevy pbr" {
    std.log.warn("", .{});

    const composer = Composer.init();
    defer composer.deinit();

    try testAddBevyPbrModules(composer, false);

    const module = try composer.makeNagaModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/pbr.wgsl"),
        .file_path = "src/bevy_pbr_wgsl/pbr.wgsl",
    });

    const source = module.toSource();
    defer source.deinit();
    std.debug.print("len: {}\n", .{std.mem.span(source.source).len});
    // try std.testing.expect(std.mem.span(source.source).len == 37001);
}

test "ShaderDefs" {
    const defs = ShaderDefs.init();
    defer defs.deinit();

    defs.insertBool("HAS_TANGENTS", true);
    defs.insertU32("MAX_LIGHTS", 256);

    defs.debugPrint();
}

test "bevy pbr fail" {
    std.log.warn("", .{});

    const composer = Composer.init();
    defer composer.deinit();

    try testAddBevyPbrModules(composer, true);

    try std.testing.expectError(error.NagaModuleNotCreated, composer.makeNagaModule(.{
        .source = @embedFile("../test_data/bevy_pbr_wgsl/pbr.wgsl"),
        .file_path = "src/bevy_pbr_wgsl/pbr.wgsl",
    }));
}
