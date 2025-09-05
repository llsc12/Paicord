/// https://discord.com/developers/docs/resources/poll#poll-object-poll-object-structure
public struct Poll: Sendable, Codable {

    /// https://discord.com/developers/docs/resources/poll#poll-media-object-poll-media-object-structure
    public struct Media: Sendable, Codable, ValidatablePayload {
        /// "text should always be non-null for both questions and answers, but please do not depend on that in the future."
        public var text: String?
        /// "When creating a poll answer with an emoji, one only needs to send either the id (custom emoji) or name (default emoji) as the only field."
        public var emoji: Emoji?

        public init(text: String? = nil, emojiId: EmojiSnowflake) {
            self.text = text
            self.emoji = .init(id: emojiId)
        }

        public init(text: String? = nil, emojiName: String) {
            self.text = text
            self.emoji = .init(name: emojiName)
        }

        public init(text: String) {
            self.text = text
            self.emoji = nil
        }

        public func validate() -> [ValidationFailure] {
            /// "The maximum length of text is 300 for the question, and 55 for any answer."
            /// So we can at least enforce `<= 300`.
            validateCharacterCountDoesNotExceed(text, max: 300, name: "text")
        }
    }

    /// https://discord.com/developers/docs/resources/poll#poll-answer-object-poll-answer-object-structure
    public struct Answer: Sendable, Codable {
        public var answer_id: Int?
        public var poll_media: Media

        public init(answer_id: Int? = nil, poll_media: Media) {
            self.answer_id = answer_id
            self.poll_media = poll_media
        }
    }

    /// https://discord.com/developers/docs/resources/poll#layout-type
    @UnstableEnum<Int>
    public enum LayoutKind: Sendable, Codable {
        case `default`  // 1
        case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/resources/poll#poll-results-object-poll-results-object-structure
    public struct Results: Sendable, Codable {

        /// https://discord.com/developers/docs/resources/poll#poll-results-object-poll-answer-count-object-structure
        public struct AnswerCount: Sendable, Codable {
            public var id: Int
            public var count: Int
            public var me_voted: Bool
        }

        public var is_finalized: Bool
        public var answer_counts: [AnswerCount]
    }

    public var question: Media
    public var answers: [Answer]
    public var expiry: DiscordTimestamp?
    public var allow_multiselect: Bool
    public var layout_type: LayoutKind
    public var results: Results?
}
