use crate::ffi;

pub use ffi::DiscordColorRust as DiscordColor;
pub use ffi::DiscordLocaleRust as DiscordLocale;
pub use ffi::DiscordTimestampRust as DiscordTimestamp;

impl std::fmt::Debug for DiscordColor {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "DiscordColor({})", self.inner)
    }
}

impl std::fmt::Debug for DiscordLocale {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Danish => write!(f, "Danish"),
            Self::German => write!(f, "German"),
            Self::EnglishUK => write!(f, "EnglishUK"),
            Self::EnglishUS => write!(f, "EnglishUS"),
            Self::Spanish => write!(f, "Spanish"),
            Self::French => write!(f, "French"),
            Self::Croatian => write!(f, "Croatian"),
            Self::Italian => write!(f, "Italian"),
            Self::Lithuanian => write!(f, "Lithuanian"),
            Self::Hungarian => write!(f, "Hungarian"),
            Self::Dutch => write!(f, "Dutch"),
            Self::Norwegian => write!(f, "Norwegian"),
            Self::Polish => write!(f, "Polish"),
            Self::Portuguese => write!(f, "Portuguese"),
            Self::Romanian => write!(f, "Romanian"),
            Self::Finnish => write!(f, "Finnish"),
            Self::Swedish => write!(f, "Swedish"),
            Self::Vietnamese => write!(f, "Vietnamese"),
            Self::Turkish => write!(f, "Turkish"),
            Self::Czech => write!(f, "Czech"),
            Self::Greek => write!(f, "Greek"),
            Self::Bulgarian => write!(f, "Bulgarian"),
            Self::Russian => write!(f, "Russian"),
            Self::Ukrainian => write!(f, "Ukrainian"),
            Self::Hindi => write!(f, "Hindi"),
            Self::Thai => write!(f, "Thai"),
            Self::ChineseChina => write!(f, "ChineseChina"),
            Self::Japanese => write!(f, "Japanese"),
            Self::ChineseTaiwan => write!(f, "ChineseTaiwan"),
            Self::Korean => write!(f, "Korean"),
            Self::Undocumented(arg0) => f.debug_tuple("Undocumented").field(arg0).finish(),
        }
    }
}

impl std::fmt::Debug for DiscordTimestamp {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("DiscordTimestampRust").field("inner", &self.inner).finish()
    }
}