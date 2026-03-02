use std::hash::Hash;

use crate::ffi;

pub use ffi::SnowflakeRust as Snowflake;

impl std::fmt::Debug for Snowflake {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Snowflake({})", self.inner)
    }
}

impl Snowflake {
    pub fn new(inner: u64) -> Self {
        Snowflake { inner }
    }

    pub fn get_description(&self) -> String {
        self.inner.to_string()
    }

    pub fn get_raw(&self) -> u64 {
        self.inner
    }
}

impl PartialEq for Snowflake {
    fn eq(&self, other: &Self) -> bool {
        self.inner == other.inner
    }
}

impl Eq for Snowflake {}

impl Hash for Snowflake {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.inner.hash(state);
    }
}

impl From<String> for Snowflake {
    fn from(id: String) -> Self {
        Self::from(&id)
    }
}

impl From<&String> for Snowflake {
    fn from(id: &String) -> Self {
        let inner = id.parse::<u64>().unwrap_or(0);
        Snowflake::new(inner)
    }
}

impl From<&str> for Snowflake {
    fn from(id: &str) -> Self {
        let inner = id.parse::<u64>().unwrap_or(0);
        Snowflake::new(inner)
    }
}

impl From<u64> for Snowflake {
    fn from(id: u64) -> Self {
        Self::from(&id)
    }
}

impl From<&u64> for Snowflake {
    fn from(id: &u64) -> Self {
        Snowflake::new(*id)
    }
}
