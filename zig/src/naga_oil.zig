const std = @import("std");
const naga_oil = @cImport({
    @cInclude("naga_oil_c.h");
});

pub const Composer = struct {
    composer: naga_oil.Composer,

    pub fn init() Composer {
        return .{ .composer = naga_oil.composer_create() };
    }

    pub fn deinit(self: Composer) void {
        naga_oil.composer_destroy(self.composer);
    }

    pub fn addComposableModule(self: Composer, desc: naga_oil.ComposableModuleDescriptor) !void {
        if (naga_oil.add_composable_module(self.composer, desc) < 0) return error.AddComposableModuleFailed;
    }

    pub fn makeNagaModule(self: Composer, desc: naga_oil.ModuleDescriptor) error{NagaModuleNotCreated}!Module {
        const module = naga_oil.make_naga_module(self.composer, desc);
        if (module == null) return error.NagaModuleNotCreated;
        return .{ .module = module };
    }
};

pub const Module = struct {
    module: naga_oil.Module,

    pub fn deinit(self: Module) void {
        naga_oil.source_destroy(self.source);
    }

    pub fn toSource(self: Module) Source {
        return .{ .source = naga_oil.naga_module_to_source(self.module) };
    }
};

pub const Source = struct {
    source: [*c]u8,

    pub fn deinit(self: Source) void {
        naga_oil.source_destroy(self.source);
    }
};

pub const ShaderDefs = struct {
    defs: naga_oil.ShaderDefs,

    pub fn init() ShaderDefs {
        return .{ .defs = naga_oil.shader_defs_create() };
    }

    pub fn deinit(self: ShaderDefs) void {
        naga_oil.shader_defs_destroy(self.defs);
    }

    pub fn insertI32(self: ShaderDefs, key: []const u8, value: i32) void {
        naga_oil.shader_defs_insert_bool(self.defs, key, value);
    }

    pub fn insertU32(self: ShaderDefs, key: []const u8, value: u32) void {
        naga_oil.shader_defs_insert_bool(self.defs, key, value);
    }

    pub fn insertBool(self: ShaderDefs, key: []const u8, value: u32) void {
        naga_oil.shader_defs_insert_bool(self.defs, key, value);
    }
};
