use std::collections::HashMap;

use cacache::index::find;
use lineartree::Tree;
use paicord_rs::discord_models::protobuf::preloaded_user_settings::GuildFolders;
use paicord_rs::discord_models::types::channel::DiscordChannelKind;
use paicord_rs::discord_models::types::guild::Guild;
use paicord_rs::discord_models::types::snowflake::Snowflake;
use slint::{ComponentHandle, Model, ModelExt};

use crate::app::{DiscordChannelSlint, GuildStore};
use crate::images::ImageMangler;
use crate::models::guild_folder;
use crate::models::slint_tree::SlintTreeItem;
use crate::{app::GuildFolderSlint, models::slint_tree::SlintTree};

pub type ChannelListModel = SlintTree<DiscordChannelSlint>;

impl slint::Model for ChannelListModel {
    type Data = DiscordChannelSlint;

    fn row_count(&self) -> usize {
        self.get_tree_count_without_collapsed_children()
    }

    fn set_row_data(&self, row: usize, data: Self::Data) {
        self.set_item_at_row(row, data);
    }

    fn row_data(&self, row: usize) -> Option<Self::Data> {
        let node_ref = self.get_node_at_row(row)?;
        self.get_node_data(node_ref)
    }

    fn model_tracker(&self) -> &dyn slint::ModelTracker {
        &self.notify
    }
}

impl ChannelListModel {
    pub fn new(guild: &Guild, image_mangler: &ImageMangler) -> anyhow::Result<Self> {
        let mut tree = Tree::new();

        let root = tree.root(Default::default())?;

        let mut orphan_channels = guild
            .channels
            .iter()
            .filter(|channel| channel.parent_id.is_none())
            .collect::<Vec<_>>();

        orphan_channels.sort_by(|left, right| {
            let left_is_category = left.kind == Some(DiscordChannelKind::GuildCategory);
            let right_is_category = right.kind == Some(DiscordChannelKind::GuildCategory);

            if left_is_category == right_is_category {
                return left.position.unwrap_or(0).cmp(&right.position.unwrap_or(0));
            } else {
                if left_is_category {
                    std::cmp::Ordering::Greater
                } else {
                    std::cmp::Ordering::Less
                }
            }
        });

        for channel in orphan_channels {
            let channel_node = tree.child_node(root, channel.into())?;

            if channel.kind != Some(DiscordChannelKind::GuildCategory) {
                continue;
            }

            let mut children = guild
                .channels
                .iter()
                .filter(|c| c.parent_id == Some(channel.id))
                .collect::<Vec<_>>();

            children.sort_by(|left, right| left.position.unwrap_or(0).cmp(&right.position.unwrap_or(0)));

            for child in children {
                tree.child_node(channel_node, child.into())?;
            }
        }

        Ok(Self::new_with_items(tree, image_mangler.clone()))
    }
}

unsafe impl Send for ChannelListModel {}
unsafe impl Sync for ChannelListModel {}
