# zig-naga-oil
Zig wrapper for [naga_oil](https://github.com/bevyengine/naga_oil) Rust crate


## Build Rust
- `cargo build --release`: builds static lib for the current platform
- `cargo build --release --target x86_64-pc-windows-gnu`: cross compiles

## Add Package to Your Project
- copy `zig` folder to your project
- reference `build.zig`: `const oil_build = @import("path/to/naga_oil/build.zig;`
- link the library: `oil_build.linkArtifact(exe, target, optimize);`
- fetch the module and add to your exe: `exe.addModule("naga_oil", oil_build.getModule(b));`

## Usage

```zig
// create a Composer
const composer = Composer.init();
defer composer.deinit();

// add source code modules to the Composer
try composer.addComposableModule(.{
    .source = @embedFile("utils.wgsl"),
    .file_path = "shaders/utils.wgsl",
});

// optionally created ShaderDefs for conditinal compilation
const shader_defs = ShaderDefs.init();
defer shader_defs.deinit();

shader_defs.insertBool("HAS_TANGENTS", true);
shader_defs.insertU32("MAX_LIGHTS", 256);

// create a Naga Module with the main shader file
const module = try composer.makeNagaModule(.{
    .source = @embedFile("pbr.wgsl"),
    .file_path = "shaders/pbr.wgsl",
    .shader_defs = shader_defs,
});

// generate the shader source
const source = module.toSource();
defer source.deinit();
std.debug.print("shader: {}\n", .{source.source});
```
