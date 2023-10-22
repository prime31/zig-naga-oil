# zig-naga-oil
Zig wrapper for [naga_oil](https://github.com/bevyengine/naga_oil) Rust crate


## Build Rust
- `cargo build --release`: builds static lib for the current platform
- `cargo build --release --target x86_64-pc-windows-gnu`: cross compiles

## Usage
- reference `build.zig`: `const oil_build = @import("path/to/naga_oil/build.zig;`
- link the library: `oil_build.linkArtifact(exe, target, optimize);`
- fetch the module and add to your exe: `exe.addModule("naga_oil", oil_build.getModule(b));`
