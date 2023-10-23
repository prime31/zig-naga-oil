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

    pub fn addComposableModule(self: Composer, desc: naga_oil.ComposableModuleDescriptor) error{AddComposableModuleFailed}!void {
        if (naga_oil.composer_add_composable_module(self.composer, desc) < 0) return error.AddComposableModuleFailed;
    }

    pub fn makeNagaModule(self: Composer, desc: naga_oil.ModuleDescriptor) error{NagaModuleNotCreated}!Module {
        const module = naga_oil.composer_make_naga_module(self.composer, desc);
        if (module == null) return error.NagaModuleNotCreated;
        return .{ .module = module };
    }
};

pub const Module = struct {
    module: naga_oil.Module,

    pub fn toSource(self: Module) Source {
        return .{ .source = naga_oil.module_to_source(self.module) };
    }
};

pub const Source = struct {
    source: [*c]u8,

    pub fn deinit(self: Source) void {
        naga_oil.source_destroy(self.source);
    }
};

/// When used the called function owns the memory so deinit is omitted
pub const ShaderDefs = struct {
    defs: naga_oil.ShaderDefs,

    pub fn init() ShaderDefs {
        return .{ .defs = naga_oil.shader_defs_create() };
    }

    pub fn insertI32(self: ShaderDefs, key: []const u8, value: i32) void {
        naga_oil.shader_defs_insert_sint(self.defs, key.ptr, value);
    }

    pub fn insertU32(self: ShaderDefs, key: []const u8, value: u32) void {
        naga_oil.shader_defs_insert_uint(self.defs, key.ptr, value);
    }

    pub fn insertBool(self: ShaderDefs, key: []const u8, value: bool) void {
        naga_oil.shader_defs_insert_bool(self.defs, key.ptr, value);
    }

    pub fn debugPrint(self: ShaderDefs) void {
        naga_oil.shader_defs_debug_print(self.defs);
    }
};

pub const ImportDefinitions = struct {
    imports: naga_oil.ImportDefinitions,

    pub fn init() ImportDefinitions {
        return .{ .imports = naga_oil.import_definitions_create() };
    }

    pub fn deinit(self: ImportDefinitions) void {
        naga_oil.import_definitions_destroy(self.imports);
    }

    pub fn push(self: ImportDefinitions, import: []const u8) void {
        naga_oil.import_definitions_push(self.imports, import.ptr);
    }

    pub fn pushWithItems(self: ImportDefinitions, import: []const u8, items: []const u8) void {
        const vec = StringVec.init();
        vec.push(items);
        naga_oil.import_definitions_push_with_items(self.imports, import.ptr, vec);
    }
};

/// When used the called function owns the memory so deinit is omitted
const StringVec = struct {
    defs: naga_oil.StringVec,

    pub fn init() StringVec {
        return .{ .defs = naga_oil.string_vec_create() };
    }

    pub fn push(self: StringVec, item: []const u8) void {
        naga_oil.string_vec_push(self.defs, item.ptr);
    }
};
