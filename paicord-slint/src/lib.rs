pub mod state;
pub mod app;
pub mod images;
pub mod models;

#[cfg_attr(target_os = "android", link(name = "c++_shared"))]
unsafe extern "C" {}

#[cfg_attr(target_arch = "wasm32", wasm_bindgen(start))]
#[tokio::main]
pub async fn main() {
    // if !std::env::var("SLINT_BACKEND").is_ok() {
    //     unsafe {
    //         std::env::set_var("SLINT_BACKEND", "winit-skia");
    //     }
    // }

    // unsafe {
    //     std::env::set_var("SLINT_ENABLE_EXPERIMENTAL_FEATURES", "1");
    // }

    run_app().unwrap();
}

#[cfg(target_os = "android")]
#[unsafe(no_mangle)]
#[tokio::main]
async fn android_main(android_app: slint::android::AndroidApp) {
    slint::android::init(android_app).unwrap();
    run_app().unwrap();
}

fn run_app() -> Result<(), slint::PlatformError> {
    let app = app::App::new().unwrap();

    slint::invoke_from_event_loop(|| {
        #[cfg(target_os = "linux")]
        slint::set_xdg_app_id("Paicord").unwrap();
    })
    .unwrap();

    app.run()?;

    Ok(())
}
