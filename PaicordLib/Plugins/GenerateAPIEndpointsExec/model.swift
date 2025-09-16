import Foundation
import NIOHTTP1
import Yams

struct API: Decodable {

    struct Info: Decodable {
        var title: String
        var description: String
        var version: String
    }

    struct Server: Decodable {
        var url: String
    }

    struct Components: Decodable {

        struct Schemes: Decodable {

            struct Scheme: Decodable {
                var type: String
                var scheme: String
            }

            var bearerAuth: Scheme
            var apikeyAuth: Scheme
        }

        var securitySchemes: Schemes
    }

    struct Security: Decodable {
        var apikeyAuth: [String]
    }

    struct Tag: Decodable {
        var name: String
        var description: String
    }

    struct Path {

        fileprivate struct InfoDecodeModel: Decodable {

            var values: [(method: HTTPMethod, info: Info)]

            init(from decoder: any Decoder) throws {
                let container = try decoder.singleValueContainer()
                let infos = try container.decode([String: Info].self)
                self.values = infos.map { methodString, info in
                    var methodString = methodString
                    if let idx = methodString.firstIndex(of: "-") {
                        methodString.removeSubrange(idx...)
                    }
                    let method = HTTPMethod(rawValue: methodString.uppercased())
                    if case .RAW = method {
                        fatalError("Unhandled method: \(method)")
                    }
                    return (method, info)
                }.sorted {
                    $0.info.summary < $1.info.summary
                }
            }
        }

        struct Info: Decodable {

            enum Tag: String, Decodable {
                case polls = "Polls"
                case autoMod = "AutoMod"
                case auditLog = "Audit Log"
                case channels = "Channels"
                case commands = "Commands"
                case emoji = "Emoji"
                case entitlements = "Entitlements"
                case gateway = "Gateway"
                case guilds = "Guilds"
                case guildTemplates = "Guild Templates"
                case interactions = "Interactions"
                case invites = "Invites"
                case members = "Members"
                case messages = "Messages"
                case oAuth = "OAuth"
                case roles = "Roles"
                case roleConnections = "Role Connections"
                case scheduledEvents = "Scheduled Events"
                case skus = "SKUs"
                case stages = "Stages"
                case stickers = "Stickers"
                case threads = "Threads"
                case users = "Users"
                case voice = "Voice"
                case webhooks = "Webhooks"

                var priority: Int {
                    switch self {
                    case .polls: return 25
                    case .autoMod: return 24
                    case .auditLog: return 23
                    case .channels: return 22
                    case .commands: return 21
                    case .emoji: return 20
                    case .entitlements: return 19
                    case .gateway: return 18
                    case .guilds: return 17
                    case .guildTemplates: return 16
                    case .interactions: return 15
                    case .invites: return 14
                    case .members: return 13
                    case .messages: return 12
                    case .oAuth: return 11
                    case .roles: return 10
                    case .roleConnections: return 9
                    case .scheduledEvents: return 8
                    case .skus: return 7
                    case .stages: return 6
                    case .stickers: return 5
                    case .threads: return 4
                    case .users: return 3
                    case .voice: return 2
                    case .webhooks: return 1
                    }
                }

                var countsAgainstGlobalRateLimit: Bool {
                    switch self {
                    case .polls: return true
                    case .autoMod: return true
                    case .auditLog: return true
                    case .channels: return true
                    case .commands: return true
                    case .emoji: return true
                    case .entitlements: return true
                    case .gateway: return true
                    case .guilds: return true
                    case .guildTemplates: return true
                    case .interactions: return false
                    case .invites: return true
                    case .members: return true
                    case .messages: return true
                    case .oAuth: return true
                    case .roles: return true
                    case .roleConnections: return true
                    case .scheduledEvents: return true
                    case .skus: return true
                    case .stages: return true
                    case .stickers: return true
                    case .threads: return true
                    case .users: return true
                    case .voice: return true
                    case .webhooks: return true
                    }
                }

                var link: String {
                    switch self {
                    case .polls:
                        return "https://discord.com/developers/docs/resources/poll"
                    case .autoMod:
                        return "https://discord.com/developers/docs/resources/auto-moderation"
                    case .auditLog:
                        return "https://discord.com/developers/docs/resources/audit-log"
                    case .channels:
                        return "https://discord.com/developers/docs/resources/channel"
                    case .commands:
                        return "https://discord.com/developers/docs/interactions/application-commands"
                    case .emoji:
                        return "https://discord.com/developers/docs/resources/emoji"
                    case .entitlements:
                        return "https://discord.com/developers/docs/monetization/entitlements"
                    case .gateway:
                        return "https://discord.com/developers/docs/topics/gateway"
                    case .guilds:
                        return "https://discord.com/developers/docs/resources/guild"
                    case .guildTemplates:
                        return "https://discord.com/developers/docs/resources/guild-template"
                    case .interactions:
                        return "https://discord.com/developers/docs/interactions/receiving-and-responding"
                    case .invites:
                        return "https://discord.com/developers/docs/resources/invite"
                    case .members:
                        return "https://discord.com/developers/docs/resources/guild"
                    case .messages:
                        return "https://discord.com/developers/docs/resources/channel"
                    case .oAuth:
                        return "https://discord.com/developers/docs/topics/oauth2"
                    case .roles:
                        return "https://discord.com/developers/docs/resources/guild"
                    case .roleConnections:
                        return "https://discord.com/developers/docs/resources/user"
                    case .scheduledEvents:
                        return "https://discord.com/developers/docs/resources/guild-scheduled-event"
                    case .skus:
                        return "https://discord.com/developers/docs/monetization/skus"
                    case .stages:
                        return "https://discord.com/developers/docs/resources/stage-instance"
                    case .stickers:
                        return "https://discord.com/developers/docs/resources/sticker"
                    case .threads:
                        return "https://discord.com/developers/docs/resources/channel"
                    case .users:
                        return "https://discord.com/developers/docs/resources/user"
                    case .voice:
                        return "https://discord.com/developers/docs/resources/voice#list-voice-regions"
                    case .webhooks:
                        return "https://discord.com/developers/docs/resources/webhook"
                    }
                }
            }

            struct Parameter: Decodable {

                enum In: String, Decodable {
                    case path
                    case query
                    case header
                }

                struct Schema: Decodable {

                    enum Kind: String, Decodable {
                        case string
                    }

                    var type: Kind
                    var example: String?
                }

                var name: String
                var `in`: In
                var schema: Schema
                var required: Bool?
            }

            var tags: [Tag]
            var summary: String
            var parameters: [Parameter]?

            func makeCase() -> String {
                let summary = self.summary.toCamelCase()
                if summary.isEmpty {
                    fatalError("Summary is empty: \(self)")
                }
                let pathParams = (self.parameters ?? []).filter({ $0.in == .path })
                if pathParams.isEmpty {
                    return "case \(summary)"
                } else {
                    let paths = pathParams.map { param -> String in
                        let paramName = param.name.toCamelCase()
                        let type: String
                        switch param.schema.type {
                        case .string:
                            switch paramName {
                            case "guildId":
                                type = "GuildSnowflake"
                            case "applicationId":
                                type = "ApplicationSnowflake"
                            case "userId":
                                type = "UserSnowflake"
                            case "channelId":
                                type = "ChannelSnowflake"
                            case "messageId":
                                type = "MessageSnowflake"
                            case "roleId":
                                type = "RoleSnowflake"
                            case "commandId":
                                type = "CommandSnowflake"
                            case "integrationId":
                                type = "IntegrationSnowflake"
                            case "interactionId":
                                type = "InteractionSnowflake"
                            case "emojiId":
                                type = "EmojiSnowflake"
                            case "ruleId":
                                type = "RuleSnowflake"
                            case "stickerId":
                                type = "StickerSnowflake"
                            case "guildScheduledEventId":
                                type = "GuildScheduledEventSnowflake"
                            case "overwriteId":
                                type = "AnySnowflake"
                            case "webhookId":
                                type = "WebhookSnowflake"
                            case "entitlementId":
                                type = "EntitlementSnowflake"
                            case "skuId":
                                type = "SKUSnowflake"
                            case "answerId":
                                type = "Int"
                            case let name where name.hasSuffix("Id"):
                                print("Unhandled ID type: '\(paramName)'")
                                fatalError("Unhandled ID type: '\(paramName)'")
                            default:
                                type = "String"
                            }
                        }
                        return "\(paramName): \(type)"
                    }.joined(separator: ", ")
                    return "case \(summary)(\(paths))"
                }
            }

            func makeIterativeCase() -> (name: String, params: [String]) {
                let summary = self.summary.toCamelCase()
                if summary.isEmpty {
                    fatalError("Summary is empty: \(self)")
                }
                let pathParams = (self.parameters ?? []).filter({ $0.in == .path })
                if pathParams.isEmpty {
                    return ("case .\(summary):", [])
                } else {
                    let paths = pathParams.map { param -> String in
                        param.name.toCamelCase()
                    }
                    let pathsJoined = paths.joined(separator: ", ")
                    return ("case let .\(summary)(\(pathsJoined)):", paths)
                }
            }

            func makeRawCaseName() -> String {
                let summary = self.summary.toCamelCase()
                if summary.isEmpty {
                    fatalError("Summary is empty: \(self)")
                }
                return "case .\(summary):"
            }

            func makeRawCaseNameWithParams() -> (name: String, params: [String]) {
                let summary = self.summary.toCamelCase()
                if summary.isEmpty {
                    fatalError("Summary is empty: \(self)")
                }
                let pathParams = (self.parameters ?? []).filter({ $0.in == .path })
                let paths = pathParams.map { param -> String in
                    let paramName = param.name.toCamelCase()
                    return paramName
                }
                return ("case .\(summary):", paths)
            }
        }

        var path: String
        var method: HTTPMethod
        var info: Info
    }

    var version: String
    var info: Info
    var servers: [Server]
    var components: Components
    var security: [Security]
    var tags: [Tag]
    var paths: [Path]

    enum CodingKeys: String, CodingKey {
        case version = "openapi"
        case info
        case servers
        case components
        case security
        case tags
        case paths
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(String.self, forKey: .version)
        self.info = try container.decode(API.Info.self, forKey: .info)
        self.servers = try container.decode([API.Server].self, forKey: .servers)
        self.components = try container.decode(API.Components.self, forKey: .components)
        self.security = try container.decode([API.Security].self, forKey: .security)
        self.tags = try container.decode([API.Tag].self, forKey: .tags)
        let paths = try container.decode([String: Path.InfoDecodeModel].self, forKey: .paths)
        self.paths = paths.flatMap { key, value in
            value.values.map { value in
                Path(path: key, method: value.method, info: value.info)
            }
        }.sorted {
            $0.info.summary < $1.info.summary
        }.sorted {
            $0.method.priority < $1.method.priority
        }
    }

    static func decode() -> Self {
        let decoder = YAMLDecoder()
        let fm = FileManager.default
        let current = fm.currentDirectoryPath
        let path = current + "/Plugins/GenerateAPIEndpointsExec/Resources/openapi.yml"
        guard let data = fm.contents(atPath: path) else {
            fatalError(
                "Make sure you've set the custom working directory for the current scheme: https://docs.vapor.codes/getting-started/xcode/#custom-working-directory. If Xcode doesn't let you set a custom working directory with the instructions in the link, on the 'info' tab, set 'Executable' to 'Ask on Launch', then it should let you set your custom working directory. You can set 'Executable' back to 'None' afterwards."
            )
        }
        let decoded = try! decoder.decode(API.self, from: data)
        return decoded
    }
}
