use crate::app::LazyImage;

impl LazyImage {
    pub fn from_url(url: String) -> Self {
        Self {
            url: url.into(),
            ..Default::default()
        }
    }
}

unsafe impl Send for LazyImage {}
unsafe impl Sync for LazyImage {}