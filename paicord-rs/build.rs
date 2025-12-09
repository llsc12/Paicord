use core::panic;
use std::{path::PathBuf, process::Command};

fn main() {
    println!("cargo:rerun-if-changed=NULL");

    let bridge_files = vec!["src/user_gateway_manager.rs"];
    swift_bridge_build::parse_bridges(bridge_files)
        .write_all_concatenated(swift_bridge_out_dir(), "paicord-rs");

    compile_swift();

    println!("cargo:rustc-link-lib=curl");
    println!("cargo:rustc-link-lib=static=PaicordLibBridge");
    println!(
        "cargo:rustc-link-search={}",
        swift_library_static_lib_dir().to_str().unwrap()
    );
    let zlib = pkg_config::Config::new()
        .cargo_metadata(true)
        .print_system_libs(false)
        .probe("zlib");
    match zlib {
        Ok(zlib) => {
            if !zlib.include_paths.is_empty() {
                let paths = zlib
                    .include_paths
                    .iter()
                    .map(|s| s.display().to_string())
                    .collect::<Vec<_>>();
                println!("cargo:include={}", paths.join(","));
            }
        }
        Err(e) => {
            println!(
                "cargo:warning=Could not find zlib include paths via pkg-config: {}",
                e
            )
        }
    }

    let user = std::env::var("USER").unwrap_or("sarah".to_string());

    let swift_lib_path = std::env::var("SWIFT_LIBRARY_PATH").unwrap_or(
        PathBuf::from("/home/")
            .join(user)
            .join(".local/share/swiftly/toolchains/6.2.1/usr/lib/swift_static/linux/")
            .to_string_lossy()
            .to_string(),
    );

    if !std::path::Path::new(&swift_lib_path).exists() {
        panic!(
            "Swift library path not found at /usr/lib/swift/linux and SWIFT_LIBRARY_PATH environment variable not set"
        );
    }

    println!("cargo:rustc-link-search=native={}", swift_lib_path);
    for entry in std::fs::read_dir(&swift_lib_path).unwrap() {
        let path = entry.unwrap().path();
        if let Some(name) = path.file_name().and_then(|s| s.to_str())
            && name.ends_with(".a")
        {
            let lib_name = name
                .strip_prefix("lib")
                .unwrap_or(name)
                .strip_suffix(".a")
                .unwrap_or(name);
            println!("cargo:rustc-link-lib=static={}", lib_name); // Or static= if using Static SDK
        }
    }

    println!("cargo:rustc-link-lib=stdc++");
    println!("cargo:rustc-link-lib=curl");

    #[cfg(any(target_os = "linux", target_os = "android"))]
    #[cfg(any(target_arch = "x86_64", target_arch = "aarch64"))]
    println!(
        "cargo:rustc-link-arg={}{}/swiftrt.o",
        swift_lib_path,
        std::env::consts::ARCH
    );
}

fn compile_swift() {
    let swift_package_dir = manifest_dir().join("PaicordLibBridge");

    let mut cmd = Command::new("swiftly");

    #[cfg(target_os = "android")]
    let toolchain = if cfg!(target_os = "android") && cfg!(target_arch = "aarch64") {
        ["--swift-sdk", "aarch64-unknown-linux-android"]
    } else {
        ["--swift-sdk", "x86_64-unknown-linux-android"]
    };

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

    if is_release_build() {
        cmd.args(["-c", "release"]);
    }
    #[cfg(target_os = "android")]
    cmd.args(toolchain);

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

    manifest_dir().join(format!("PaicordLibBridge/.build/{}", debug_or_release))
}
