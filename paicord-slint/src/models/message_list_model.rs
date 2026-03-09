use std::{collections::VecDeque, sync::RwLock};

use paicord_rs::{
    discord_models::types::{gateway::PartialMessage, snowflake::Snowflake},
    markdown::DiscordMarkdownParser,
};
use slint::{ComponentHandle, Model};

use crate::{
    app::{ChannelStore, DiscordMessageSlint},
    images::ImageMangler,
};

pub struct MessageListModel {
    pub messages: RwLock<VecDeque<DiscordMessageSlint>>,
    image_mangler: ImageMangler,
    notify: slint::ModelNotify,
}

impl MessageListModel {
    pub async fn new(
        messages: &Vec<PartialMessage>,
        guild_id: Option<&Snowflake>,
        markdown_parser: &DiscordMarkdownParser,
        image_mangler: &ImageMangler,
    ) -> anyhow::Result<Self> {
        let mut messages_slint = VecDeque::new();
        for message in messages {
            let msg =
                DiscordMessageSlint::from_partial(message, None, None, guild_id, markdown_parser).await?;
            messages_slint.push_back(msg);
        }

        let s = Self {
            messages: RwLock::new(messages_slint),
            image_mangler: image_mangler.clone(),
            notify: slint::ModelNotify::default(),
        };

        Ok(s)
    }

    fn lazy_load_avatar(&self, message: &mut DiscordMessageSlint) {
        if message.author.avatar.loaded {
            return;
        }

        let message_id = message.id.to_string();

        message.author.avatar.image = self.image_mangler.lazy_get(
            message.author.avatar.url.to_string(),
            128,
            128,
            true,
            move |ui, image| {
                let store = ui.global::<ChannelStore>();
                let messages = store.get_messages();

                let Some((index, mut original_message)) = messages
                    .iter()
                    .enumerate()
                    .find(|(_, m)| m.id.to_string() == message_id)
                else {
                    return;
                };

                original_message.author.avatar.image = image;
                original_message.author.avatar.loaded = true;
                messages.set_row_data(index, original_message);
            },
        );
    }

    fn lazy_load_reference_avatar(&self, message: &mut DiscordMessageSlint) {
        if message.referenced_message.id.is_empty()
            || message.referenced_message.author.avatar.loaded
        {
            return;
        }

        let message_id = message.id.to_string();

        message.referenced_message.author.avatar.image = self.image_mangler.lazy_get(
            message.referenced_message.author.avatar.url.to_string(),
            128,
            128,
            true,
            move |ui, image| {
                let store = ui.global::<ChannelStore>();
                let messages = store.get_messages();

                let Some((index, mut original_message)) = messages
                    .iter()
                    .enumerate()
                    .find(|(_, m)| m.id.to_string() == message_id)
                else {
                    return;
                };

                original_message.referenced_message.author.avatar.image = image;
                original_message.referenced_message.author.avatar.loaded = true;
                messages.set_row_data(index, original_message);
            },
        );
    }

    fn lazy_load_attachments(&self, message: &mut DiscordMessageSlint) {
        for (index, mut attachment) in message.image_attachments.iter().enumerate() {
            if attachment.loaded {
                continue;
            }

            let message_id = message.id.to_string();
            let url = attachment.url.to_string();

            let image = self.image_mangler.lazy_get(
                url,
                attachment.width as u32,
                attachment.height as u32,
                false,
                move |ui, image| {
                    let store = ui.global::<ChannelStore>();
                    let messages = store.get_messages();

                    let Some((msg_index, mut original_message)) = messages
                        .iter()
                        .enumerate()
                        .find(|(_, m)| m.id.to_string() == message_id)
                    else {
                        return;
                    };

                    let Some(mut image_attachment) =
                        original_message.image_attachments.row_data(index)
                    else {
                        return;
                    };

                    image_attachment.image = image;
                    image_attachment.loaded = true;
                    original_message
                        .image_attachments
                        .set_row_data(index, image_attachment);
                },
            );
            attachment.image = image;
            attachment.loaded = true;
            message.image_attachments.set_row_data(index, attachment);
        }
    }
}

impl Model for MessageListModel {
    type Data = DiscordMessageSlint;

    fn row_count(&self) -> usize {
        self.messages.read().unwrap().len()
    }

    fn set_row_data(&self, _row: usize, data: Self::Data) {
        let mut changed = false;
        let mut added = false;
        let mut removed = false;
        let mut row = 0;

        {
            let mut messages = self.messages.write().unwrap();

            if let Some((index, message)) = messages
                .iter_mut()
                .enumerate()
                .find(|(_, m)| m.id == data.id)
            {
                *message = data;
                row = index;
                changed = true;
            } else {
                messages.push_back(data);
                row = messages.len();
                added = true;
            }

            if messages.len() > 200 {
                messages.pop_front();
                removed = true;
            }
        }

        if changed {
            self.notify.row_changed(row);
        }

        if added {
            self.notify.row_added(row, 1);
        }

        if removed {
            self.notify.row_removed(0, 1);
        }
    }

    fn row_data(&self, row: usize) -> Option<Self::Data> {
        let mut message = {
            let messages = self.messages.read().unwrap();
            messages.get(row)?.clone()
        };

        self.lazy_load_avatar(&mut message);
        self.lazy_load_reference_avatar(&mut message);
        self.lazy_load_attachments(&mut message);

        Some(message.clone())
    }

    fn model_tracker(&self) -> &dyn slint::ModelTracker {
        &self.notify
    }
}

unsafe impl Send for MessageListModel {}
unsafe impl Sync for MessageListModel {}
