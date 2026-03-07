use crate::ffi;

pub type Role = ffi::RoleRust;

impl std::fmt::Debug for Role {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("RoleRust")
            .field("id", &self.id)
            // .field("name", &self.name)
            // .field("description", &self.description)
            .field("color", &self.color)
            // .field("hoist", &self.hoist)
            // .field("icon", &self.icon)
            // .field("unicode_emoji", &self.unicode_emoji)
            .field("position", &self.position)
            // .field("managed", &self.managed)
            // .field("mentionable", &self.mentionable)
            // .field("version", &self.version)
            .finish()
    }
}

unsafe impl Send for Role {}
unsafe impl Sync for Role {}