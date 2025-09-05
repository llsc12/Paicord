import DiscordModels
import Foundation

enum Constants {
    static let token: String = {
        if let token = ProcessInfo.processInfo.environment["BOT_TOKEN"] {
            return token
        } else {
            fatalError(
                "Due to the complexity of making integration tests work, they can only be run by the author of DiscordBM, PRs of the author on Github, or on the main branch commits, at least for now. Please reach out if you are facing any issues because of this"
            )
        }
    }()

    static let guildId: GuildSnowflake = "1036881950696288277"
    static let guildName = "DiscordBM Test Server"

    static let botId: UserSnowflake = "1030118727418646629"
    static let botName = "DisBMLibTestBot"

    static let personalId: UserSnowflake = "290483761559240704"
    static let personalName = "Mahdi BM"

    static let adminRoleId: RoleSnowflake = "1036971780717432832"
    static let dummyRoleId: RoleSnowflake = "1107534145548189726"

    static let secondAccountId: UserSnowflake = "966330655069843457"

    static let serverEmojiId: EmojiSnowflake = "1073704788400820324"

    enum Channels: ChannelSnowflake {
        case general = "1036881951463833612"
        case spam = "1038138527877181542"
        case spam2 = "1154513758106951710"
        case webhooks = "1066277056641503232"
        case webhooks2 = "1067783166074564658"
        case perm1 = "1069609693573554207"
        case perm2 = "1069614568466305135"
        case perm3 = "1069615830851145798"
        case reaction = "1073282726750330889"
        case threads = "1074227452987052052"
        case forum = "1075089016979984435"
        case announcements = "1075135538715172954"
        case moderation = "1075088920989138976"
        case voice = "1036881951463833613"
        case stage = "1107680127468457985"

        var id: ChannelSnowflake {
            self.rawValue
        }
    }
}
