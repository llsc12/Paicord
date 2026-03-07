use paicord_rs::{discord_http::endpoints::cdn_endpoints::{self, CDNEndpoint}, discord_models::{protobuf::preloaded_user_settings::GuildFolder, types::{guild::Guild, snowflake::Snowflake}}};

use crate::{app::{GuildFolderSlint, LazyImage}, models::slint_tree::SlintTreeItem, utils};

impl SlintTreeItem for GuildFolderSlint {
    fn is_expanded(&self) -> bool {
        self.expanded && self.is_folder
    }

    fn get_id(&self) -> Snowflake {
        Snowflake::from(self.id.to_string())
    }

    fn has_children(&self) -> bool {
        self.is_folder
    }
}

impl From<&Guild> for GuildFolderSlint {
    fn from(guild: &Guild) -> Self {
        let icon_url = if let Some(icon) = &guild.icon {
            cdn_endpoints::get_cdn_url(CDNEndpoint::GuildIcon {
                guild_id: guild.id,
                icon: icon.clone(),
            })
        } else {
            String::new()
        };
        Self {
            id: guild.id.get_description().into(),
            name: guild.name.clone().into(),
            icon: LazyImage::from_url(icon_url),
            ..Default::default()
        }
    }
}

impl From<Guild> for GuildFolderSlint {
    fn from(guild: Guild) -> Self {
        Self::from(&guild)
    }
}

impl From<&GuildFolder> for GuildFolderSlint {
    fn from(folder: &GuildFolder) -> Self {
        let slint_color = if let Some(discord_color) = &folder.color {
            let (r, g, b) = discord_color.as_rgb();
            slint::Color::from_rgb_u8(r, g, b)
        } else {
            slint::Color::default()
        };

        Self {
            has_color: folder.color.is_some(),
            color: slint::Brush::SolidColor(slint_color),
            name: folder.name.clone().unwrap_or("Unknown Folder".to_string()).into(),
            is_folder: true,
            ..Default::default()
        }
    }
}

unsafe impl Send for GuildFolderSlint {}
unsafe impl Sync for GuildFolderSlint {}