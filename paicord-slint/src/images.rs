use std::{
    io::Cursor, path::{Path, PathBuf}, sync::{Arc, Mutex}
};

use fast_image_resize::Resizer;
use image::{DynamicImage, ImageFormat, buffer};
use slint::{Image, Rgba8Pixel, SharedPixelBuffer, Weak};
use threadpool::ThreadPool;

use crate::app::MainWindow;

#[derive(Clone)]
pub struct ImageMangler {
    window: Weak<MainWindow>,
    cache_path: PathBuf,
    thread_pool: ThreadPool,

    placeholder: Arc<Mutex<SharedPixelBuffer<Rgba8Pixel>>>,
}

impl ImageMangler {
    pub fn new<S: AsRef<Path>>(window: Weak<MainWindow>, cache_dir: S) -> Self {
        ImageMangler {
            window,
            cache_path: cache_dir.as_ref().to_path_buf(),
            thread_pool: ThreadPool::default(),
            placeholder: Self::load_default_image(include_bytes!("../ui/images/paicord_icon.png")),
        }
    }

    pub async fn get<S: AsRef<str>>(
        &self,
        url: S,
        width: u32,
        height: u32,
        cache: bool,
    ) -> slint::Image {
        let buffer = self.get_buffer(url, width, height, cache).await;
        slint::Image::from_rgba8_premultiplied(buffer)
    }

    pub async fn get_buffer<S: AsRef<str>>(
        &self,
        url: S,
        width: u32,
        height: u32,
        cache: bool,
    ) -> SharedPixelBuffer<Rgba8Pixel> {
        let url = url.as_ref().to_string();
        if url.is_empty() {
            return self.placeholder.lock().unwrap().clone()
        }
        let cache_key = url.replace("/", "_").replace(":", "_");

        if cache && let Some(mut dyn_image) = self.cache_get_async(&cache_key).await {
            if width != dyn_image.width() || height != dyn_image.height() {
                dyn_image = resize(dyn_image, width, height);
            }
            return dynamic_to_buffer(&dyn_image);
        }

        let Ok(response) = reqwest::get(url).await else {
            return self.placeholder.lock().unwrap().clone()
        };

        let Ok(bytes) = response.bytes().await else {
            return self.placeholder.lock().unwrap().clone()
        };

        if let Ok(dynamic_image) = image::load_from_memory(&bytes) {
            let dynamic_image = resize(dynamic_image, width, height);
            if cache {
                self.cache_set(&cache_key, &dynamic_image);
            }
            return dynamic_to_buffer(&dynamic_image);
        }

        self.placeholder.lock().unwrap().clone()
    }

    pub fn lazy_get<F, S: AsRef<str>>(
        &self,
        url: S,
        width: u32,
        height: u32,
        cache: bool,
        set_image: F,
    ) -> slint::Image
    where
        F: Fn(MainWindow, slint::Image) + Send + 'static,
    {
        let buffer = self.lazy_get_buffer(url, width, height, cache, set_image);
        slint::Image::from_rgba8_premultiplied(buffer)
    }

    pub fn lazy_get_buffer<F, S: AsRef<str>>(
        &self,
        url: S,
        width: u32,
        height: u32,
        cache: bool,
        set_image: F,
    ) -> SharedPixelBuffer<Rgba8Pixel>
    where
        F: Fn(MainWindow, slint::Image) + Send + 'static,
    {
        let url = url.as_ref().to_string();
        if url.is_empty() {
            return self.placeholder.lock().unwrap().clone()
        }
        let cache_key = url.replace("/", "_").replace(":", "_");

        if cache && let Some(mut dyn_image) = self.cache_get(&cache_key) {
            if width != dyn_image.width() || height != dyn_image.height() {
                dyn_image = resize(dyn_image, width, height);
            }
            return dynamic_to_buffer(&dyn_image);
        }

        let images = self.clone();
        let ui = self.window.clone();
        self.thread_pool.execute(move || {
            let Ok(image_data) = reqwest::blocking::get(url) else {
                return;
            };

            let Ok(bytes) = image_data.bytes() else {
                return;
            };

            if let Ok(mut dyn_image) = image::load_from_memory(&bytes) {
                if width != dyn_image.width() || height != dyn_image.height() {
                    dyn_image = resize(dyn_image, width, height);
                }
                if cache {
                    images.cache_set(&cache_key, &dyn_image);
                }
                let buffer = dynamic_to_buffer(&dyn_image);
                ui.upgrade_in_event_loop(move |ui| {
                    let image = slint::Image::from_rgba8_premultiplied(buffer.clone());
                    set_image(ui, image);
                })
                .unwrap();
            }
        });

        self.placeholder.lock().unwrap().clone()
    }

    fn cache_get(&self, key: &str) -> Option<DynamicImage> {
        if let Ok(bytes) = cacache::read_sync(self.cache_path.clone(), key) {
            if let Ok(dyn_image) = image::load_from_memory(&bytes) {
                return Some(dyn_image);
            }
        }
        None
    }

    async fn cache_get_async<S: AsRef<str>>(&self, key: S) -> Option<DynamicImage> {
        if let Ok(bytes) = cacache::read(self.cache_path.clone(), key.as_ref()).await {
            return image::load_from_memory(&bytes).ok();
        }

        None
    }

    fn cache_set(&self, key: &str, image: &DynamicImage) {
        let mut bytes = vec![];
        let mut cursor = Cursor::new(&mut bytes);

        let extension = key.split('.').last().unwrap_or("png");
        let format = ImageFormat::from_extension(extension).unwrap_or(ImageFormat::Png);

        image.write_to(&mut cursor, format).unwrap();
        cacache::write_sync(self.cache_path.clone(), key, bytes).unwrap();
    }

    fn load_default_image(buffer: &[u8]) -> Arc<Mutex<SharedPixelBuffer<Rgba8Pixel>>> {
        let image = image::load_from_memory(buffer).unwrap();
        Arc::new(Mutex::new(dynamic_to_buffer(&image)))
    }
}

pub fn resize(image: DynamicImage, width: u32, height: u32) -> DynamicImage {
    let src_image = image;

    let mut dst_image = DynamicImage::new(width, height, src_image.color());

    let mut resizer = Resizer::new();
    resizer.resize(&src_image, &mut dst_image, None).unwrap();

    dst_image
}

pub fn dynamic_to_buffer(dynamic_image: &DynamicImage) -> SharedPixelBuffer<Rgba8Pixel> {
    // TODO this might be cloning twice.
    let rgba8_image = dynamic_image.clone().into_rgba8();
    SharedPixelBuffer::<Rgba8Pixel>::clone_from_slice(
        rgba8_image.as_raw(),
        rgba8_image.width(),
        rgba8_image.height(),
    )
}

pub fn dynamic_to_slint(dyn_image: &DynamicImage) -> slint::Image {
    slint::Image::from_rgba8_premultiplied(dynamic_to_buffer(dyn_image))
}

unsafe impl Send for ImageMangler {}
unsafe impl Sync for ImageMangler {}
