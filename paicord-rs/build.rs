use core::panic;
use std::{path::PathBuf, process::Command};

fn main() {
    println!("cargo:rerun-if-changed=NULL");
    println!("cargo:warn=Building PaicordLibBridge via build.rs");

    if let Ok(bridge_path) = std::env::var("BRIDGE_PATH") {
        let dest_file = PathBuf::from(bridge_path).join("libPaicordLibBridge.so");
        //delete if exists
        if dest_file.exists() {
            std::fs::remove_file(&dest_file).unwrap_or_else(|e| {
                panic!(
                    "Failed to delete existing bridge library at {:?}: {}",
                    dest_file, e
                )
            });
        }
    }
    let bridge_files = vec![
        // "src/discord_models/types/shared.rs",
        // "src/discord_models/types/snowflake.rs",
        // "src/discord_models/types/gateway.rs",
        // "src/discord_models/types/user.rs",
        // "src/discord_gateway/remote_auth_gateway_manager.rs",
        // "src/discord_gateway/user_gateway_manager.rs",
        // "src/discord_http/default_discord_client.rs",
        // "src/discord_http/endpoints/cdn_endpoints.rs",
        "src/lib.rs",
    ];
    swift_bridge_build::parse_bridges(bridge_files)
        .write_all_concatenated(swift_bridge_out_dir(), "paicord-rs");

    compile_swift();

    println!("cargo:rustc-link-lib=dylib=PaicordLibBridge");
    println!(
        "cargo:rustc-link-search={}",
        swift_library_static_lib_dir().to_str().unwrap()
    );
}

fn compile_swift() {
    let swift_package_dir = manifest_dir().join("PaicordLibBridge");

    let mut cmd = Command::new("swiftly");

    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();
    let target_arch = std::env::var("CARGO_CFG_TARGET_ARCH").unwrap_or_default();

    let toolchain = if target_os == "android" && target_arch == "aarch64" {
        ["--swift-sdk", "aarch64-unknown-linux-android29"]
    } else {
        ["--swift-sdk", "x86_64-unknown-linux-android29"]
    };

    if target_os == "android" {
        cmd.env("ANDROID_NDK_ROOT", "");
    }

    cmd.current_dir(swift_package_dir)
        .args(["run", "swift", "build"])
        .args([
            "-Xswiftc",
            "-import-objc-header",
            "-Xswiftc",
            swift_source_dir()
                .join("bridging-header.h")
                .to_str()
                .unwrap(),
        ]);

    // if is_release_build() {
    //     cmd.args(["-c", "release"]);
    // }

    if target_os == "android" {
        cmd.args(toolchain);
    }
    let exit_status = cmd.spawn().unwrap().wait_with_output().unwrap();

    if !exit_status.status.success() {
        panic!(
            r#"
Stderr: {}
Stdout: {}
"#,
            String::from_utf8(exit_status.stderr).unwrap(),
            String::from_utf8(exit_status.stdout).unwrap(),
        )
    }
}

fn swift_bridge_out_dir() -> PathBuf {
    generated_code_dir()
}

fn manifest_dir() -> PathBuf {
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    PathBuf::from(manifest_dir)
}

fn is_release_build() -> bool {
    std::env::var("PROFILE").unwrap() == "release"
}

fn swift_source_dir() -> PathBuf {
    manifest_dir().join("PaicordLibBridge/Sources")
}

fn generated_code_dir() -> PathBuf {
    swift_source_dir().join("generated")
}

fn swift_library_static_lib_dir() -> PathBuf {
    let debug_or_release = if is_release_build() {
        "release"
    } else {
        "debug"
    };

    let debug_or_release = "debug";

    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();
    if target_os == "android" {
        manifest_dir().join(format!(
            "PaicordLibBridge/.build/x86_64-unknown-linux-android29/{}",
            debug_or_release
        ))
    } else {
        manifest_dir().join(format!("PaicordLibBridge/.build/{}", debug_or_release))
    }
}
