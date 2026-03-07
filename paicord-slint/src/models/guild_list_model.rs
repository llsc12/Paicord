use std::collections::HashMap;

use cacache::index::find;
use lineartree::Tree;
use paicord_rs::discord_models::protobuf::preloaded_user_settings::GuildFolders;
use paicord_rs::discord_models::types::guild::Guild;
use paicord_rs::discord_models::types::snowflake::Snowflake;
use slint::{ComponentHandle, Model, ModelExt};

use crate::app::GuildStore;
use crate::images::ImageMangler;
use crate::models::guild_folder;
use crate::models::slint_tree::SlintTreeItem;
use crate::{app::GuildFolderSlint, models::slint_tree::SlintTree};

pub type GuildListModel = SlintTree<GuildFolderSlint>;

impl slint::Model for GuildListModel {
    type Data = GuildFolderSlint;

    fn row_count(&self) -> usize {
        self.get_tree_count_without_collapsed_children()
    }

    fn set_row_data(&self, row: usize, data: Self::Data) {
        self.set_item_at_row(row, data);
    }

    fn row_data(&self, row: usize) -> Option<Self::Data> {
        let node_ref = self.get_node_at_row(row)?;
        let mut node = self.get_node_data(node_ref)?;

        if node.icon.loaded {
            return Some(node);
        }

        self.lazy_load_icon(&mut node);

        Some(node)
    }

    fn model_tracker(&self) -> &dyn slint::ModelTracker {
        &self.notify
    }
}

impl GuildListModel {
    pub fn new(
        guilds: HashMap<Snowflake, Guild>,
        folders: Option<GuildFolders>,
        image_mangler: &ImageMangler,
    ) -> anyhow::Result<Self> {
        let mut tree = Tree::new();

        let root = tree.root(Default::default())?;

        let Some(folders) = folders.as_ref() else {
            for guild in guilds.values() {
                tree.child_node(root, guild.into())?;
            }

            return Ok(Self::new_with_items(tree, image_mangler.clone()));
        };

        for folder in &folders.folders {
            let Some(_) = folder.id else {
                let Some(first_id) = folder.guild_ids.first() else {
                    continue;
                };

                let Some(guild) = guilds.get(&Snowflake::from(first_id)) else {
                    continue;
                };

                tree.child_node(root, guild.into())?;

                continue;
            };

            let folder_node = tree.child_node(root, folder.into())?;

            for guild_id in &folder.guild_ids {
                let Some(guild) = guilds.get(&Snowflake::from(*guild_id)) else {
                    continue;
                };

                tree.child_node(folder_node, guild.into())?;
            }
        }

        Ok(Self::new_with_items(tree, image_mangler.clone()))
    }

    fn lazy_load_icon(&self, node: &mut GuildFolderSlint) {
        if node.icon.loaded {
            return;
        }

        let node_id = node.id.clone();

        node.icon.image = self.image_mangler.lazy_get(
            node.icon.url.to_string(),
            128,
            128,
            true,
            move |ui, image| {
                let guild_store = ui.global::<GuildStore>();
                let folders = guild_store.get_guild_folders();

                let Some((index, mut folder)) =
                    folders.iter().enumerate().find(|(_, f)| f.id == node_id)
                else {
                    return;
                };

                folder.icon.image = image;
                folder.icon.loaded = true;
                folders.set_row_data(index, folder);
            },
        );
    }
}

unsafe impl Send for GuildListModel {}
unsafe impl Sync for GuildListModel {}
