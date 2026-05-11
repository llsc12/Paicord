# Feature Checklist

Add features as needed, add features we haven't implemented yet so people can know what to work on!

## Core Architecture
- [x] REST API client
- [x] Gateway (WebSocket) connection
- [x] Gateway reconnect + resume
- [x] Rate limit handling
- [x] Event dispatcher system
- [x] Captcha handling
- [x] Super-properties
- [x] Error handling + retry logic
- [x] CDN asset fetching (avatars, attachments, emojis etc.)

---

# Authentication & Account

## Login / Auth
- [x] Login email-password
- [x] 2FA support
- [x] Token refresh
- [x] Multi-account support
- [x] Account switching

## Account Settings
- [ ] Change username
- [ ] Change avatar
- [ ] Change banner
- [ ] Change bio / profile fields
- [ ] Email / password change
- [ ] Language settings
- [ ] Theme settings
- [ ] Accessibility settings

## User Profiles
- [x] View profile
- [ ] Mutual servers
- [ ] Mutual friends
- [ ] Custom status
- [x] Activity / presence display
- [x] Profile badges

---

# Friends & Social

## Friends
- [ ] Send friend request
- [ ] Accept / reject friend request
- [ ] Cancel outgoing request
- [ ] Remove friend
- [ ] Friend list UI
- [x] Online / offline indicators

## Blocks
- [ ] Block user
- [ ] Unblock user
- [ ] Block list

## Relationships
- [ ] Incoming requests
- [ ] Outgoing requests

---

# Presence System

- [x] Online / Idle / DND / Invisible
- [ ] Custom status
- [ ] Activity presence
- [ ] Rich presence display
- [ ] Streaming status
- [ ] Game activity

---

# Messaging

## Direct Messages
- [x] Open DM
- [ ] Create DM channel
- [x] Group DMs
- [ ] Leave group DM
- [ ] Rename group DM
- [ ] Add / remove participants

## Sending Messages
- [x] Send text message
- [x] Edit message
- [x] Delete message
- [x] Reply to message
- [ ] Message forwarding
- [ ] Entity autocompletions (mentions, commands etc.)

## Message Content
- [x] Markdown formatting
- [x] Rich embeds
- [x] Mentions
- [x] Role mentions
- [x] Channel mentions
- [x] Custom emoji
- [x] Unicode emoji
- [x] Stickers
- [ ] Attach files
- [x] Image embeds
- [x] Link previews
- [ ] Spoiler tags
- [x] Code blocks

## Message Reactions

- [ ] Create reaction
- [x] Add reaction
- [x] Remove reaction
- [ ] Reaction picker
- [x] Reaction counts

## Message Interaction
- [ ] Buttons
- [ ] Select menus
- [ ] Slash command responses
- [ ] Modals
- [ ] Components V2

## Message Threads
- [ ] Create thread
- [ ] Join thread
- [ ] Leave thread
- [ ] Archive thread
- [ ] Thread list

## Message Management
- [ ] Pin message
- [ ] Unpin message
- [ ] Message search
- [ ] Jump to message
- [ ] Message history pagination

---

# Notifications

- [ ] Local notifications
- [ ] Notification badges
- [ ] Mention notifications
- [ ] Role mention notifications
- [ ] Thread notifications
- [ ] Per-channel notification settings
- [ ] Do Not Disturb
- [ ] iOS persistent background gateway connection

---

# Servers (Guilds)

## Guild Basics
- [ ] Create server
- [ ] Join server
- [ ] Leave server
- [ ] Delete server
- [ ] Server invite links

## Server Settings
- [x] Server name / icon
- [x] Server banner
- [ ] Server description
- [ ] Community settings
- [ ] Verification level
- [ ] Moderation settings

## Members
- [x] Member list
- [ ] Member search
- [x] Member roles display
- [ ] Member join / leave events
- [ ] Kick member
- [ ] Ban member
- [ ] Timeout member

## Roles
- [ ] Create role
- [ ] Edit role
- [ ] Delete role
- [ ] Assign role
- [ ] Role permissions

## Channels
- [ ] Create channel
- [ ] Edit channel
- [ ] Delete channel
- [ ] Channel categories
- [ ] Channel permissions

## Channel Types
- [ ] Text channels
- [ ] Voice channels
- [ ] Stage channels
- [ ] Forum channels
- [ ] Announcement channels

---

# Voice & Video

## Voice Connection
- [x] Join voice channel
- [x] Leave voice channel
- [x] Voice gateway connection
- [x] Voice transport encryption
- [x] Voice DAVE E2EE support

## Voice Controls
- [ ] Mute
- [ ] Deafen
- [ ] Push-to-talk
- [ ] Voice activity detection
- [ ] Input device selection
- [ ] Output device selection
- [ ] Volume control

## Voice Features
- [ ] Video calls
- [ ] Screen sharing
- [ ] Stream viewing
- [ ] Camera toggle
- [ ] Noise suppression

## Voice Moderation
- [ ] Server mute
- [ ] Server deafen
- [ ] Move user
- [ ] Disconnect user

---

# Media & Assets

- [x] Image attachments
- [x] Video attachments
- [x] File uploads
- [x] File downloads
- [x] Animated GIF support
- [x] CDN caching
- [x] Avatar rendering
- [x] Emoji rendering
- [x] Sticker rendering

---

# Emojis & Stickers

- [ ] Server emoji list
- [ ] Upload emoji
- [ ] Delete emoji
- [ ] Emoji/Sticker/GIF picker component

---

# Search & Discovery

- [ ] Message search
- [ ] Server search
- [ ] Channel search
- [ ] Member search
- [ ] Emoji search
- [ ] GIF search

---

# Moderation

- [ ] Audit log viewer
- [ ] Message delete logging
- [ ] Ban list
- [ ] Timeout system
- [ ] Slow mode
- [ ] Auto moderation

---

# Integrations

- [ ] Slash commands
- [ ] Application commands
- [ ] Webhooks
- [ ] External integrations

---

# Events

- [ ] Scheduled events
- [ ] Event creation
- [ ] Event reminders
- [ ] Event management

---

# UI / Client

## Layout
- [x] Server list
- [x] Channel list
- [x] Member list
- [x] Chat view
- [ ] Thread sidebar

## UI Features
- [x] Dark mode
- [x] Light mode
- [ ] Theme customization
- [ ] Compact mode
- [x] Font scaling
- [ ] Accessibility features

---

# Advanced Features

- [ ] Message drafts
- [x] Typing indicators
- [ ] Read receipts
- [ ] Read state sync
- [x] Message queue
- [ ] Custom themes
