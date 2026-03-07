use std::sync::Arc;

use crate::ffi::{BridgedGuildFolders, BridgedPreloadedUserSettings, GuildFolderRust};

pub type GuildFolder = GuildFolderRust;

#[derive(Clone, Debug)]
pub struct PreloadedUserSettings {
    pub guild_folders: GuildFolders,
}

impl PreloadedUserSettings {
    pub(crate) fn new(inner: BridgedPreloadedUserSettings) -> Self {
        Self {
            guild_folders: GuildFolders::new(inner.get_guild_folders()),
        }
    }
}

#[derive(Clone, Debug)]
pub struct GuildFolders {
    pub folders: Vec<GuildFolder>,
    pub guild_positions: Vec<u64>,
}

impl GuildFolders {
    pub(crate) fn new(inner: BridgedGuildFolders) -> Self {
        let folders = inner.get_folders();
        let folders = (0..folders.len())
            .map(|i| folders.get_unchecked(i))
            .collect();
        let guild_positions = inner.get_guild_positions();

        Self {
            folders,
            guild_positions,
        }
    }
}

impl std::fmt::Debug for BridgedPreloadedUserSettings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("BridgedPreloadedUserSettings").finish()
    }
}

impl std::fmt::Debug for GuildFolder {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("GuildFolderRust")
            .field("guild_ids", &self.guild_ids)
            .field("id", &self.id)
            .field("name", &self.name)
            .field("color", &self.color)
            .finish()
    }
}

unsafe impl Send for BridgedPreloadedUserSettings {}
unsafe impl Sync for BridgedPreloadedUserSettings {}
