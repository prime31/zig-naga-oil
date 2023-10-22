use std::{env, path::PathBuf};

use cbindgen::{Config, Language};

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let package_name = env::var("CARGO_PKG_NAME").unwrap();
    let output_file = PathBuf::from(&crate_dir)
        .join("include")
        .join(format!("{}.h", package_name));

    // cbindgen::generate(&crate_dir).unwrap().write_to_file(output_file);

    let mut config = Config::default();
    config.language = Language::C;
    config.cpp_compat = false;

    cbindgen::generate_with_config(&crate_dir, config)
        .unwrap()
        .write_to_file(output_file);
}
