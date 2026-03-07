// Copyright © SixtyFPS GmbH <info@slint.dev>
// SPDX-License-Identifier: MIT

use std::path::PathBuf;

fn main() {
    println!("cargo:rerun-if-changed=NULL");
    let config = slint_build::CompilerConfiguration::new();
    slint_build::compile_with_config("ui/main.slint", config).unwrap();

    let user = std::env::var("USER").unwrap_or("sarah".to_string());
    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();

    let swift_lib_path = std::env::var("SWIFT_LIBRARY_PATH").unwrap_or(
        PathBuf::from("/home/")
            .join(user)
            .join(if target_os == "android" {
                "/home/sarah/.swiftpm/swift-sdks/swift-6.2-RELEASE-android-24-0.1.artifactbundle/swift-6.2-release-android-24-sdk/android-27d-sysroot/usr/lib/swift/android/"
            } else {
                "/home/sarah/.local/share/swiftly/toolchains/6.2.3/usr/lib/swift_static/linux/"
            })
            .to_string_lossy()
            .to_string(),
    );

    if !std::path::Path::new(&swift_lib_path).exists() {
        panic!(
            "Swift library path not found at /usr/lib/swift/linux and SWIFT_LIBRARY_PATH environment variable not set"
        );
    }

    if target_os == "android" {
        println!(
            "cargo:rustc-link-arg={}{}/swiftrt.o",
            swift_lib_path,
            std::env::consts::ARCH
        );
    }


    // let target_dir = std::env::var("CARGO_TARGET_DIR").unwrap_or_else(|_| "target".to_string());
    // let profile = std::env::var("PROFILE").unwrap_or_else(|_| "debug".to_string());

    // let bridge_path = PathBuf::from("../paicord-rs/PaicordLibBridge/.build/debug/libPaicordLibBridge.so");

    // if !bridge_path.exists() {
    //     panic!(
    //         "Bridge library not found at {:?}. Make sure to build the paicord-rs crate first.",
    //         bridge_path
    //     );
    // }

    // let dest_dir = PathBuf::from(&target_dir).join(&profile);
    // let dest_file = dest_dir.join("libPaicordLibBridge.so");

    // std::fs::copy(&bridge_path, &dest_file).unwrap_or_else(|e| {
    //     panic!(
    //         "Failed to copy bridge library from {:?} to {:?}: {}",
    //         bridge_path, dest_file, e
    //     )
    // });
}
