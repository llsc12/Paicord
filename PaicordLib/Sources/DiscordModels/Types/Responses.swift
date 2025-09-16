public enum Responses {

    /// https://discord.com/developers/docs/resources/channel#list-public-archived-threads-response-body
    public struct ListArchivedThreads: Sendable, Codable {
        public var threads: [DiscordChannel]
        public var members: [ThreadMember]
        public var has_more: Bool
    }

    /// https://discord.com/developers/docs/resources/guild#list-active-guild-threads-response-body
    public struct ListActiveGuildThreads: Sendable, Codable {
        public var threads: [DiscordChannel]
        public var members: [ThreadMember]
    }

    /// https://discord.com/developers/docs/resources/sticker#list-nitro-sticker-packs-response-structure
    public struct ListStickerPacks: Sendable, Codable {
        public var sticker_packs: [StickerPack]
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-prune-count
    public struct GuildPrune: Sendable, Codable {
        public var pruned: Int
    }

    /// https://discord.com/developers/docs/resources/guild#bulk-guild-ban-bulk-ban-response
    public struct GuildBulkBan: Sendable, Codable {
        public var banned_users: [UserSnowflake]
        public var failed_users: [UserSnowflake]
    }

    /// https://discord.com/developers/docs/resources/channel#start-thread-in-forum-or-media-channel
    public struct ChannelWithMessage: Sendable, Codable {
        public var channel: DiscordChannel
        public var message: DiscordChannel.Message

        private enum MessageCodingKeys: String, CodingKey {
            case message
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.channel = try container.decode(DiscordChannel.self)
            let messageContainer = try decoder.container(keyedBy: MessageCodingKeys.self)
            self.message = try messageContainer.decode(DiscordChannel.Message.self, forKey: .message)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.channel)
            var messageContainer = encoder.container(keyedBy: MessageCodingKeys.self)
            try messageContainer.encode(self.message, forKey: .message)
        }
    }

    /// https://discord.com/developers/docs/resources/poll#get-answer-voters-response-body
    public struct ListPollAnswerVoters: Sendable, Codable {
        public var users: [DiscordUser]
    }
}
