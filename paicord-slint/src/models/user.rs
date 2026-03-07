use paicord_rs::discord_models::types::{guild::PartialMember, user::PartialUser};

use crate::app::PartialUserSlint;

impl From<&PartialUser> for PartialUserSlint {
    fn from(value: &PartialUser) -> Self {
        Self {
            id: value.id.get_description().into(),
            username: value.username.clone().unwrap_or("Unknown User".to_string()).into(),
            avatar: slint::Image::default(),
            global_name: value.global_name.clone().unwrap_or("".to_string()).into(),
        }
    }
}

impl From<PartialUser> for PartialUserSlint {
    fn from(value: PartialUser) -> Self {
        Self::from(&value)
    }
}