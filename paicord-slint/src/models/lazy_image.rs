use crate::app::LazyImage;

impl LazyImage {
    pub fn from_url(url: String) -> Self {
        Self {
            url: url.into(),
            ..Default::default()
        }
    }
}