default:
    @just --list

debug:
    cargo build
    cp paicord-rs/PaicordLibBridge/.build/debug/libPaicordLibBridge.so target/debug/libPaicordLibBridge.so
    ./target/debug/paicord

release:
    cargo build --release
    cp paicord-rs/PaicordLibBridge/.build/debug/libPaicordLibBridge.so target/release/libPaicordLibBridge.so
    LD_LIBRARY_PATH=./target/release ./target/release/paicord