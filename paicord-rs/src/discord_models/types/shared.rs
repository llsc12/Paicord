use chrono::{DateTime, Local, TimeZone, offset::LocalResult};

use crate::{discord_models::types::gateway::PartialMessage, ffi};

pub type DiscordColor = ffi::DiscordColorRust;
pub type DiscordLocale = ffi::DiscordLocaleRust;
pub type DiscordTimestamp = ffi::DiscordTimestampRust;

impl DiscordColor {
    pub fn as_rgb(&self) -> (u8, u8, u8) {
        let red = self.inner >> 16;
        let green = (self.inner >> 8) & 0x00FF;
        let blue = self.inner & 0x0000FF;

        (red as u8, green as u8, blue as u8)
    }
}

impl Default for DiscordColor {
    fn default() -> Self {
        Self { inner: 0 }
    }
}

impl DiscordTimestamp {
    pub fn as_datetime(&self) -> LocalResult<DateTime<Local>> {
        let millis = (self.inner * 1000.0) as i64;
        chrono::Local.timestamp_millis_opt(millis)
    }

    pub fn to_string(&self, message: &PartialMessage) -> String {
        let now = Local::now();

        let datetime = match self.as_datetime() {
            LocalResult::Single(dt) => dt,
            LocalResult::Ambiguous(dt1, _) => dt1,
            LocalResult::None => now.clone()
        };

        if datetime.date_naive() == now.date_naive() {
            datetime.format("%-I:%M %p").to_string()
        } else if datetime.date_naive() == (now - chrono::Duration::days(1)).date_naive() {
            format!("Yesterday at {}", datetime.format("%-I:%M %p"))
        } else {
            datetime.format("%m/%d/%Y at %-I:%M %p").to_string()
        }
    }
}

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

unsafe impl Send for ffi::BridgedRustError {}
unsafe impl Sync for ffi::BridgedRustError {}