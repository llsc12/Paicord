import AsyncHTTPClient
import Atomics
/// Avoid `@tesatable` for `Discord***` targets just to make sure everything we use
/// here is also accessible by the public (e.g. the initializers of different types)
import DiscordClientLib
import DiscordHTTP
import NIOCore
import XCTest

class DiscordClientTests: XCTestCase {

    /// Don't change this to `HTTPClient.shared` to have a test for not using `HTTPClient.shared`.
    let httpClient = HTTPClient()
    var client: (any DiscordClient)!

    let permanentTestCommandName = "permanent-test-command"

    override func setUp() async throws {
        self.client = await DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token,
            /// For not failing tests
            configuration: .init(retryPolicy: .init(backoff: .basedOnHeaders(maxAllowed: 10)))
        )
        await GatewayTester.shared.increaseTestsRanThenStartIfNeeded(httpClient: httpClient)
    }

    override func tearDown() async throws {
        await GatewayTester.shared.endIfNeeded()
    }

    /// Can't use the async `shutdown()` in `tearDown()`. Will get `Fatal error: leaking promise created at (file: "NIOPosix/HappyEyeballs.swift", line: 300)`
    deinit {
        try! httpClient.syncShutdown()
    }

    func testAppIdSetting() async throws {
        /// Tests that it can extract an app-id from a bot-token even if not provided.
        let client1 = await DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token
        )
        XCTAssertEqual(client1.appId?.rawValue, Constants.botId.rawValue)

        /// Tests that the provided app-id overrides the bot-token-extracted app-id
        let client2 = await DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token,
            appId: ApplicationSnowflake("000")
        )
        XCTAssertEqual(client2.appId?.rawValue, "000")
    }

    /// Just here so you know.
    /// We can't initiate interactions with automations (not officially at least), so can't test.
    func testInteractions() {}

    func testGateway() async throws {
        /// Get from "gateway"
        let url = try await client.getGateway().decode().url
        XCTAssertTrue(url.contains("wss://"), "payload: \(url)")
        XCTAssertTrue(url.contains("discord"), "payload: \(url)")

        /// Get from "bot gateway"
        let botInfo = try await client.getBotGateway().decode()

        XCTAssertTrue(botInfo.url.contains("wss://"), "payload: \(botInfo)")
        XCTAssertTrue(botInfo.url.contains("discord"), "payload: \(botInfo)")
        let limitInfo = botInfo.session_start_limit
        let numbers = [
            limitInfo.max_concurrency,
            limitInfo.remaining,
            limitInfo.total,
        ]
        XCTAssertTrue(numbers.allSatisfy({ $0 != 0 }), "payload: \(botInfo)")
    }

    func testMessages() async throws {

        /// Cleanup: Get channel messages and delete messages by the bot itself, if any.
        /// Makes this test resilient to failing when it has failed the last time.
        let allOldMessages = try await client.listMessages(
            channelId: Constants.Channels.general.id
        ).decode()

        for message in allOldMessages where message.author?.id == Constants.botId {
            try await client.deleteMessage(
                channelId: message.channel_id,
                messageId: message.id
            ).guardSuccess()
        }

        /// Trigger typing indicator
        try await client.triggerTypingIndicator(
            channelId: Constants.Channels.general.id
        ).guardSuccess()

        /// Create
        let userMention = DiscordUtils.mention(id: Constants.personalId)
        let text = "Testing! \(Date()) \(userMention)"
        let message = try await client.createMessage(
            channelId: Constants.Channels.general.id,
            payload: .init(
                content: text,
                /// Allowed mention doesn't allow mentioning any users.
                allowed_mentions: .init(
                    /// `parse` doesn't allow user mentions.
                    parse: [.roles],
                    /// `users` overrides what `parse` says, to allow to mention me.
                    users: [Constants.personalId]
                ),
                /// Reply to a non-existent message
                message_reference: .init(
                    message_id: .makeFake(),
                    channel_id: Constants.Channels.general.id,
                    guild_id: Constants.guildId,
                    fail_if_not_exists: false
                ),
                components: [
                    [
                        .button(.init(label: "Go to mahdibm.com!", url: "https://mahdibm.com")),
                        .button(.init(style: .danger, emoji: .init(name: "🐥"), custom_id: "heyyyy")),
                    ]
                ]
            )
        ).decode()

        XCTAssertEqual(message.content, text)
        XCTAssertEqual(message.channel_id, Constants.Channels.general.id)

        /// Edit
        let newText = "Edit Testing! \(Date())"
        let edited = try await client.updateMessage(
            channelId: Constants.Channels.general.id,
            messageId: message.id,
            payload: .init(embeds: [
                .init(
                    description: newText,
                    provider: .init(
                        name: "MahdiBM",
                        url: "https://mahdibm.com"
                    )
                )
            ])
        ).decode()

        XCTAssertEqual(edited.content, text)
        XCTAssertEqual(edited.embeds.first?.description, newText)
        XCTAssertEqual(edited.channel_id, Constants.Channels.general.id)

        /// Add 4 Reactions
        let reactions = ["🚀", "🤠", "👀", "❤️"]
        for reaction in reactions {
            try await client.addMessageReaction(
                channelId: Constants.Channels.general.id,
                messageId: message.id,
                emoji: .unicodeEmoji(reaction)
            ).guardSuccess()
        }

        try await client.deleteOwnMessageReaction(
            channelId: Constants.Channels.general.id,
            messageId: message.id,
            emoji: .unicodeEmoji(reactions[0])
        ).guardSuccess()

        try await client.deleteUserMessageReaction(
            channelId: Constants.Channels.general.id,
            messageId: message.id,
            emoji: .unicodeEmoji(reactions[1]),
            userId: Snowflake(Constants.botId)
        ).guardSuccess()

        let listMessageReactionsByEmojiResponseNormal = try await client.listMessageReactionsByEmoji(
            channelId: Constants.Channels.general.id,
            messageId: message.id,
            emoji: .unicodeEmoji(reactions[2]),
            type: .normal
        ).decode()

        XCTAssertEqual(listMessageReactionsByEmojiResponseNormal.count, 1)

        let reactionUser = try XCTUnwrap(listMessageReactionsByEmojiResponseNormal.first)
        XCTAssertEqual(reactionUser.id, Constants.botId)

        let listMessageReactionsByEmojiResponseBurst = try await client.listMessageReactionsByEmoji(
            channelId: Constants.Channels.general.id,
            messageId: message.id,
            emoji: .unicodeEmoji(reactions[2]),
            type: .burst
        ).decode()

        XCTAssertEqual(listMessageReactionsByEmojiResponseBurst.count, 0)

        try await client.deleteAllMessageReactionsByEmoji(
            channelId: Constants.Channels.general.id,
            messageId: message.id,
            emoji: .unicodeEmoji(reactions[2])
        ).guardSuccess()

        try await client.deleteAllMessageReactions(
            channelId: Constants.Channels.general.id,
            messageId: message.id
        ).guardSuccess()

        /// Get the message again
        let retrievedMessage = try await client.getMessage(
            channelId: Constants.Channels.general.id,
            messageId: message.id
        ).decode()

        XCTAssertEqual(retrievedMessage.id, edited.id)
        XCTAssertEqual(retrievedMessage.content, edited.content)
        XCTAssertEqual(retrievedMessage.channel_id, edited.channel_id)
        XCTAssertEqual(retrievedMessage.embeds.first?.description, edited.embeds.first?.description)
        XCTAssertFalse(retrievedMessage.reactions?.isEmpty == false)

        /// Get channel messages
        let allMessages = try await client.listMessages(
            channelId: Constants.Channels.general.id
        ).decode()

        XCTAssertGreaterThan(allMessages.count, 2)
        XCTAssertEqual(allMessages[0].id, edited.id)
        XCTAssertEqual(allMessages[1].content, "And this is another test message :\\)")
        XCTAssertEqual(allMessages[2].content, "Hello! This is a test message!")

        /// Get channel messages with `limit == 2`
        let allMessagesLimit = try await client.listMessages(
            channelId: Constants.Channels.general.id,
            limit: 2
        ).decode()

        XCTAssertEqual(allMessagesLimit.count, 2)

        /// Get channel messages with `after`
        let allMessagesAfter = try await client.listMessages(
            channelId: Constants.Channels.general.id,
            after: allMessages[1].id
        ).decode()

        XCTAssertEqual(allMessagesAfter.count, 1)

        /// Get channel messages with `before`
        let allMessagesBefore = try await client.listMessages(
            channelId: Constants.Channels.general.id,
            before: allMessages[2].id
        ).decode()

        XCTAssertEqual(allMessagesBefore.count, 0)

        /// Get channel messages with `around`
        let allMessagesAround = try await client.listMessages(
            channelId: Constants.Channels.general.id,
            around: allMessages[1].id
        ).decode()

        XCTAssertEqual(allMessagesAround.count, 3)

        /// Pin Message
        try await client.pinMessage(
            channelId: Constants.Channels.general.id,
            messageId: message.id,
            reason: "Testing Pin Messages!"
        ).guardSuccess()

        /// List Pinned Message
        let pinnedMessage = try await client.listPinnedMessages(
            channelId: Constants.Channels.general.id
        ).decode()

        XCTAssertEqual(pinnedMessage.count, 1)
        let first = try XCTUnwrap(pinnedMessage.first)

        XCTAssertEqual(first.id, message.id)

        /// Unpin Message
        try await client.unpinMessage(
            channelId: Constants.Channels.general.id,
            messageId: message.id,
            reason: "Testing Deleting Pin Messages!"
        ).guardSuccess()

        XCTAssertTrue(message.type.isDeletable)
        /// Delete
        try await client.deleteMessage(
            channelId: Constants.Channels.general.id,
            messageId: message.id,
            reason: "Random reason " + UUID().uuidString
        ).guardSuccess()
    }

    func testMoreMessage() async throws {
        let message = try await client.createMessage(
            channelId: Constants.Channels.announcements.id,
            payload: .init(content: "Announcement crosspost test!")
        ).decode()

        _ = try await client.crosspostMessage(
            channelId: Constants.Channels.announcements.id,
            messageId: message.id
        ).decode()

        let message2 = try await client.createMessage(
            channelId: Constants.Channels.announcements.id,
            payload: .init(content: "For bulk delete :)")
        ).decode()

        try await client.bulkDeleteMessages(
            channelId: Constants.Channels.announcements.id,
            reason: "Bulk delete test!",
            payload: .init(messages: [message.id, message2.id])
        ).guardSuccess()
    }

    func testPolls() async throws {
        let message = try await client.createMessage(
            channelId: Constants.Channels.spam.id,
            payload: .init(
                content: "Here's a Poll!",
                poll: .init(
                    question: .init(
                        text: "How you doin'?"
                    ),
                    answers: [
                        .init(
                            poll_media: .init(
                                text: "Good"
                            )
                        ),
                        .init(
                            poll_media: .init(
                                text: "Not bad",
                                emojiId: Constants.serverEmojiId
                            )
                        ),
                        .init(
                            poll_media: .init(
                                text: "Great",
                                emojiName: "🤠"
                            )
                        ),
                    ],
                    duration: 120,
                    allow_multiselect: true,
                    layout_type: .default
                )
            )
        ).decode()

        let answerId = try XCTUnwrap(message.poll?.answers.first?.answer_id)

        let voters = try await self.client.listPollAnswerVotes(
            channelId: message.channel_id,
            messageId: message.id,
            answerId: answerId
        ).decode()

        XCTAssertEqual(voters.users.count, 0, "\(voters.users)")

        try await self.client.endPoll(
            channelId: message.channel_id,
            messageId: message.id
        ).guardSuccess()
    }

    func testGlobalApplicationCommands() async throws {
        /// Cleanup before start

        let oldCommands = try await client.listApplicationCommands()
            .decode()
            .filter { $0.name != permanentTestCommandName }

        for command in oldCommands {
            try await client.deleteApplicationCommand(commandId: command.id).guardSuccess()
        }

        /// Create
        let commandName1 = "test-command"
        let commandDesc1 = "Testing!"
        let command1 = try await client.createApplicationCommand(
            payload: .init(
                name: commandName1,
                description: commandDesc1,
                description_localizations: [
                    .spanish: "ES_\(commandDesc1)",
                    .german: "DE_\(commandDesc1)",
                ]
            )
        ).decode()

        XCTAssertEqual(command1.name, commandName1)
        XCTAssertEqual(command1.description, commandDesc1)
        XCTAssertEqual(command1.description_localizations?.values.count, 2)

        /// Get one
        let oneCommand = try await client.getApplicationCommand(
            commandId: command1.id
        ).decode()
        XCTAssertEqual(oneCommand.name, commandName1)
        XCTAssertEqual(oneCommand.description, commandDesc1)

        /// Edit
        let commandName2 = "test-command-2"
        let command2 = try await client.updateApplicationCommand(
            commandId: command1.id,
            payload: .init(
                name: commandName2,
                options: [
                    .init(
                        type: .string,
                        name: "test-option",
                        description: "test-option description"
                    )
                ]
            )
        ).decode()

        XCTAssertEqual(command2.name, commandName2)

        /// Get all
        let allCommands = try await client.listApplicationCommands()
            .decode()
            .filter { $0.name != permanentTestCommandName }

        XCTAssertEqual(allCommands.count, 1)
        let retrievedCommand1 = try XCTUnwrap(allCommands.first)
        XCTAssertEqual(retrievedCommand1.name, commandName2)
        XCTAssertEqual(retrievedCommand1.description, commandDesc1)

        /// Bulk overwrite
        let commandName3 = "test-command-3"
        let commandType3: ApplicationCommand.Kind = .user
        let overwrite = try await client.bulkSetApplicationCommands(
            payload: [
                .init(
                    name: commandName3,
                    type: commandType3
                ),
                .init(
                    name: permanentTestCommandName,
                    description: "Permanent test command description"
                ),
            ]
        ).decode().filter {
            $0.name != permanentTestCommandName
        }

        XCTAssertEqual(overwrite.count, 1)
        let overwriteCommand1 = try XCTUnwrap(overwrite.first)
        XCTAssertEqual(overwriteCommand1.name, commandName3)
        XCTAssertEqual(overwriteCommand1.type, commandType3)

        /// Delete
        let commandId = try XCTUnwrap(overwriteCommand1.id)
        try await client.deleteApplicationCommand(
            commandId: commandId
        ).guardSuccess()
    }

    func testGuildApplicationCommands() async throws {
        /// Cleanup

        let oldCommands = try await client.listGuildApplicationCommands(
            guildId: Constants.guildId
        ).decode()

        for command in oldCommands {
            try await client.deleteGuildApplicationCommand(
                guildId: Constants.guildId,
                commandId: command.id
            ).guardSuccess()
        }

        /// Create
        let commandName1 = "test-guild-command"
        let commandDesc1 = "Testing!"
        let command1 = try await client.createGuildApplicationCommand(
            guildId: Constants.guildId,
            payload: .init(
                name: commandName1,
                description: commandDesc1,
                description_localizations: [
                    .spanish: "ES_\(commandDesc1)",
                    .german: "DE_\(commandDesc1)",
                ]
            )
        ).decode()

        XCTAssertEqual(command1.name, commandName1)
        XCTAssertEqual(command1.description, commandDesc1)
        XCTAssertEqual(command1.description_localizations?.values.count, 2)

        /// Get one
        let oneCommand = try await client.getGuildApplicationCommand(
            guildId: Constants.guildId,
            commandId: command1.id
        ).decode()
        XCTAssertEqual(oneCommand.name, commandName1)
        XCTAssertEqual(oneCommand.description, commandDesc1)

        let permissions = try await client.listGuildApplicationCommandPermissions(
            guildId: Constants.guildId
        ).decode()

        let firstPermissionGroup = try XCTUnwrap(permissions.first)

        let onePermissionGroup = try await client.getGuildApplicationCommandPermissions(
            guildId: Constants.guildId,
            commandId: Snowflake(firstPermissionGroup.id)
        ).decode()

        XCTAssertEqual(onePermissionGroup.id, firstPermissionGroup.id)

        /// Edit
        let commandName2 = "test-guild-command-2"
        let command2 = try await client.updateGuildApplicationCommand(
            guildId: Constants.guildId,
            commandId: command1.id,
            payload: .init(name: commandName2)
        ).decode()

        XCTAssertEqual(command2.name, commandName2)

        /// Get all
        let allCommands = try await client.listGuildApplicationCommands(
            guildId: Constants.guildId
        ).decode()

        XCTAssertEqual(allCommands.count, 1)
        let retrievedCommand1 = try XCTUnwrap(allCommands.first)
        XCTAssertEqual(retrievedCommand1.name, commandName2)
        XCTAssertEqual(retrievedCommand1.description, commandDesc1)

        /// Bulk overwrite
        let commandName3 = "test-guild-command-3"
        let commandType3: ApplicationCommand.Kind = .user
        let overwrite = try await client.bulkSetGuildApplicationCommands(
            guildId: Constants.guildId,
            payload: [
                .init(
                    name: commandName3,
                    type: commandType3
                )
            ]
        ).decode()

        XCTAssertEqual(overwrite.count, 1)
        let overwriteCommand1 = try XCTUnwrap(overwrite.first)
        XCTAssertEqual(overwriteCommand1.name, commandName3)
        XCTAssertEqual(overwriteCommand1.type, commandType3)

        /// Delete
        let commandId = try XCTUnwrap(overwriteCommand1.id)
        try await client.deleteGuildApplicationCommand(
            guildId: Constants.guildId,
            commandId: commandId
        ).guardSuccess()
    }

    func testGuildWithCreatedGuild() async throws {
        let guildName = "Test Guild"

        /// Cleanup
        for guild in try await client.listOwnGuilds().decode() {
            if guild.name?.hasPrefix(guildName) == true {
                try await client.deleteGuild(id: guild.id).guardSuccess()
            }
        }

        let createdGuild = try await client.createGuild(payload: .init(name: guildName)).decode()
        XCTAssertEqual(createdGuild.name, guildName)

        let newGuildName = guildName + " Updated Name"
        let updateGuild = try await client.updateGuild(
            id: createdGuild.id,
            payload: .init(name: newGuildName)
        ).decode()

        XCTAssertEqual(updateGuild.id, createdGuild.id)
        XCTAssertEqual(updateGuild.name, newGuildName)

        /// Can't leave guild because the bot is the owner
        let leaveGuildError = try await client.leaveGuild(id: createdGuild.id).asError()

        switch leaveGuildError {
        case let .jsonError(jsonError) where jsonError.code == .invalidGuild:
            break
        case .none, .badStatusCode, .jsonError:
            XCTFail("Unexpected error: \(String(describing: leaveGuildError))")
        }

        _ = try await client.previewPruneGuild(
            guildId: Constants.guildId,
            days: 30,
            /// The role is unrelated to this guild though.
            includeRoles: [Constants.adminRoleId]
        ).decode()

        _ = try await client.pruneGuild(
            guildId: createdGuild.id,
            reason: "Testing Guild Prune!",
            payload: .init(
                days: 30,
                compute_prune_count: true,
                /// The role is unrelated to this guild though.
                include_roles: [Constants.adminRoleId]
            )
        ).decode()

        /// This endpoint requires guild ownership!
        try await client.setGuildMfaLevel(
            guildId: createdGuild.id,
            reason: "Testing MFA!",
            payload: .init(level: Bool.random() ? .elevated : .none)
        ).guardSuccess()

        try await client.deleteGuild(id: createdGuild.id).guardSuccess()
    }

    func testGuildAndChannel() async throws {
        /// Get
        let guild = try await client.getGuild(
            id: Constants.guildId,
            withCounts: false
        ).decode()

        XCTAssertEqual(guild.id, Constants.guildId)
        XCTAssertEqual(guild.name, Constants.guildName)
        XCTAssertEqual(guild.approximate_member_count, nil)
        XCTAssertEqual(guild.approximate_presence_count, nil)

        /// Get with counts
        let guildWithCounts = try await client.getGuild(
            id: Constants.guildId,
            withCounts: true
        ).decode()

        XCTAssertEqual(guildWithCounts.id, Constants.guildId)
        XCTAssertEqual(guildWithCounts.name, Constants.guildName)
        XCTAssertEqual(guildWithCounts.approximate_member_count, 3)
        XCTAssertNotEqual(guildWithCounts.approximate_presence_count, nil)

        /// Get guild channels
        let channels =
            try await client
            .listGuildChannels(guildId: Constants.guildId)
            .decode()

        XCTAssertTrue(channels.map(\.id).contains(Constants.Channels.general.id), "\(channels)")

        try await client.updateGuildChannelPositions(
            guildId: Constants.guildId,
            payload: [.init(id: Constants.Channels.perm1.id, position: Int.random(in: 1...5))]
        ).guardSuccess()

        /// Create channel
        let createChannel = try await client.createGuildChannel(
            guildId: Constants.guildId,
            reason: "Testing",
            payload: .init(
                name: "Test-Create-Channel",
                default_reaction_emoji: .init(emoji_name: "🐥")
            )
        ).decode()

        /// Get channel
        let getChannel = try await client.getChannel(id: createChannel.id).decode()

        XCTAssertEqual("\(getChannel)", "\(createChannel)")

        let topic = "Test Topic"
        let updateChannel = try await client.updateGuildChannel(
            id: createChannel.id,
            payload: .init(
                topic: topic,
                default_reaction_emoji: .init(emoji_id: Constants.serverEmojiId)
            )
        ).decode()

        XCTAssertEqual(updateChannel.id, createChannel.id)
        XCTAssertEqual(updateChannel.topic, topic)

        /// Follow announcement channel to this channel
        try await client.followAnnouncementChannel(
            id: Constants.Channels.announcements.id,
            reason: "Because I want to!",
            payload: .init(webhook_channel_id: createChannel.id)
        ).guardSuccess()

        try await client.deleteChannel(id: createChannel.id).guardSuccess()
    }

    func testChannelPermissions() async throws {
        let overwriteId = AnySnowflake(Constants.secondAccountId)

        try await client.setChannelPermissionOverwrite(
            channelId: Constants.Channels.general.id,
            overwriteId: overwriteId,
            reason: "Testing Permissions Set!",
            payload: .init(
                type: .member,
                allow: [.addReactions],
                deny: [.useExternalEmojis]
            )
        ).guardSuccess()

        try await client.deleteChannelPermissionOverwrite(
            channelId: Constants.Channels.general.id,
            overwriteId: overwriteId,
            reason: "Testing Permissions Delete!"
        ).guardSuccess()
    }

    func testInvites() async throws {
        let invite = try await client.createChannelInvite(
            channelId: Constants.Channels.spam.id,
            payload: .init(
                max_age: 30,
                max_uses: .unlimited,
                temporary: true,
                unique: true,
                target_type: nil,
                target_user_id: nil,
                target_application_id: nil
            )
        ).decode()

        let guildInvites =
            try await client
            .listGuildInvites(guildId: Constants.guildId)
            .decode()

        XCTAssertGreaterThan(guildInvites.count, 0)
        XCTAssertTrue(
            guildInvites.map(\.code).contains(invite.code),
            "\(guildInvites) did not contain \(invite.code)"
        )

        let channelInvites = try await client.listChannelInvites(
            channelId: Constants.Channels.spam.id
        ).decode()

        XCTAssertGreaterThan(channelInvites.count, 0)
        XCTAssertTrue(
            channelInvites.map(\.code).contains(invite.code),
            "\(guildInvites) did not contain \(invite.code)"
        )

        let resolved = try await client.resolveInvite(code: invite.code).decode()

        XCTAssertEqual(resolved.code, invite.code)

        try await client.revokeInvite(code: invite.code).guardSuccess()
    }

    func testGuildMembers() async throws {

        /// Search Guild members
        let search = try await client.searchGuildMembers(
            guildId: Constants.guildId,
            query: "Mahdi",
            limit: nil
        ).decode()

        XCTAssertTrue((1...5).contains(search.count), search.count.description)
        XCTAssertTrue(
            search.contains(where: { $0.user?.global_name?.contains("Mahdi") == true }),
            "\(search)"
        )

        /// Search Guild members with invalid limit
        do {
            _ = try await client.searchGuildMembers(
                guildId: Constants.guildId,
                query: "Mahdi",
                limit: 10_000
            )
            XCTFail("'searchGuildMembers' must fail with too-big limits")
        } catch {
            switch error {
            case DiscordHTTPError.queryParameterOutOfBounds(
                name: "limit",
                value: "10000",
                lowerBound: 1,
                upperBound: 1_000
            ):
                break
            default:
                XCTFail("Unexpected fail error: \(error)")
            }
        }

        let anotherMember = try await client.getGuildMember(
            guildId: Constants.guildId,
            userId: Constants.personalId
        ).decode()

        XCTAssertEqual(anotherMember.user?.id, Constants.personalId)

        let avatar = try XCTUnwrap(anotherMember.user?.avatar)
        let file = try await client.getCDNUserAvatar(
            userId: Constants.personalId,
            avatar: avatar
        ).getFile()
        XCTAssertGreaterThan(file.data.readableBytes, 100)

        /// Can't add anyone since don't have access token.
        let addMemberError = try await client.addGuildMember(
            guildId: Constants.guildId,
            userId: .makeFake(),
            payload: .init(
                access_token: "",
                nick: "nicko",
                roles: nil,
                mute: true,
                deaf: true
            )
        ).asError()

        switch addMemberError {
        case let .jsonError(jsonError) where jsonError.code == .invalidOAuth2AccessToken:
            break
        case .none, .badStatusCode, .jsonError:
            XCTFail("Unexpected error: \(String(describing: addMemberError))")
        }

        /// Can't really delete anyone, since can't add.
        let deleteMemberError = try await client.deleteGuildMember(
            guildId: Constants.guildId,
            userId: .makeFake()
        ).asError()

        switch deleteMemberError {
        case let .jsonError(jsonError) where jsonError.code == .unknownUser:
            break
        case .none, .badStatusCode, .jsonError:
            XCTFail("Unexpected error: \(String(describing: deleteMemberError))")
        }

        let newNick = "TestBotNick\(Int.random(in: 0..<100))"
        let memberUpdate = try await client.updateOwnGuildMember(
            guildId: Constants.guildId,
            payload: .init(nick: newNick)
        ).decode()

        XCTAssertEqual(memberUpdate.nick, newNick)

        let updatedMember = try await client.updateGuildMember(
            guildId: Constants.guildId,
            userId: Constants.secondAccountId,
            reason: "Testing Guild Member Edit!",
            payload: .init(
                nick: "NewNick\(Int.random(in: 0..<100))",
                roles: [Constants.dummyRoleId],
                /// These next 3 fields are voice-related. Will throw an error if we attempt
                /// to set them, considering the target user is not connected to voice.
                mute: nil,
                deaf: nil,
                channel_id: nil,
                communication_disabled_until: .init(date: Date().addingTimeInterval(30)),
                flags: [.completedOnboarding, .bypassVerification]
            )
        ).decode()

        XCTAssertEqual(updatedMember.user?.id, Constants.secondAccountId)

        let allMembers =
            try await client
            .listGuildMembers(guildId: Constants.guildId)
            .decode()

        XCTAssertGreaterThanOrEqual(allMembers.count, 1, "\(allMembers)")

        if allMembers.count < 1 {
            return XCTFail("Members count too low: \(allMembers)")
        }

        let second = allMembers[0]

        let userId = try XCTUnwrap(second.user?.id)

        let limitedMembers = try await client.listGuildMembers(
            guildId: Constants.guildId,
            limit: 1,
            after: userId
        ).decode()

        XCTAssertGreaterThanOrEqual(limitedMembers.count, 1, "\(limitedMembers)")
    }

    func testGuildBans() async throws {
        let userId: UserSnowflake = "950695294906007573"
        let reason = "Testing Guild Bans!"

        try await client.banUserFromGuild(
            guildId: Constants.guildId,
            userId: userId,
            reason: reason,
            payload: .init(delete_message_seconds: 60)
        ).guardSuccess()

        let ban = try await client.getGuildBan(
            guildId: Constants.guildId,
            userId: userId
        ).decode()

        XCTAssertEqual(ban.reason, reason)
        XCTAssertEqual(ban.user.id, userId)

        let bans = try await client.listGuildBans(
            guildId: Constants.guildId
        ).decode()

        XCTAssertTrue(bans.map(\.user.id).contains(ban.user.id), "\(bans) did not contain \(ban)")

        try await client.unbanUserFromGuild(
            guildId: Constants.guildId,
            userId: userId
        ).guardSuccess()
    }

    func testGuildBulkBan() async throws {
        let userId: UserSnowflake = "950695294906007573"
        let reason = "Testing Guild Bulk Ban!"

        try await client.bulkBanUsersFromGuild(
            guildId: Constants.guildId,
            reason: reason,
            payload: .init(
                user_ids: [userId],
                delete_message_seconds: 60
            )
        ).guardSuccess()

        let ban = try await client.getGuildBan(
            guildId: Constants.guildId,
            userId: userId
        ).decode()

        XCTAssertEqual(ban.reason, reason)
        XCTAssertEqual(ban.user.id, userId)

        try await client.unbanUserFromGuild(
            guildId: Constants.guildId,
            userId: userId
        ).guardSuccess()
    }

    func testGuildRoles() async throws {
        /// Create new role
        let rolePayload = Payloads.GuildRole(
            name: "test_role",
            permissions: [.addReactions, .attachFiles, .banMembers, .changeNickname],
            color: .init(red: 100, green: 100, blue: 100)!,
            hoist: true,
            unicode_emoji: nil,  // Needs a boosted server
            mentionable: true
        )
        let role = try await client.createGuildRole(
            guildId: Constants.guildId,
            reason: "Testing Role Create!",
            payload: rolePayload
        ).decode()

        let positionRoles = try await client.updateGuildRolePositions(
            guildId: Constants.guildId,
            reason: "Testing Role Positions Update!",
            payload: [.init(id: role.id, position: Bool.random() ? 3 : 4)]
        ).decode()

        XCTAssertTrue(
            positionRoles.map(\.id).contains(role.id),
            "\(positionRoles) did not contain \(role)"
        )

        XCTAssertEqual(role.name, rolePayload.name)
        XCTAssertEqual(role.permissions.rawValue, rolePayload.permissions!.rawValue)
        XCTAssertEqual(role.color.value, rolePayload.color!.value)
        XCTAssertEqual(role.hoist, rolePayload.hoist)
        XCTAssertEqual(role.unicode_emoji, rolePayload.unicode_emoji)
        XCTAssertEqual(role.mentionable, rolePayload.mentionable)

        /// Get guild roles
        let guildRoles = try await client.listGuildRoles(id: Constants.guildId).decode()
        let rolesWithName = guildRoles.filter({ $0.name == role.name })
        XCTAssertGreaterThanOrEqual(rolesWithName.count, 1)

        /// Add role to member
        try await client.addGuildMemberRole(
            guildId: Constants.guildId,
            userId: Constants.personalId,
            roleId: role.id
        ).guardSuccess()

        try await client.deleteGuildMemberRole(
            guildId: Constants.guildId,
            userId: Constants.personalId,
            roleId: role.id
        ).guardSuccess()

        let updatedRole = try await client.updateGuildRole(
            guildId: Constants.guildId,
            roleId: role.id,
            reason: "Testing Role Update!",
            payload: .init(name: "test_role_new")
        ).decode()

        XCTAssertEqual(updatedRole.id, role.id)

        /// Delete role
        let reason = "Random reason " + UUID().uuidString
        try await client.deleteGuildRole(
            guildId: Constants.guildId,
            roleId: role.id,
            reason: reason
        ).guardSuccess()

        /// Get guild audit logs with action type,
        /// since it'll return some info after these role manipulations.
        let auditLogsWithActionType = try await client.listGuildAuditLogEntries(
            guildId: Constants.guildId,
            action_type: .roleDelete
        ).decode()

        let entries = auditLogsWithActionType.audit_log_entries
        XCTAssertTrue(entries.contains(where: { $0.reason == reason }), "Entries: \(entries)")
    }

    func testGuildEmojis() async throws {
        /// Cleanup in the test failed last time
        let leftOverEmojis =
            try await client
            .listGuildEmojis(guildId: Constants.guildId)
            .decode()
            .filter({ $0.name?.hasPrefix("testemoji") == true })
        for emoji in leftOverEmojis {
            let id = try XCTUnwrap(emoji.id)
            try await client.deleteGuildEmoji(
                guildId: Constants.guildId,
                emojiId: id,
                reason: "Cleanup"
            ).guardSuccess()
        }

        /// Create Emoji
        let image = ByteBuffer(data: resource(name: "1kb.png"))
        let emoji = try await client.createGuildEmoji(
            guildId: Constants.guildId,
            reason: "Creating Emoji Test!",
            payload: .init(
                name: "testemoji",
                image: .init(file: .init(data: image, filename: "1kb_emoji.png")),
                roles: []
            )
        ).decode()

        let emojiId = try XCTUnwrap(emoji.id)

        /// Get Guild Emojis
        let emojis =
            try await client
            .listGuildEmojis(guildId: Constants.guildId)
            .decode()
        XCTAssertEqual(emojis.count, 2)

        let firstEmoji = try XCTUnwrap(emojis.last)
        XCTAssertEqual(firstEmoji.id, emojiId)

        /// Update Emoji
        let newName = "testemojinew"
        let updateEmoji = try await client.updateGuildEmoji(
            guildId: Constants.guildId,
            emojiId: emojiId,
            reason: "Updating Emoji Test!",
            payload: .init(name: newName, roles: [])
        ).decode()

        XCTAssertEqual(updateEmoji.id, emojiId)
        XCTAssertEqual(updateEmoji.name, newName)

        /// Get One Guild Emoji
        let getEmoji = try await client.getGuildEmoji(
            guildId: Constants.guildId,
            emojiId: emojiId
        ).decode()

        XCTAssertEqual(getEmoji.id, emojiId)
        XCTAssertEqual(getEmoji.name, newName)

        /// Delete Emoji
        try await client.deleteGuildEmoji(
            guildId: Constants.guildId,
            emojiId: emojiId,
            reason: "Deleting Emoji Test!"
        ).guardSuccess()
    }

    func testGuildWidget() async throws {
        let updatedWidget1 = try await client.updateGuildWidgetSettings(
            guildId: Constants.guildId,
            reason: "Update Widget Test!",
            payload: .init(
                enabled: true,
                channel_id: Constants.Channels.general.id
            )
        ).decode()

        XCTAssertEqual(updatedWidget1.enabled, true)
        XCTAssertEqual(updatedWidget1.channel_id, Constants.Channels.general.id)

        let widgetSettings =
            try await client
            .getGuildWidgetSettings(guildId: Constants.guildId)
            .decode()

        XCTAssertEqual(widgetSettings.enabled, true)
        XCTAssertEqual(widgetSettings.channel_id, Constants.Channels.general.id)

        let widget =
            try await client
            .getGuildWidget(guildId: Constants.guildId)
            .decode()

        XCTAssertEqual(widget.id, Constants.guildId)

        let widgetPng1 =
            try await client
            .getGuildWidgetPng(guildId: Constants.guildId)
            .getFile()

        XCTAssertGreaterThan(widgetPng1.data.readableBytes, 100)

        let widgetPng2 =
            try await client
            .getGuildWidgetPng(guildId: Constants.guildId, style: .banner4)
            .getFile()

        XCTAssertGreaterThan(widgetPng2.data.readableBytes, 100)

        let updatedWidget2 = try await client.updateGuildWidgetSettings(
            guildId: Constants.guildId,
            reason: "Update Widget Test!",
            payload: .init(
                enabled: false,
                channel_id: Constants.Channels.spam.id
            )
        ).decode()

        XCTAssertEqual(updatedWidget2.enabled, false)
        XCTAssertEqual(updatedWidget2.channel_id, Constants.Channels.spam.id)
    }

    func testGuildWelcomeScreen() async throws {
        let description = "Welcome my future friends!"
        let updateWelcomeScreen1 = try await client.updateGuildWelcomeScreen(
            guildId: Constants.guildId,
            reason: "Testing Updating Welcome Screen 1!",
            payload: .init(
                enabled: true,
                welcome_channels: [
                    .init(
                        channel_id: Constants.Channels.general.id,
                        description: "Welcome to the welcome channel!"
                    )
                ],
                description: description
            )
        ).decode()

        XCTAssertEqual(updateWelcomeScreen1.description, description)

        let welcomeScreen1 = try await client.getGuildWelcomeScreen(
            guildId: Constants.guildId,
            reason: "Testing Getting Welcome Screen!"
        ).decode()

        XCTAssertEqual(welcomeScreen1.description, description)

        let updateWelcomeScreen2 = try await client.updateGuildWelcomeScreen(
            guildId: Constants.guildId,
            reason: "Testing Updating Welcome Screen 2!",
            payload: .init(enabled: false)
        ).decode()

        XCTAssertEqual(updateWelcomeScreen2.description, description)

        let welcomeScreen2 = try await client.getGuildWelcomeScreen(
            guildId: Constants.guildId,
            reason: "Testing Getting Welcome Screen!"
        ).decode()

        XCTAssertEqual(welcomeScreen2.description, description)
    }

    func testGuildIntegrations() async throws {
        let integrations =
            try await client
            .listGuildIntegrations(guildId: Constants.guildId)
            .decode()

        XCTAssertGreaterThan(integrations.count, 0)

        XCTAssertTrue(
            integrations.map(\.application?.id).contains(Snowflake(Constants.botId)),
            "\(integrations) did not contain \(Constants.botId)"
        )

        /// Can't delete any integrations because can't automatically add one.
        let integrationDeleteError = try await client.deleteGuildIntegration(
            guildId: Constants.guildId,
            integrationId: .makeFake(),
            reason: "Won't even work!"
        ).asError()

        switch integrationDeleteError {
        case let .jsonError(jsonError) where jsonError.code == .unknownIntegration:
            break
        case .none, .badStatusCode, .jsonError:
            XCTFail("Unexpected error: \(String(describing: integrationDeleteError))")
        }
    }

    func testGuildScheduledEvents() async throws {
        let image = ByteBuffer(data: resource(name: "discordbm-logo.png"))
        let created1 = try await client.createGuildScheduledEvent(
            guildId: Constants.guildId,
            reason: "Test Creating Scheduled Events!",
            payload: .init(
                channel_id: nil,
                entity_metadata: .init(location: "https://mahdibm.com"),
                name: "Test Scheduled Events!",
                privacy_level: .guildOnly,
                scheduled_start_time: .init(date: Date().addingTimeInterval(300)),
                scheduled_end_time: .init(date: Date().addingTimeInterval(600)),
                description: "Testing Scheduled Events!",
                entity_type: .external,
                image: .init(file: .init(data: image, filename: "discordbm.png"))
            )
        ).decode()

        let created2 = try await client.createGuildScheduledEvent(
            guildId: Constants.guildId,
            reason: "Test Creating Scheduled Events!",
            payload: .init(
                channel_id: Constants.Channels.voice.id,
                entity_metadata: nil,
                name: "Test Scheduled Events!",
                privacy_level: .guildOnly,
                scheduled_start_time: .init(date: Date().addingTimeInterval(300)),
                scheduled_end_time: .init(date: Date().addingTimeInterval(600)),
                description: "Testing Scheduled Events!",
                entity_type: .voice,
                image: .init(file: .init(data: image, filename: "discordbm.png"))
            )
        ).decode()

        let created3 = try await client.createGuildScheduledEvent(
            guildId: Constants.guildId,
            reason: "Test Creating Scheduled Events!",
            payload: .init(
                channel_id: Constants.Channels.stage.id,
                entity_metadata: nil,
                name: "Test Scheduled Events!",
                privacy_level: .guildOnly,
                scheduled_start_time: .init(date: Date().addingTimeInterval(300)),
                scheduled_end_time: .init(date: Date().addingTimeInterval(600)),
                description: "Testing Scheduled Events!",
                entity_type: .stageInstance,
                image: .init(file: .init(data: image, filename: "discordbm.png"))
            )
        ).decode()

        let imageHash = try XCTUnwrap(created1.image)

        /// Test this CDN endpoint here since we have a valid scheduled event on our hands.
        let eventCover = try await client.getCDNGuildScheduledEventCover(
            eventId: created1.id,
            cover: imageHash
        ).getFile()

        XCTAssertGreaterThan(eventCover.data.readableBytes, 100)

        let eventsWithCount = try await client.listGuildScheduledEvents(
            guildId: Constants.guildId,
            withUserCount: true
        ).decode()

        XCTAssertTrue(eventsWithCount.allSatisfy({ $0.user_count != nil }), "\(eventsWithCount)")

        let eventsNoCount = try await client.listGuildScheduledEvents(
            guildId: Constants.guildId,
            withUserCount: false
        ).decode()

        XCTAssertTrue(eventsNoCount.allSatisfy({ $0.user_count == nil }), "\(eventsNoCount)")

        let gotEvent1 = try await client.getGuildScheduledEvent(
            guildId: Constants.guildId,
            guildScheduledEventId: created1.id,
            withUserCount: true
        ).decode()

        XCTAssertEqual(gotEvent1.id, created1.id)

        let gotEvent2 = try await client.getGuildScheduledEvent(
            guildId: Constants.guildId,
            guildScheduledEventId: created2.id,
            withUserCount: false
        ).decode()

        XCTAssertEqual(gotEvent2.id, created2.id)

        /// Can't assert too much for the `listGuildScheduledEventUsers`
        /// endpoint since there will be no users in the list.

        let users3 = try await client.listGuildScheduledEventUsers(
            guildId: Constants.guildId,
            guildScheduledEventId: created3.id
        ).decode()

        _ = try await client.listGuildScheduledEventUsers(
            guildId: Constants.guildId,
            guildScheduledEventId: created3.id,
            limit: 1,
            before: users3.first?.user.id
        ).decode()

        let users2 = try await client.listGuildScheduledEventUsers(
            guildId: Constants.guildId,
            guildScheduledEventId: created2.id,
            withMember: true
        ).decode()

        _ = try await client.listGuildScheduledEventUsers(
            guildId: Constants.guildId,
            guildScheduledEventId: created1.id,
            limit: 10,
            after: users2.first?.user.id
        ).decode()

        for created in [created1, created2, created3] {
            try await client.deleteGuildScheduledEvent(
                guildId: Constants.guildId,
                guildScheduledEventId: created.id
            ).guardSuccess()
        }
    }

    func testGuildTemplates() async throws {
        /// Cleanup
        if let template =
            try await client
            .listGuildTemplates(guildId: Constants.guildId)
            .decode().first
        {
            try await client.deleteGuildTemplate(
                guildId: Constants.guildId,
                code: template.code
            ).guardSuccess()
        }

        let created = try await client.createGuildTemplate(
            guildId: Constants.guildId,
            payload: .init(
                name: "Testing Templates!",
                description: "Testing Guild Templates!"
            )
        ).decode()

        let gotTemplate =
            try await client
            .getGuildTemplate(code: created.code)
            .decode()

        XCTAssertEqual(gotTemplate.code, created.code)

        let allTemplates =
            try await client
            .listGuildTemplates(guildId: Constants.guildId)
            .decode()

        XCTAssertGreaterThan(allTemplates.count, 0)

        let updated = try await client.updateGuildTemplate(
            guildId: Constants.guildId,
            code: created.code,
            payload: .init(
                name: "New Testing Templates!",
                description: "New Testing Guild Templates!"
            )
        ).decode()

        XCTAssertEqual(updated.code, created.code)

        let synced = try await client.syncGuildTemplate(
            guildId: Constants.guildId,
            code: created.code
        ).decode()

        XCTAssertEqual(synced.code, created.code)

        let image = ByteBuffer(data: resource(name: "1kb.png"))
        let guildName = "Guild From Template Test!"
        let guild = try await client.createGuildFromTemplate(
            code: created.code,
            payload: .init(
                name: guildName,
                icon: .init(file: .init(data: image, filename: "1kb.png"))
            )
        ).decode()

        XCTAssertEqual(guild.name, guildName)
        XCTAssertFalse(guild.roles.isEmpty)

        try await client.deleteGuild(id: guild.id).guardSuccess()

        try await client.deleteGuildTemplate(
            guildId: Constants.guildId,
            code: created.code
        ).guardSuccess()
    }

    func testGuildOthers() async throws {
        let preview =
            try await client
            .getGuildPreview(guildId: Constants.guildId)
            .decode()

        XCTAssertEqual(preview.id, Constants.guildId)
        XCTAssertEqual(preview.name, Constants.guildName)

        /// Get guild audit logs
        let auditLogs = try await client.listGuildAuditLogEntries(
            guildId: Constants.guildId
        ).decode()
        XCTAssertEqual(auditLogs.audit_log_entries.count, 50, "\(auditLogs.audit_log_entries)")

        _ = try await client.listGuildVoiceRegions(guildId: Constants.guildId).decode()

        let vanityError =
            try await client
            .getGuildVanityUrl(guildId: Constants.guildId)
            .asError()

        switch vanityError {
        /// `missingAccess` is not accurate.
        /// The actual problem is that the server doesn't have a vanity url (requires boosts)
        case let .jsonError(jsonError) where jsonError.code == .missingAccess:
            break
        case .none, .badStatusCode, .jsonError:
            XCTFail("Unexpected error: \(String(describing: vanityError))")
        }

        let onboarding =
            try await client
            .getGuildOnboarding(guildId: Constants.guildId)
            .decode()

        XCTAssertEqual(onboarding.guild_id, Constants.guildId)

        let firstPrompt = try XCTUnwrap(onboarding.prompts.first)
        let firstPromptOption = try XCTUnwrap(firstPrompt.options.first)

        let updatedOnboardingError = try await client.updateGuildOnboarding(
            guildId: Constants.guildId,
            reason: "Guild Onboarding Test Update Reason.",
            payload: .init(
                prompts: [
                    .init(
                        id: firstPrompt.id,
                        type: firstPrompt.type,
                        options: [
                            .init(
                                id: firstPromptOption.id,
                                channel_ids: firstPromptOption.channel_ids,
                                role_ids: firstPromptOption.role_ids,
                                emoji: firstPromptOption.emoji,
                                title: "Test title \(UUID().uuidString)",
                                description: "Test desc \(UUID().uuidString)"
                            )
                        ],
                        title: "Test onboarding title \(UUID().uuidString)",
                        single_select: false,
                        required: false,
                        in_onboarding: false
                    )
                ],
                default_channel_ids: [Constants.Channels.moderation.id],
                enabled: nil,
                mode: .onboardingAdvanced
            )
        ).decodeJSONError()

        switch updatedOnboardingError.code {
        // FIXME: should throw 'cannotUpdateOnboardingWhileBelowRequirements' instead
        case .invalidFormBodyOrInvalidContentType: break
        default:
            XCTFail("Unexpected error: \(updatedOnboardingError)")
        }
    }

    func testStageInstance() async throws {
        let createdInstance = try await client.createStageInstance(
            reason: "Test Creating Stage Instances!",
            payload: .init(
                channel_id: Constants.Channels.stage.id,
                topic: "Stage Instance Test Topic!",
                privacy_level: .guildOnly,
                send_start_notification: true
            )
        ).decode()

        XCTAssertEqual(createdInstance.channel_id, Constants.Channels.stage.id)

        let gotInstance =
            try await client
            .getStageInstance(channelId: Constants.Channels.stage.id)
            .decode()

        XCTAssertEqual(gotInstance.channel_id, createdInstance.channel_id)

        let newTopic = "New Stage Instance Test Topic!"
        let newPrivacyLevel = StageInstance.PrivacyLevel.public
        let updatedInstance = try await client.updateStageInstance(
            channelId: Constants.Channels.stage.id,
            reason: "Test Updating Stage Instances!",
            payload: .init(topic: newTopic, privacy_level: newPrivacyLevel)
        ).decode()

        XCTAssertEqual(updatedInstance.channel_id, Constants.Channels.stage.id)
        XCTAssertEqual(updatedInstance.topic, newTopic)
        XCTAssertEqual(updatedInstance.privacy_level, newPrivacyLevel)

        try await client.deleteStageInstance(
            channelId: Constants.Channels.stage.id,
            reason: "Test Deleting Stage Instances!"
        ).guardSuccess()
    }

    func testStickers() async throws {
        let image = ByteBuffer(data: resource(name: "discordbm-logo.png"))

        let createdSticker = try await client.createGuildSticker(
            guildId: Constants.guildId,
            reason: "Test Creating Stickers!",
            payload: .init(
                name: "DiscordBM",
                description: "DiscordBM sticker test!",
                tags: "DiscordBM",
                file: .init(data: image, filename: "DiscordBM.png")
            )
        ).decode()

        /// Recently gives this error:
        /// <?xml version='1.0' encoding='UTF-8'?><Error><Code>AccessDenied</Code><Message>Access denied.</Message><Details>Anonymous caller does not have storage.objects.get access to the Google Cloud Storage object. Permission 'storage.objects.get' denied on resource (or it may not exist).</Details></Error>

        //        /// Testing CDN sticker endpoint while we can
        //        let stickerFile = try await client.getCDNSticker(
        //            stickerId: createdSticker.id
        //        ).getFile()
        //        XCTAssertGreaterThan(file.data.readableBytes, 100)

        let gotSticker1 =
            try await client
            .getSticker(id: createdSticker.id)
            .decode()

        XCTAssertEqual(gotSticker1.id, createdSticker.id)

        let newName = "1kilograms!"
        let updatedSticker = try await client.updateGuildSticker(
            guildId: Constants.guildId,
            stickerId: createdSticker.id,
            reason: "Test Updating Stickers!",
            payload: .init(name: newName)
        ).decode()

        XCTAssertEqual(updatedSticker.id, createdSticker.id)
        XCTAssertEqual(updatedSticker.name, newName)

        let gotSticker2 = try await client.getGuildSticker(
            guildId: Constants.guildId,
            stickerId: createdSticker.id
        ).decode()

        XCTAssertEqual(gotSticker2.id, createdSticker.id)
        XCTAssertEqual(gotSticker2.name, newName)

        let allStickers =
            try await client
            .listGuildStickers(guildId: Constants.guildId)
            .decode()

        XCTAssertGreaterThan(allStickers.count, 0)
        XCTAssertTrue(
            allStickers.map(\.id).contains(createdSticker.id),
            "\(allStickers) did not contain \(createdSticker.id)"
        )

        try await client.deleteGuildSticker(
            guildId: Constants.guildId,
            stickerId: createdSticker.id,
            reason: "Test Deleting Stickers!"
        ).guardSuccess()

        let packs = try await client.listStickerPacks().decode()
        XCTAssertGreaterThan(packs.sticker_packs.count, 0)

        let firstPack = try XCTUnwrap(
            packs.sticker_packs.first(
                where: { $0.banner_asset_id != nil }
            )
        )

        let packBanner =
            try await client
            .getCDNStickerPackBanner(assetId: firstPack.banner_asset_id!)
            .getFile()

        XCTAssertGreaterThan(packBanner.data.readableBytes, 100)
    }

    func testVoice() async throws {
        let regions = try await client.listVoiceRegions().decode()

        XCTAssertGreaterThan(regions.count, 0)

        let guildRegions =
            try await client
            .listGuildVoiceRegions(guildId: Constants.guildId)
            .decode()

        XCTAssertGreaterThan(guildRegions.count, 0)

        /// Can't set this because we can't join a voice/stage channel first.
        let selfVoiceStateError = try await client.updateSelfVoiceState(
            guildId: Constants.guildId,
            payload: .init(
                channel_id: Constants.Channels.stage.id,
                suppress: false,
                request_to_speak_timestamp: DiscordTimestamp(date: Date().addingTimeInterval(5))
            )
        ).asError()

        switch selfVoiceStateError {
        case .jsonError(let jsonError) where jsonError.code == .unknownVoiceState:
            break
        case .none, .badStatusCode, .jsonError:
            XCTFail("Unexpected error: \(String(describing: selfVoiceStateError))")
        }

        /// Can't set this because we can't join a voice/stage channel first.
        let voiceStateError = try await client.updateVoiceState(
            guildId: Constants.guildId,
            userId: Constants.secondAccountId,
            payload: .init(
                channel_id: Constants.Channels.stage.id,
                suppress: true
            )
        ).asError()

        switch voiceStateError {
        case .jsonError(let jsonError) where jsonError.code == .unknownVoiceState:
            break
        case .none, .badStatusCode, .jsonError:
            XCTFail("Unexpected error: \(String(describing: voiceStateError))")
        }
    }

    func testUser() async throws {
        let selfUser = try await client.getOwnUser().decode()

        XCTAssertEqual(selfUser.id, Constants.botId)

        let selfApplication = try await client.getOwnApplication().decode()

        XCTAssertEqual(selfApplication.id.rawValue, Constants.botId.rawValue)

        let image = ByteBuffer(data: resource(name: "1kb.png"))
        let imageData = Payloads.ImageData(
            file: .init(
                data: image,
                filename: "test_image.png"
            )
        )
        func fakeURL() -> String {
            "https://fake.com/\(Int.random(in: .min ... .max))"
        }
        let updatedApplication = try await client.updateOwnApplication(
            payload: .init(
                custom_install_url: fakeURL(),
                description: "TEST DESCRIPTION \(UInt.random(in: .min ... .max))",
                role_connections_verification_url: fakeURL(),
                install_params: nil,
                flags: [
                    .gatewayPresenceLimited,
                    .gatewayGuildMembersLimited,
                    .gatewayMessageContentLimited,
                ],
                icon: imageData,
                cover_image: imageData,
                interactions_endpoint_url: nil,
                tags: (0..<5).map { _ in "\(Int.random(in: .min ... .max))" }
            )
        ).decode()

        XCTAssertEqual(updatedApplication.id.rawValue, Constants.botId.rawValue)

        let user = try await client.getUser(id: Constants.secondAccountId).decode()

        XCTAssertEqual(user.id, Constants.secondAccountId)

        do {
            let image = ByteBuffer(data: resource(name: "1kb.png"))
            let updatedUser = try await client.updateOwnUser(
                payload: .init(
                    username: "DisBMTestLib\(Int.random(in: 0..<100))",
                    avatar: .init(file: .init(data: image, filename: "1kb.png"))
                )
            ).decode()

            XCTAssertEqual(updatedUser.id, Constants.botId)
        } catch let error as DiscordHTTPError {
            if case let .badStatusCode(response) = error,
                response.description.contains(#""code": "USERNAME_RATE_LIMIT""#)
            {
                /// Do nothing, this error is acceptable.
            } else {
                throw error
            }
        }

        let guilds = try await client.listOwnGuilds().decode()

        XCTAssertGreaterThan(guilds.count, 1, "\(guilds)")

        let guildsWithBefore = try await client.listOwnGuilds(
            before: guilds.first?.guild_id,
            limit: 10
        ).decode()

        XCTAssertGreaterThan(guildsWithBefore.count, 1, "\(guildsWithBefore)")
        XCTAssertNil(guildsWithBefore.first?.approximate_member_count)

        let guildsWithAfterAndCounts = try await client.listOwnGuilds(
            after: guilds.first?.guild_id,
            limit: 10,
            withCounts: true
        ).decode()

        XCTAssertGreaterThan(guildsWithAfterAndCounts.count, 1, "\(guildsWithAfterAndCounts)")
        XCTAssertNotNil(guildsWithAfterAndCounts.first?.approximate_member_count)
    }

    func testConnections() async throws {
        _ = try await client.listOwnConnections().decode()
    }

    func testDMs() async throws {
        /// Create DM
        let dmChannel = try await client.createDm(
            payload: .init(recipient_id: Constants.personalId)
        ).decode()

        XCTAssertEqual(dmChannel.type, .dm)
        let recipient = try XCTUnwrap(dmChannel.recipients?.first)
        XCTAssertEqual(recipient.id, Constants.personalId)

        /// Send a message to the DM channel
        let text = "Testing! \(Date())"
        let message = try await client.createMessage(
            channelId: dmChannel.id,
            payload: .init(content: text)
        ).decode()

        XCTAssertEqual(message.content, text)
        XCTAssertEqual(message.channel_id, dmChannel.id)

        /// These group-dm endpoints require access tokens. Can't test easily.
        let createGroupDmError = try await client.createGroupDm(
            payload: .init(access_tokens: [], nicks: [:])
        ).asError()

        switch createGroupDmError {
        case let .jsonError(jsonError) where jsonError.code == .invalidFormBodyOrInvalidContentType:
            break
        default:
            XCTFail("Unexpected error: \(String(describing: createGroupDmError))")
        }

        let addGroupDmUserError = try await client.addGroupDmUser(
            channelId: dmChannel.id,
            userId: Constants.personalId,
            payload: .init(access_token: "", nick: "")
        ).asError()

        switch addGroupDmUserError {
        case let .jsonError(jsonError)
        where jsonError.code == .cannotExecuteActionOnThisChannelType:
            break
        default:
            XCTFail("Unexpected error: \(String(describing: createGroupDmError))")
        }

        let deleteGroupDmUserError = try await client.deleteGroupDmUser(
            channelId: dmChannel.id,
            userId: Constants.personalId
        ).asError()

        switch deleteGroupDmUserError {
        case let .jsonError(jsonError) where jsonError.code == .missingPermissions:
            break
        default:
            XCTFail("Unexpected error: \(String(describing: createGroupDmError))")
        }
    }

    func testThreads() async throws {

        /// Create a message for creating a thread
        let message = try await client.createMessage(
            channelId: Constants.Channels.threads.id,
            payload: .init(content: "Thread-test Message")
        ).decode()

        /// Create Thread
        let thread = try await client.createThreadFromMessage(
            channelId: Constants.Channels.threads.id,
            messageId: message.id,
            reason: "Testing!",
            payload: .init(
                name: "Creating a Thread to Test!",
                auto_archive_duration: .threeDays,
                rate_limit_per_user: 2
            )
        ).decode()

        let updatedThreadName = "Creating a Thread to Test! Updated Name"
        let updateThread = try await client.updateThreadChannel(
            id: thread.id,
            payload: .init(name: updatedThreadName)
        ).decode()

        XCTAssertEqual(updateThread.id, thread.id)
        XCTAssertEqual(updateThread.name, updatedThreadName)

        do {
            let text = "Testing! \(Date())"
            let message = try await client.createMessage(
                channelId: thread.id,
                payload: .init(content: text)
            ).decode()

            XCTAssertEqual(message.content, text)
            XCTAssertEqual(message.channel_id, thread.id)

            /// Edit
            let newText = "Edit Testing! \(Date())"
            let edited = try await client.updateMessage(
                channelId: thread.id,
                messageId: message.id,
                payload: .init(embeds: [
                    .init(description: newText)
                ])
            ).decode()

            XCTAssertEqual(edited.content, text)
            XCTAssertEqual(edited.embeds.first?.description, newText)
            XCTAssertEqual(edited.channel_id, thread.id)

            /// Delete
            try await client.deleteMessage(
                channelId: thread.id,
                messageId: message.id,
                reason: "Random reason " + UUID().uuidString
            ).guardSuccess()
        }

        try await client.addThreadMember(
            threadId: thread.id,
            userId: Constants.personalId
        ).guardSuccess()

        let threadMember = try await client.getThreadMember(
            threadId: thread.id,
            userId: Constants.personalId
        ).decode()

        XCTAssertEqual(threadMember.user_id, Constants.personalId)

        let threadMemberWithMember = try await client.getThreadMemberWithMember(
            threadId: thread.id,
            userId: Constants.personalId
        ).decode()

        XCTAssertEqual(threadMemberWithMember.user_id, Constants.personalId)
        XCTAssertNotNil(threadMemberWithMember.member.user?.id, Constants.personalId.rawValue)

        let allThreadMembers = try await client.listThreadMembers(threadId: thread.id).decode()

        guard allThreadMembers.count == 2 else {
            XCTFail("Expected 2 thread member but got \(allThreadMembers.count)")
            return
        }

        /// Test `listActiveGuildThreads` endpoint here since we know have active threads.
        let activeThreads =
            try await client
            .listActiveGuildThreads(guildId: Constants.guildId)
            .decode()

        XCTAssertFalse(activeThreads.threads.isEmpty)
        XCTAssertFalse(activeThreads.members.isEmpty)

        let allThreadMembersAfter = try await client.listThreadMembersWithMember(
            threadId: thread.id,
            after: allThreadMembers[0].user_id!
        ).decode()

        XCTAssertEqual(allThreadMembersAfter.count, 1)
        let otherUser = [Constants.personalId, Constants.botId].filter {
            $0 != allThreadMembers[0].user_id!
        }
        XCTAssertEqual(allThreadMembersAfter.first?.user_id, otherUser[0])

        let limitedThreadMembers = try await client.listThreadMembersWithMember(
            threadId: thread.id,
            limit: 1
        ).decode()

        XCTAssertEqual(limitedThreadMembers.count, 1)

        try await client.leaveThread(id: thread.id)
            .guardSuccess()

        let threadMembersLeft = try await client.listThreadMembers(threadId: thread.id).decode()

        XCTAssertEqual(threadMembersLeft.first?.user_id, Constants.personalId)

        try await client.joinThread(id: thread.id)
            .guardSuccess()

        let threadMembersRejoined = try await client.listThreadMembers(threadId: thread.id).decode()

        XCTAssertEqual(threadMembersRejoined.count, 2)

        try await client.deleteThreadMember(
            threadId: thread.id,
            userId: Constants.personalId
        ).guardSuccess()

        let threadMembersRemoved = try await client.listThreadMembers(threadId: thread.id).decode()

        XCTAssertEqual(threadMembersRemoved.first?.user_id, Constants.botId)

        try await client.deleteMessage(
            channelId: Constants.Channels.threads.id,
            messageId: message.id
        ).guardSuccess()

        let threadWithoutMessage = try await client.createThread(
            channelId: Constants.Channels.announcements.id,
            reason: "Testing without message thread",
            payload: .init(
                name: "Thread test without message",
                auto_archive_duration: .oneHour,
                type: .announcementThread,
                invitable: true,
                rate_limit_per_user: 900
            )
        ).decode()

        _ = try await client.listPublicArchivedThreads(
            channelId: Constants.Channels.announcements.id,
            before: Date(),
            limit: 2
        ).decode()

        /// The message-id is the same as the thread id based on what Discord says
        try await client.deleteMessage(
            channelId: Constants.Channels.announcements.id,
            messageId: Snowflake(threadWithoutMessage.id)
        ).guardSuccess()

        let forumThreadName = "Forum thread test"
        let content = "Hello!"
        let forumThread = try await client.startThreadInForumOrMediaChannel(
            channelId: Constants.Channels.forum.id,
            reason: "Forum channel thread testing",
            payload: .init(
                name: forumThreadName,
                auto_archive_duration: .oneDay,
                rate_limit_per_user: nil,
                message: .init(content: content),
                applied_tags: nil
            )
        ).decode()

        XCTAssertEqual(forumThread.channel.name, forumThreadName)
        XCTAssertEqual(forumThread.message.content, content)

        try await client.listPublicArchivedThreads(
            channelId: Constants.Channels.threads.id,
            before: Date().addingTimeInterval(-60),
            limit: 2
        ).guardSuccess()

        try await client.listPrivateArchivedThreads(
            channelId: Constants.Channels.threads.id,
            before: Date().addingTimeInterval(-3_600),
            limit: 2
        ).guardSuccess()

        try await client.listOwnPrivateArchivedThreads(
            channelId: Constants.Channels.threads.id,
            limit: 2
        ).guardSuccess()
    }

    func testWebhooks() async throws {

        /// Cleanup before starting the actual tests
        do {
            let guildWebhooks = try await client.getGuildWebhooks(
                guildId: Constants.guildId
            ).decode()

            for webhook in guildWebhooks {
                try await client.deleteWebhook(id: webhook.id)
                    .guardSuccess()
            }
        }

        let image1 = ByteBuffer(data: resource(name: "discordbm-logo.png"))
        let image2 = ByteBuffer(data: resource(name: "1kb.png"))

        let webhookName1 = "TestWebhook1"

        let webhook1 = try await client.createWebhook(
            channelId: Constants.Channels.webhooks.id,
            payload: .init(
                name: webhookName1,
                avatar: .init(file: .init(data: image1, filename: "DiscordBM.png"))
            )
        ).decode()

        XCTAssertTrue(webhook1.token?.isEmpty == false)
        XCTAssertTrue(webhook1.id.rawValue.isEmpty == false)
        XCTAssertTrue(webhook1.avatar?.isEmpty == false)
        XCTAssertEqual(webhook1.name, webhookName1)
        XCTAssertEqual(webhook1.guild_id, Constants.guildId)
        XCTAssertEqual(webhook1.channel_id, Constants.Channels.webhooks.id)

        let webhookName2 = "TestWebhook2"

        let webhook2 = try await client.createWebhook(
            channelId: Constants.Channels.webhooks.id,
            payload: .init(name: webhookName2)
        ).decode()

        XCTAssertTrue(webhook2.token?.isEmpty == false)
        XCTAssertTrue(webhook2.id.rawValue.isEmpty == false)
        XCTAssertNil(webhook2.avatar)
        XCTAssertEqual(webhook2.name, webhookName2)
        XCTAssertEqual(webhook2.guild_id, Constants.guildId)
        XCTAssertEqual(webhook2.channel_id, Constants.Channels.webhooks.id)

        let webhook1Token = try XCTUnwrap(webhook1.token)
        let webhook2Token = try XCTUnwrap(webhook2.token)

        let getWebhook = try await client.getWebhook(id: webhook1.id).decode()
        XCTAssertEqual(getWebhook.id, webhook1.id)
        XCTAssertEqual(getWebhook.token, webhook1.token)

        let getWebhookByToken = try await client.getWebhook(
            address: .deconstructed(id: webhook2.id, token: webhook2Token)
        ).decode()
        XCTAssertEqual(getWebhookByToken.id, webhook2.id)
        XCTAssertEqual(getWebhookByToken.token, webhook2.token)

        let channelWebhooks = try await client.listChannelWebhooks(
            channelId: Constants.Channels.webhooks.id
        ).decode()

        XCTAssertEqual(channelWebhooks.count, 2)

        let channelWebhook1 = try XCTUnwrap(channelWebhooks.first)

        XCTAssertEqual(channelWebhook1.token, webhook1.token)
        XCTAssertEqual(channelWebhook1.id, webhook1.id)

        let channelWebhook2 = try XCTUnwrap(channelWebhooks.last)

        XCTAssertEqual(channelWebhook2.token, webhook2.token)
        XCTAssertEqual(channelWebhook2.id, webhook2.id)

        let guildWebhooks = try await client.getGuildWebhooks(
            guildId: Constants.guildId
        ).decode()

        XCTAssertEqual(guildWebhooks.count, 2)

        let guildWebhook1 = try XCTUnwrap(guildWebhooks.first)

        XCTAssertEqual(guildWebhook1.token, webhook1.token)
        XCTAssertEqual(guildWebhook1.id, webhook1.id)

        let guildWebhook2 = try XCTUnwrap(guildWebhooks.last)

        XCTAssertEqual(guildWebhook2.token, webhook2.token)
        XCTAssertEqual(guildWebhook2.id, webhook2.id)

        let webhookNewName1 = "WebhookTestNew1"
        let modify1 = try await client.updateWebhook(
            id: webhook1.id,
            payload: .init(
                name: webhookNewName1,
                avatar: .init(file: .init(data: image2, filename: "1kb.png")),
                channel_id: Constants.Channels.webhooks2.id
            )
        ).decode()

        XCTAssertEqual(modify1.token, webhook1.token)
        XCTAssertEqual(modify1.id, webhook1.id)
        XCTAssertTrue(modify1.avatar?.isEmpty == false)
        XCTAssertNotEqual(modify1.avatar, webhook1.avatar)
        XCTAssertEqual(modify1.name, webhookNewName1)
        XCTAssertEqual(modify1.guild_id, Constants.guildId)
        XCTAssertEqual(modify1.channel_id, Constants.Channels.webhooks2.id)

        let webhookNewName2 = "WebhookTestNew2"
        let modify2 = try await client.updateWebhook(
            address: .deconstructed(id: webhook2.id, token: webhook2Token),
            payload: .init(name: webhookNewName2)
        ).decode()

        XCTAssertEqual(modify2.token, webhook2.token)
        XCTAssertEqual(modify2.id, webhook2.id)
        XCTAssertNil(modify2.avatar)
        XCTAssertEqual(modify2.name, webhookNewName2)
        XCTAssertEqual(modify2.guild_id, Constants.guildId)
        XCTAssertEqual(modify2.channel_id, Constants.Channels.webhooks.id)

        try await client.executeWebhook(
            address: .deconstructed(id: webhook1.id, token: webhook1Token),
            payload: .init(content: "Testing! \(Date())")
        ).guardSuccess()

        let text = "Testing! \(Date())"
        let date = Date()
        let message = try await client.executeWebhookWithResponse(
            address: .deconstructed(id: webhook1.id, token: webhook1Token),
            payload: .init(
                content: text,
                embeds: [.init(title: "Hey", timestamp: date)]
            )
        ).decode()

        XCTAssertEqual(message.channel_id, Constants.Channels.webhooks2.id)
        XCTAssertEqual(message.content, text)
        XCTAssertEqual(message.embeds.first?.title, "Hey")
        let timestamp = try XCTUnwrap(message.embeds.first?.timestamp?.date).timeIntervalSince1970
        let range = (date.timeIntervalSince1970 - 1)...(date.timeIntervalSince1970 + 1)
        XCTAssertTrue(range.contains(timestamp), "\(range) did not contain \(timestamp)")

        let text2 = "Testing! \(Date())"
        let threadId: ChannelSnowflake = "1066278441256751114"
        let threadMessage = try await client.executeWebhookWithResponse(
            address: .deconstructed(id: webhook2.id, token: webhook2Token),
            threadId: threadId,
            payload: .init(content: text2)
        ).decode()

        XCTAssertEqual(threadMessage.channel_id, threadId)
        XCTAssertEqual(threadMessage.content, text2)

        let getMessage = try await client.getWebhookMessage(
            address: .deconstructed(id: webhook1.id, token: webhook1Token),
            messageId: message.id
        ).decode()

        XCTAssertEqual(getMessage.id, message.id)
        XCTAssertEqual(getMessage.content, message.content)
        XCTAssertEqual(getMessage.embeds.map(\.title), message.embeds.map(\.title))

        let newText = "Testing Edit! \(Date())"
        let editThreadMessage = try await client.updateWebhookMessage(
            address: .deconstructed(id: webhook2.id, token: webhook2Token),
            messageId: threadMessage.id,
            threadId: threadId,
            payload: .init(content: newText)
        ).decode()

        XCTAssertEqual(editThreadMessage.content, newText)
        XCTAssertEqual(editThreadMessage.id, threadMessage.id)

        let getThreadMessage = try await client.getWebhookMessage(
            address: .deconstructed(id: webhook2.id, token: webhook2Token),
            messageId: threadMessage.id,
            threadId: threadId
        ).decode()

        XCTAssertEqual(getThreadMessage.id, threadMessage.id)
        XCTAssertEqual(getThreadMessage.content, editThreadMessage.content)

        let deleteThreadMessage = try await client.deleteWebhookMessage(
            address: .deconstructed(id: webhook2.id, token: webhook2Token),
            messageId: threadMessage.id,
            threadId: threadId
        )
        XCTAssertNoThrow(try deleteThreadMessage.guardSuccess())

        let delete1 = try await client.deleteWebhook(id: webhook1.id, reason: "Testing! 1")
        XCTAssertNoThrow(try delete1.guardSuccess())

        let delete2 = try await client.deleteWebhook(
            address: .deconstructed(id: webhook2.id, token: webhook2Token),
            reason: "Testing! 2"
        )
        XCTAssertNoThrow(try delete2.guardSuccess())
    }

    func testOAuth() async throws {
        let app = try await client.getOwnOauth2Application().decode()
        XCTAssertEqual(app.id, Snowflake(Constants.botId))
    }

    /// Can't test these properly as the test-bot doesn't have real access to these.
    func testEntitlements() async throws {
        let all = try await client.listEntitlements().decode()
        XCTAssertEqual(all.count, 0, "\(all)")

        let createError = try await client.createTestEntitlement(
            payload: .init(
                sku_id: .makeFake(),
                owner_id: Constants.botId
            )
        ).asError()

        switch createError {
        case .jsonError(let jsonError) where jsonError.code == .unknownSKU:
            break
        case .none, .badStatusCode, .jsonError:
            XCTFail("Unexpected error: \(String(describing: createError))")
        }

        let consumeError = try await client.consumeEntitlement(
            entitlementId: .makeFake()
        ).asError()

        switch consumeError {
        case .jsonError(let jsonError) where jsonError.code == .unknownEntitlement:
            break
        case .none, .badStatusCode, .jsonError:
            XCTFail("Unexpected error: \(String(describing: consumeError))")
        }

        let deleteError = try await client.deleteTestEntitlement(
            entitlementId: .makeFake()
        ).asError()

        switch deleteError {
        case .jsonError(let jsonError) where jsonError.code == .unknownEntitlement:
            break
        case .none, .badStatusCode, .jsonError:
            XCTFail("Unexpected error: \(String(describing: deleteError))")
        }

        let allSKUs = try await client.listSKUs().decode()
        XCTAssertEqual(allSKUs.count, 0, "\(allSKUs)")
    }

    func testAutoModerationRules() async throws {
        /// Cleanup
        var rules = try await client.listAutoModerationRules(
            guildId: Constants.guildId
        ).decode()

        let mentionSpamRule: AutoModerationRule
        /// Removing `.mentionSpam` from the rules variable prevents this error when the code below tries to cleanup rules:
        /// ```
        /// {
        ///   "message": "Mention Spam AutoMod rule cannot be deleted from community servers",
        ///   "code": 200006
        /// }
        /// ```
        if let idx = rules.firstIndex(where: { $0.trigger_type == .mentionSpam }) {
            mentionSpamRule = rules.remove(at: idx)
        } else {
            XCTFail(
                """
                No mention-spam AutoModerationRule found.
                You might need to disable this check for the first run.
                """
            )
            return
        }

        for rule in rules {
            guard rule.creator_id == Constants.botId else { continue }
            try await client.deleteAutoModerationRule(
                guildId: Constants.guildId,
                ruleId: rule.id,
                reason: "Testing Cleanup!"
            ).guardSuccess()
        }

        let createdRule1 = try await client.createAutoModerationRule(
            guildId: Constants.guildId,
            reason: "Testing!",
            payload: .init(
                name: "Testing 1",
                event_type: .messageSend,
                trigger_type: .keyword,
                trigger_metadata: .init(
                    keyword_filter: ["ood"],
                    regex_patterns: nil,
                    presets: [.slurs],
                    allow_list: ["good"],
                    mention_total_limit: 1,
                    mention_raid_protection_enabled: true
                ),
                actions: [.blockMessage(customMessage: "You bad boy!!!")],
                enabled: true,
                exempt_roles: [Constants.adminRoleId],
                exempt_channels: [
                    Constants.Channels.announcements.id,
                    Constants.Channels.reaction.id,
                ]
            )
        ).decode()

        let createdRule2Error = try await client.createAutoModerationRule(
            guildId: Constants.guildId,
            reason: "Testing!",
            payload: .init(
                name: "Testing 2",
                event_type: .messageSend,
                trigger_type: .mentionSpam,
                trigger_metadata: .init(
                    keyword_filter: nil,
                    regex_patterns: ["moo*l", "looooo*l"],
                    presets: [.slurs],
                    allow_list: ["good"],
                    mention_total_limit: 1,
                    mention_raid_protection_enabled: true
                ),
                actions: [.sendAlertMessage(channelId: Constants.Channels.moderation.id)],
                enabled: true,
                exempt_roles: [Constants.adminRoleId],
                exempt_channels: [
                    Constants.Channels.general.id,
                    Constants.Channels.perm1.id,
                ]
            )
        ).decodeJSONError()

        /// Can't create 2 mention spam rules
        XCTAssertEqual(
            createdRule2Error.code,
            .invalidFormBodyOrInvalidContentType,
            "\(createdRule2Error)"
        )

        let newRules = try await client.listAutoModerationRules(
            guildId: Constants.guildId
        ).decode().filter {
            $0.creator_id == Constants.botId
        }

        XCTAssertEqual(newRules.count, 2)

        let getRule = try await client.getAutoModerationRule(
            guildId: Constants.guildId,
            ruleId: createdRule1.id
        ).decode()

        XCTAssertEqual(getRule.id, createdRule1.id)

        let newName = "Testing 222"
        let updateRule = try await client.updateAutoModerationRule(
            guildId: Constants.guildId,
            ruleId: mentionSpamRule.id,
            reason: "Testing!",
            payload: .init(
                name: newName,
                event_type: .messageSend,
                trigger_type: .mentionSpam,
                trigger_metadata: .init(
                    keyword_filter: nil,
                    regex_patterns: ["moo*l", "looooo*l", "pooo*l"],
                    presets: [.slurs],
                    allow_list: ["good"],
                    mention_total_limit: 1,
                    mention_raid_protection_enabled: true
                ),
                actions: [.timeout(durationSeconds: 10)],
                enabled: false,
                exempt_roles: [Constants.adminRoleId],
                exempt_channels: [
                    Constants.Channels.general.id,
                    Constants.Channels.perm1.id,
                ]
            )
        ).decode()

        XCTAssertEqual(updateRule.id, mentionSpamRule.id)
        XCTAssertEqual(updateRule.name, newName)

        try await client.deleteAutoModerationRule(
            guildId: Constants.guildId,
            ruleId: createdRule1.id,
            reason: "Testing Cleanup!"
        ).guardSuccess()

        /// Can't delete the `.mentionSpam` rule:
        /// ```
        /// {
        ///   "message": "Mention Spam AutoMod rule cannot be deleted from community servers",
        ///   "code": 200006
        /// }
        /// ```
    }

    func testApplicationRoleConnectionMetadata() async throws {
        let update = try await client.bulkOverwriteApplicationRoleConnectionMetadata(
            payload: [
                .init(
                    type: .booleanEqual,
                    key: "key",
                    name: "name",
                    name_localizations: [.spanish: "nombre"],
                    description: "role connection description",
                    description_localizations: [
                        .englishUK: "role connection descriptionoo",
                        .englishUS: "role connection descriptionio",
                    ]
                ),
                .init(
                    type: .dateTimeGreaterThanOrEqual,
                    key: "keyio",
                    name: "namio",
                    name_localizations: [.spanish: "nombrepo"],
                    description: "role connection descriptionno",
                    description_localizations: [
                        .englishUK: "role connection descriptionooko",
                        .englishUS: "role connection descriptioniolo",
                    ]
                ),
            ]
        ).decode()

        XCTAssertEqual(update.count, 2)

        let metadata =
            try await client
            .listApplicationRoleConnectionMetadata()
            .decode()

        XCTAssertEqual(metadata.count, 2)
    }

    /// Couldn't find test-cases for the commented functions
    func testCDN() async throws {
        do {
            let file = try await client.getCDNCustomEmoji(
                emojiId: "1073704788400820324"
            ).getFile()
            XCTAssertGreaterThan(file.data.readableBytes, 100)
            XCTAssertEqual(file.extension, "png")
            XCTAssertEqual(file.filename, "1073704788400820324.png")
        }

        do {
            let file = try await client.getCDNGuildIcon(
                guildId: "965874258054094878",
                icon: "08b885eb2b03ee09fc906fa1a38cc1f8"
            ).getFile(overrideName: "guildIcon")
            XCTAssertGreaterThan(file.data.readableBytes, 100)
            XCTAssertEqual(file.extension, "png")
            XCTAssertEqual(file.filename, "guildIcon.png")
        }

        do {
            let file = try await client.getCDNGuildSplash(
                guildId: "922186320275722322",
                splash: "276ba186b5208a74344706941eb7fe8d"
            ).getFile()
            XCTAssertGreaterThan(file.data.readableBytes, 100)
        }

        do {
            let file = try await client.getCDNGuildDiscoverySplash(
                guildId: "922186320275722322",
                splash: "178be4921b08b761d9d9d6117c6864e2"
            ).getFile()
            XCTAssertGreaterThan(file.data.readableBytes, 100)
        }

        do {
            let file = try await client.getCDNGuildBanner(
                guildId: "922186320275722322",
                banner: "6e2e4d93e102a997cc46d15c28b0dfa0"
            ).getFile()
            XCTAssertGreaterThan(file.data.readableBytes, 100)
        }

        //        do {
        //            let file = try await client.getCDNUserBanner(
        //                userId: UserSnowflake,
        //                banner: String
        //            ).getFile()
        //            XCTAssertGreaterThan(file.data.readableBytes, 100)
        //        }

        do {
            let file = try await client.getCDNDefaultUserAvatar(
                discriminator: 0517
            ).getFile()
            XCTAssertGreaterThan(file.data.readableBytes, 100)
            XCTAssertEqual(file.extension, "png")
        }

        //        do {
        //            let file = try await client.getCDNGuildMemberAvatar(
        //                guildId: "922186320275722322",
        //                userId: "816681064855502868",
        //                avatar: "b94e12ce3debd281000d5291eec2b502"
        //            ).getFile()
        //            XCTAssertGreaterThan(file.data.readableBytes, 100)
        //        }
        //
        //        do {
        //            let file = try await client.getCDNUserAvatarDecoration(
        //                userId: UserSnowflake,
        //                avatarDecoration: String
        //            ).getFile()
        //            XCTAssertGreaterThan(file.data.readableBytes, 100)
        //        }

        do {
            let user = try await client.getUser(id: Constants.personalId).decode()

            XCTAssertEqual(user.id, Constants.personalId)

            let avatarDecoration = try XCTUnwrap(user.avatar_decoration_data)

            let file = try await client.getCDNAvatarDecoration(
                asset: avatarDecoration.asset
            ).getFile()
            XCTAssertGreaterThan(file.data.readableBytes, 100)
        }
        //
        //        do {
        //            let file = try await client.getCDNApplicationIcon(
        //                appId: ApplicationSnowflake, icon: String
        //            ).getFile()
        //            XCTAssertGreaterThan(file.data.readableBytes, 100)
        //        }
        //
        //        do {
        //            let file = try await client.getCDNApplicationCover(
        //                appId: ApplicationSnowflake, cover: String
        //            ).getFile()
        //            XCTAssertGreaterThan(file.data.readableBytes, 100)
        //        }

        do {
            let file = try await client.getCDNApplicationAsset(
                appId: "401518684763586560",
                assetId: "920476458709819483"
            ).getFile()
            XCTAssertGreaterThan(file.data.readableBytes, 100)
        }

        //        do {
        //            let file = try await client.getCDNAchievementIcon(
        //                appId: ApplicationSnowflake, achievementId: String, icon: String
        //            ).getFile()
        //            XCTAssertGreaterThan(file.data.readableBytes, 100)
        //        }

        //        do {
        //            let file = try await client.getCDNStorePageAsset(
        //                appId: ApplicationSnowflake,
        //                assetId: String
        //            ).getFile()
        //            XCTAssertGreaterThan(file.data.readableBytes, 100)
        //        }

        //        do {
        //            let file = try await client.getCDNTeamIcon(
        //                teamId: String, icon: String
        //            ).getFile()
        //            XCTAssertGreaterThan(file.data.readableBytes, 100)
        //        }

        do {
            let file = try await client.getCDNRoleIcon(
                roleId: "984557789999407214",
                icon: "2cba6c72f7abd52885359054e09ab7a2"
            ).getFile()
            XCTAssertGreaterThan(file.data.readableBytes, 100)
        }

        //
        //        do {
        //            let file = try await client.getCDNGuildMemberBanner(
        //                guildId: GuildSnowflake, userId: UserSnowflake, banner: String
        //            ).getFile()
        //            XCTAssertGreaterThan(file.data.readableBytes, 100)
        //        }

        /// `getCDNGuildScheduledEventCover()` is tested with guild-scheduled-event tests.
        /// `getCDNStickerPackBanner()` is tested with sticker tests.
        /// `getCDNUserAvatar()` is tested with guild-members tests.
        /// `getCDNSticker()` is tested with sticker tests.
    }

    func testMultipartPayload() async throws {
        let image = ByteBuffer(data: resource(name: "discordbm-logo.png"))

        do {
            let response = try await client.createMessage(
                channelId: Constants.Channels.spam.id,
                payload: .init(
                    content: "Multipart message normal attachment!",
                    files: [.init(data: image, filename: "discordbm.png")],
                    attachments: [.init(index: 0, description: "Test attachment!")]
                )
            ).decode()

            XCTAssertEqual(response.content, "Multipart message normal attachment!")
            XCTAssertEqual(response.attachments.count, 1)

            let attachment = try XCTUnwrap(response.attachments.first)
            XCTAssertEqual(attachment.filename, "discordbm.png")
            XCTAssertEqual(attachment.description, "Test attachment!")
            XCTAssertEqual(attachment.content_type, "image/png")
            XCTAssertGreaterThan(attachment.size, 20_000)
            XCTAssertEqual(attachment.height, 210)
            XCTAssertEqual(attachment.width, 1200)
            XCTAssertFalse(attachment.id.rawValue.isEmpty)
            XCTAssertFalse(attachment.url.isEmpty)
            XCTAssertFalse(attachment.proxy_url.isEmpty)

            let redownloaded =
                try await client
                .getFromCDN(url: attachment.url)
                .getFile()
            XCTAssertGreaterThan(redownloaded.data.readableBytes, 100)
        }

        do {
            let response = try await client.createMessage(
                channelId: Constants.Channels.spam.id,
                payload: .init(
                    content: "Multipart message embed attachment!",
                    embeds: [
                        .init(
                            title: "Multipart embed!",
                            timestamp: Date(),
                            image: .init(url: .attachment(name: "discordbm.png"))
                        )
                    ],
                    files: [.init(data: image, filename: "discordbm.png")]
                )
            ).decode()

            XCTAssertEqual(response.content, "Multipart message embed attachment!")
            XCTAssertEqual(response.attachments.count, 0)

            let embed = try XCTUnwrap(response.embeds.first)
            XCTAssertNotNil(embed.timestamp)

            let image = try XCTUnwrap(embed.image)
            XCTAssertEqual(image.height, 210)
            XCTAssertEqual(image.width, 1200)
            XCTAssertFalse(image.url.asString.isEmpty)
            XCTAssertFalse(image.proxy_url?.isEmpty == true)

            let redownloaded =
                try await client
                .getFromCDN(url: image.url.asString)
                .getFile()
            XCTAssertGreaterThan(redownloaded.data.readableBytes, 100)
        }

        do {
            let response = try await client.createMessage(
                channelId: Constants.Channels.spam.id,
                payload: .init(
                    content: "Multipart message filename no extension!",
                    files: [.init(data: image, filename: "discordbm")],
                    attachments: [.init(index: 0, filename: "discordbm")]
                )
            ).decode()

            XCTAssertEqual(response.content, "Multipart message filename no extension!")
            XCTAssertEqual(response.attachments.count, 1)

            let attachment = try XCTUnwrap(response.attachments.first)
            XCTAssertGreaterThan(attachment.size, 100)
        }
    }

    /// Rate-limiting has theoretical tests too, but this tests it in a practical situation.
    func testRateLimitedInPractice() async throws {
        let content = "Spamming! \(Date())"
        let rateLimitedErrors = ManagedAtomic(0)
        let count = 50
        let counter = Counter(target: count)

        let client: any DiscordClient = await DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token,
            /// Disable retrials.
            configuration: .init(retryPolicy: nil)
        )

        Task {
            for _ in 0..<count {
                do {
                    _ = try await client.createMessage(
                        channelId: Constants.Channels.spam.id,
                        payload: .init(content: content)
                    ).decode()
                    await counter.increase()
                } catch {
                    await counter.increase()
                    switch error {
                    case DiscordHTTPError.rateLimited:
                        rateLimitedErrors.wrappingIncrement(ordering: .relaxed)
                    default:
                        XCTFail("Received unexpected error: \(error)")
                    }
                }
            }
        }

        await counter.waitFulfillment()

        XCTAssertGreaterThan(rateLimitedErrors.load(ordering: .relaxed), 0)
        XCTAssertLessThan(rateLimitedErrors.load(ordering: .relaxed), count)

        /// Waiting 10 seconds to make sure the next tests don't get rate-limited
        try await Task.sleep(for: .seconds(10))
    }

    /// `ClientConfiguration.retryPolicy.basedOnHeaders` which is the `.default`
    /// should not let users notice rate-limits in a for-loop.
    func testClientConfigurationBasedOnHeadersWorksInPractice() async throws {
        let content = "Spamming 2! \(Date())"
        let rateLimitedErrors = ManagedAtomic(0)
        let count = 50
        let counter = Counter(target: count, timeout: 60)

        let client: any DiscordClient = await DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token
        )

        Task {
            for _ in 0..<count {
                do {
                    _ = try await client.createMessage(
                        channelId: Constants.Channels.spam2.id,
                        payload: .init(content: content)
                    ).decode()
                    await counter.increase()
                } catch {
                    await counter.increase()
                    switch error {
                    case DiscordHTTPError.rateLimited:
                        rateLimitedErrors.wrappingIncrement(ordering: .relaxed)
                    default:
                        XCTFail("Received unexpected error: \(error)")
                    }
                }
            }
        }

        await counter.waitFulfillment()

        XCTAssertEqual(rateLimitedErrors.load(ordering: .relaxed), 0)

        /// Waiting 10 seconds to make sure the next tests don't get rate-limited
        try await Task.sleep(for: .seconds(10))
    }

    func testCachingInPractice() async throws {
        /// Caching enabled
        do {
            let cachingBehavior = ClientConfiguration.CachingBehavior.enabled(
                defaultTTL: .seconds(2)
            )
            let configuration = ClientConfiguration(cachingBehavior: cachingBehavior)
            let cacheClient: any DiscordClient = await DefaultDiscordClient(
                httpClient: httpClient,
                token: Constants.token,
                configuration: configuration
            )

            /// We create a command, fetch the commands count, then delete the command
            /// and fetch the command count again.
            /// Since we are using caching, the first command count and the second command count
            /// must be the same (although it's wrong)
            let commandName = "test-command"
            let commandDesc = "Testing!"
            let command = try await cacheClient.createApplicationCommand(
                payload: .init(name: commandName, description: commandDesc)
            ).decode()

            XCTAssertEqual(command.name, commandName)
            XCTAssertEqual(command.description, commandDesc)

            let commandsCount = try await cacheClient.listApplicationCommands().decode().count

            try await cacheClient.deleteApplicationCommand(
                commandId: command.id
            ).guardSuccess()

            let newCommandsCount = try await cacheClient.listApplicationCommands()
                .decode().count

            XCTAssertEqual(commandsCount, newCommandsCount)
        }

        /// Because `ClientCache`s are shared across different `DefaultDiscordClient`s.
        /// This is to make sure the last test doesn't have impact on the next tests.
        try await Task.sleep(for: .seconds(2))

        /// Caching enabled, but with exception, so disabled
        do {
            let cachingBehavior = ClientConfiguration.CachingBehavior.custom(
                apiEndpoints: [.listApplicationCommands: .zero],
                apiEndpointsDefaultTTL: .seconds(2)
            )
            let configuration = ClientConfiguration(cachingBehavior: cachingBehavior)
            let cacheClient: any DiscordClient = await DefaultDiscordClient(
                httpClient: httpClient,
                token: Constants.token,
                configuration: configuration
            )

            /// We create a command, fetch the commands count, then delete the command
            /// and fetch the command count again.
            /// Since we are not using caching for this endpoint, the first command count and
            /// the second command count must NOT be the same.
            let commandName = "test-command"
            let commandDesc = "Testing!"
            let command = try await cacheClient.createApplicationCommand(
                payload: .init(name: commandName, description: commandDesc)
            ).decode()

            XCTAssertEqual(command.name, commandName)
            XCTAssertEqual(command.description, commandDesc)

            let commandsCount = try await cacheClient.listApplicationCommands().decode().count

            try await cacheClient.deleteApplicationCommand(
                commandId: command.id
            ).guardSuccess()

            let newCommandsCount =
                try await cacheClient
                .listApplicationCommands()
                .decode()
                .count

            XCTAssertEqual(commandsCount, newCommandsCount + 1)
        }

        /// Caching disabled
        do {
            let configuration = ClientConfiguration(cachingBehavior: .disabled)
            let cacheClient: any DiscordClient = await DefaultDiscordClient(
                httpClient: httpClient,
                token: Constants.token,
                configuration: configuration
            )

            /// We create a command, fetch the commands count, then delete the command
            /// and fetch the command count again.
            /// Since we are not using caching, the first command count and the second
            /// command count must NOT be the same.
            let commandName = "test-command"
            let commandDesc = "Testing!"
            let command = try await cacheClient.createApplicationCommand(
                payload: .init(name: commandName, description: commandDesc)
            ).decode()

            XCTAssertEqual(command.name, commandName)
            XCTAssertEqual(command.description, commandDesc)

            let commandsCount = try await cacheClient.listApplicationCommands().decode().count

            /// I think the command-addition takes effect a second or so later, so we need to
            /// wait a second before we try to delete the command, otherwise Discord might
            /// think the command doesn't exist and return 404.
            try await Task.sleep(for: .seconds(1))

            try await cacheClient.deleteApplicationCommand(
                commandId: command.id
            ).guardSuccess()

            let newCommandsCount =
                try await cacheClient
                .listApplicationCommands()
                .decode()
                .count

            XCTAssertEqual(commandsCount, newCommandsCount + 1)
        }
    }

    func testCachingInPracticeOnlyOneActualRequestMade() async throws {
        /// Caching enabled
        /// Will make 1 request a lot of times, but the `DefaultDiscordClient` must
        /// only send the request to Discord once, and all other times return a cached response.
        do {
            let configuration = ClientConfiguration(
                cachingBehavior: .enabled(defaultTTL: .seconds(10))
            )
            let cacheClient: any DiscordClient = await DefaultDiscordClient(
                httpClient: httpClient,
                token: Constants.token,
                configuration: configuration
            )

            /// Ridiculously high number just to make sure there is no concurrency mismanagement.
            let requestCount = 1_000
            let counter = Counter(target: requestCount, timeout: 25)
            let responses = Responses()
            for _ in 0..<requestCount {
                /// Detached so the requests run as concurrently as possible.
                Task.detached(priority: .high) {
                    do {
                        let response = try await cacheClient.getOwnUser()
                        try response.guardSuccess()
                        await counter.increase()
                        await responses.save(response: response.httpResponse)
                    } catch {
                        await counter.increase()
                        XCTFail("Unexpected error: \(error)")
                    }
                }
            }

            await counter.waitFulfillment()

            let allResponses = await responses.responses
            XCTAssertEqual(allResponses.count, requestCount)

            let cloudFlareUniqueRequestIdHeaders = allResponses.compactMap {
                $0.headers.first(name: "cf-ray")
            }
            XCTAssertEqual(cloudFlareUniqueRequestIdHeaders.count, requestCount)

            let allDifferentCloudFlareUniqueIds = Set(cloudFlareUniqueRequestIdHeaders)
            XCTAssertEqual(allDifferentCloudFlareUniqueIds.count, 1, "\(allDifferentCloudFlareUniqueIds)")

            /// Wait till the cached response is invalidated
            try await Task.sleep(for: .seconds(10))

            let response = try await cacheClient.getOwnUser()
            let cloudFlareUniqueId = try XCTUnwrap(response.httpResponse.headers.first(name: "cf-ray"))

            XCTAssertNotEqual(cloudFlareUniqueId, cloudFlareUniqueRequestIdHeaders.first)
        }
    }
}

private actor Counter {
    private var counter = 0
    private var target: Int
    private let timeout: Double
    private var expectation: Expectation?

    init(target: Int, timeout: Double = 10) {
        self.target = target
        self.timeout = timeout
    }

    func increase(file: StaticString = #filePath, line: UInt = #line) {
        self.counter += 1
        if self.counter == self.target {
            self.expectation?.fulfill(file: file, line: line)
            self.expectation = nil
        }
    }

    func waitFulfillment(file: StaticString = #filePath, line: UInt = #line) async {
        if self.counter == self.target {
            return
        } else {
            let exp = Expectation(description: "Counter")
            self.expectation = exp
            await Expectation.waitFulfillment(
                of: [exp],
                timeout: timeout,
                file: file,
                line: line
            )
        }
    }
}

private actor Responses {
    var responses = [DiscordHTTPResponse]()

    func save(response: DiscordHTTPResponse) {
        self.responses.append(response)
    }
}

/// This is used for a hack-ily run a bot manager
/// in the background while these tests are running.
/// This is to test `GatewayEventHandler` protocol and `DiscordCache`.
/// These tests don't assert anything. They're here just because the
/// `DiscordClient` tests trigger a lot of gateway events that are
/// useful for testing `DiscordCache` and `GatewayEventHandler` routings.
private actor GatewayTester {
    var botManagerAlreadySetUp = false
    var bot: BotGatewayManager? = nil
    var cache: DiscordCache? = nil
    var testsRan = 0
    private let totalTestCount = 41
    var isLastTest: Bool {
        self.testsRan == self.totalTestCount
    }

    private init() {
        /// Check to make sure `DiscordClientTests.testInvocations.count` == `self.totalTestCount`.
        /// Because `DiscordClientTests.testInvocations.count` is unavailable on linux.
        #if canImport(Darwin)
        if DiscordClientTests.testInvocations.count != self.totalTestCount {
            XCTFail(
                "Someone forgot to update 'GatewayTester.totalTestCount'. Update it to '\(DiscordClientTests.testInvocations.count)'"
            )
        }
        #endif
    }

    static let shared = GatewayTester()

    func toggleBotManagerAlreadySetUp() {
        self.botManagerAlreadySetUp.toggle()
    }

    func increaseTestsRanThenStartIfNeeded(httpClient: HTTPClient) async {
        self.testsRan += 1

        if !self.botManagerAlreadySetUp {
            self.toggleBotManagerAlreadySetUp()

            self.bot = await BotGatewayManager(
                eventLoopGroup: httpClient.eventLoopGroup,
                httpClient: httpClient,
                token: Constants.token,
                appId: Snowflake(Constants.botId),
                intents: Gateway.Intent.allCases
            )
            self.cache = await DiscordCache(
                gatewayManager: self.bot!,
                intents: .init(Gateway.Intent.allCases),
                requestAllMembers: .enabledWithPresences,
                messageCachingPolicy: .saveEditHistoryAndDeleted,
                itemsLimit: .constant(1_000)
            )
            await self.bot!.connect()

            let expectation = Expectation(description: "GatewayTesterConnect")

            let stream = await self.bot!.events
            Task {
                for await event in stream {
                    if case .ready = event.data {
                        expectation.fulfill()
                    }
                    EventHandler(event: event).handle()
                }
            }

            await Expectation.waitFulfillment(of: [expectation], timeout: 10)
        }
    }

    func endIfNeeded() async {
        if self.isLastTest {
            await self.bot?.disconnect()
            self.bot = nil
            self.cache = nil
        }
    }
}

/// To make sure the handler always provides a default value for all the functions.
private struct EventHandler: GatewayEventHandler {
    let event: Gateway.Event
}
