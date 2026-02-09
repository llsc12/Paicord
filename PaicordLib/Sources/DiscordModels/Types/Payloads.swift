import Foundation
import NIOFoundationCompat

/// REST API payloads.
///
/// These types only need to be `Encodable`,
/// unless we actually need them to be `Decodable` as well.
public enum Payloads {

  /// Used to authenticate and retrieve credentials.
  /// https://docs.discord.food/authentication#login-account
  public struct Authentication: Sendable, Encodable, ValidatablePayload {
    public var login: String
    public var password: Secret
    public var undelete: Bool = false

    public var login_source: LoginSource? = nil
    public var gift_code_sku_id: String? = nil

    public init(login: String, password: Secret, undelete: Bool = false) {
      self.login = login
      self.password = password
      self.undelete = undelete
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(
        password.value,
        min: 8,
        max: 72,
        name: "password"
      )
    }

    /// Where a login is initiated from outside of the normal login flow.
    public enum LoginSource: String, Sendable, Encodable {
      case
        gift,
        guild_template,
        guild_invite,
        dm_invite,
        friend_invite,
        role_subscription,
        role_subscription_setting
    }
  }

  /// Used to send an SMS to the user's phone for MFA.
  /// https://docs.discord.food/authentication#send-mfa-sms
  public struct AuthenticationMFASendSMS: Sendable, Encodable,
    ValidatablePayload
  {
    public var ticket: Secret

    public init(ticket: Secret) {
      self.ticket = ticket
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// Used to complete MFA verify process when you've received a ticket rather than a token from the login endpoint.
  /// https://docs.discord.food/authentication#verify-mfa-login
  public struct AuthenticationMFA: Sendable, Encodable, ValidatablePayload {
    var code: String
    var ticket: Secret

    var login_source: Authentication.LoginSource? = nil
    var gift_code_sku_id: String? = nil

    public init(code: String, ticket: Secret) {
      self.code = code
      self.ticket = ticket
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(code, min: 6, max: 8, name: "code")
    }
  }

  /// https://docs.discord.food/authentication#logout-auth-sessions
  public struct LogoutSessions: Sendable, Encodable, ValidatablePayload {
    public var session_id_hashes: [String]

    public init(session_id_hashes: [String]) {
      self.session_id_hashes = session_id_hashes
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://docs.discord.food/authentication#forgot-password
  public struct ForgotPassword: Sendable, Encodable, ValidatablePayload {
    public var login: String

    public init(login: String) {
      self.login = login
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://docs.discord.food/authentication#mfa-verification
  public struct MFASubmitData: Sendable, Codable, ValidatablePayload {
    public var ticket: Secret
    public var mfa_type: MFAKind
    public var data: String

    public init(ticket: Secret, mfa_type: MFAKind, data: String) {
      self.ticket = ticket
      self.mfa_type = mfa_type
      self.data = data
    }

    public enum MFAKind: String, Sendable, Codable {
      case totp  // totp
      case sms  // sms
      case backup  // backup
      case webauthn  // webauthn
      case password  // password
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// An attachment object, but for sending.
  /// https://discord.com/developers/docs/resources/channel#attachment-object
  /// https://docs.discord.food/resources/message#attachment-structure
  public struct Attachment: Sendable, Encodable, Hashable, ValidatablePayload {
    /// When sending, `id` is the index of this attachment in the `files` you provide.
    public var id: String
    public var filename: String?
    public var uploaded_filename: String?
    public var title: String?
    public var description: String?
    public var content_type: String?
    public var size: Int?
    public var url: String?
    public var proxy_url: String?
    public var height: Int?
    public var width: Int?
    public var ephemeral: Bool?

    /// `index` is the index of this attachment in the `files` you provide.
    public init(
      index: Int,
      filename: String? = nil,
      uploaded_filename: String? = nil,
      title: String? = nil,
      description: String? = nil,
      content_type: String? = nil,
      size: Int? = nil,
      url: String? = nil,
      proxy_url: String? = nil,
      height: Int? = nil,
      width: Int? = nil,
      ephemeral: Bool? = nil
    ) {
      self.id = "\(index)"
      self.filename = filename
      self.uploaded_filename = uploaded_filename
      self.title = title
      self.description = description
      self.content_type = content_type
      self.size = size
      self.url = url
      self.proxy_url = proxy_url
      self.height = height
      self.width = width
      self.ephemeral = ephemeral
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountDoesNotExceed(
        description,
        max: 1_024,
        name: "description"
      )
    }
  }

  /// A allowed-mentions object, but for sending.
  /// https://discord.com/developers/docs/resources/channel#allowed-mentions-object
  public struct AllowedMentions: Sendable, Hashable, Codable, ValidatablePayload {
    public var parse: [DiscordChannel.AllowedMentions.Kind]?
    public var roles: [RoleSnowflake]?
    public var users: [UserSnowflake]?
    public var replied_user: Bool?

    /// What to be mentioned.
    /// - Parameters:
    ///   - parse: What general type of mentions to be allowed.
    ///     If empty, nothing will be allowed by this field (empty != `nil`).
    ///     Doesn't stop other fields from allowing mentions.
    ///   - roles: What roles to be allowed to be mentioned.
    ///   - users: What users to be allowed to be mentioned.
    ///   - replied_user: Allow to mention the replied user.
    public init(
      parse: [DiscordChannel.AllowedMentions.Kind]? = nil,
      roles: [RoleSnowflake]? = nil,
      users: [UserSnowflake]? = nil,
      replied_user: Bool? = nil
    ) {
      self.parse = parse
      self.roles = roles
      self.users = users
      self.replied_user = replied_user
    }

    public func validate() -> [ValidationFailure] {
      validateElementCountDoesNotExceed(roles, max: 100, name: "roles")
      validateElementCountDoesNotExceed(users, max: 100, name: "users")
    }
  }

  /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object
  public struct InteractionResponse: Sendable, MultipartEncodable,
    ValidatablePayload
  {

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-interaction-callback-type
    public enum Kind: Int, Sendable, Encodable {
      /// For ping-pong.
      case pong = 1
      /// Normal response.
      case channelMessageWithSource = 4
      /// Accepts a message to answer later. Shows a loading indicator.
      case deferredChannelMessageWithSource = 5
      /// Accepts a message to answer later. Doesn't show any loading indicators.
      case deferredUpdateMessage = 6
      /// Edit a message.
      case updateMessage = 7
      /// Auto-complete result for application commands.
      case applicationCommandAutoCompleteResult = 8
      /// A modal.
      case modal = 9
      /// Indication that user needs to unlock/buy this capability.
      @available(
        *,
        deprecated,
        message: """
          Deprecated by Discord; See the official docs for more info:
          https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-interaction-callback-type
          """
      )
      case premiumRequired = 10
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-messages
    public struct Message: Sendable, MultipartEncodable, ValidatablePayload {
      public var tts: Bool?
      public var content: String?
      public var embeds: [Embed]?
      public var allowedMentions: AllowedMentions?
      public var flags: IntBitField<DiscordChannel.Message.Flag>?
      public var components: Interaction.ComponentSwitch?
      public var attachments: [Attachment]?
      public var files: [RawFile]?
      public var poll: CreatePollRequest?

      enum CodingKeys: String, CodingKey {
        case tts
        case content
        case embeds
        case allowedMentions
        case flags
        case components
        case attachments
        case poll
      }

      public init(
        tts: Bool? = nil,
        content: String? = nil,
        embeds: [Embed]? = nil,
        allowedMentions: AllowedMentions? = nil,
        flags: IntBitField<DiscordChannel.Message.Flag>? = nil,
        components: Interaction.ComponentSwitch? = nil,
        attachments: [Attachment]? = nil,
        files: [RawFile]? = nil,
        poll: CreatePollRequest? = nil
      ) {
        self.tts = tts
        self.content = content
        self.embeds = embeds
        self.allowedMentions = allowedMentions
        self.flags = flags
        self.components = components
        self.attachments = attachments
        self.files = files
        self.poll = poll
      }

      public func validate() -> [ValidationFailure] {
        validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
        allowedMentions?.validate()
        validateOnlyContains(
          flags,
          name: "flags",
          reason: "Can only contain 'suppressEmbeds' and 'ephemeral'",
          allowed: [.suppressEmbeds, .ephemeral]
        )
        if let components = components?.legacy {
          validateElementCountDoesNotExceed(
            components,
            max: 5,
            name: "components"
          )
          components.validate()
        }
        attachments?.validate()
        embeds?.validate()
        poll?.validate()
      }
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-autocomplete
    public struct Autocomplete: Sendable, Encodable, ValidatablePayload {
      public var choices: [ApplicationCommand.Option.Choice]

      public init(choices: [ApplicationCommand.Option.Choice]) {
        self.choices = choices
      }

      public func validate() -> [ValidationFailure] {
        validateElementCountDoesNotExceed(choices, max: 25, name: "choices")
      }
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-modal
    public struct Modal: Sendable, Encodable, ValidatablePayload {
      public var custom_id: String
      public var title: String
      public var components: Interaction.ComponentSwitch

      /// Discord docs says currently you can only send text-inputs.
      /// To send other types of components, use a normal message's `components`:
      /// `Payloads.InteractionResponse.Message(components: [...])`
      /// Respectively, you can't send a text-input using a normal message's `components`.
      public init(
        custom_id: String,
        title: String,
        textInputs: [Interaction.ActionRow.TextInput]
      ) {
        self.custom_id = custom_id
        self.title = title
        self.components = .legacy(textInputs.map { [.textInput($0)] })
      }

      public func validate() -> [ValidationFailure] {
        if let components = components.legacy {
          validateElementCountInRange(
            components,
            min: 1,
            max: 5,
            name: "components"
          )
        }
      }
    }

    /// A container for message flags.
    struct Flags: Sendable, Encodable, ValidatablePayload {
      var flags: IntBitField<DiscordChannel.Message.Flag>?

      init(isEphemeral: Bool) {
        self.flags = isEphemeral ? [.ephemeral] : nil
      }

      func validate() -> [ValidationFailure] {}
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-interaction-callback-data-structure
    internal enum CallbackData: Sendable, MultipartEncodable, ValidatablePayload {
      case message(Message)
      case autocomplete(Autocomplete)
      case modal(Modal)
      case flags(Flags)

      var files: [RawFile]? {
        switch self {
        case .message(let message):
          return message.files
        case .autocomplete, .modal, .flags:
          return nil
        }
      }

      func validate() -> [ValidationFailure] {
        switch self {
        case .message(let message):
          message.validate()
        case .autocomplete(let autocomplete):
          autocomplete.validate()
        case .modal(let modal):
          modal.validate()
        case .flags:
          /// For the result builder
          Optional<ValidationFailure>.none
        }
      }

      func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .message(let message):
          try container.encode(message)
        case .autocomplete(let autocomplete):
          try container.encode(autocomplete)
        case .modal(let modal):
          try container.encode(modal)
        case .flags(let flags):
          try container.encode(flags)
        }
      }
    }

    enum CodingKeys: String, CodingKey {
      case type
      case data
    }

    public var type: Kind
    internal var data: CallbackData?
    public var files: [RawFile]? {
      data?.files
    }

    private init(type: Kind, data: CallbackData? = nil) {
      self.type = type
      self.data = data
    }

    public func validate() -> [ValidationFailure] {
      data?.validate()
    }

    /// Creates a response of type `Kind.pong`.
    public static var pong: Self {
      .init(type: .pong)
    }

    /// Creates a response of type `Kind.channelMessageWithSource`.
    public static func channelMessageWithSource(_ message: Message) -> Self {
      .init(type: .channelMessageWithSource, data: .message(message))
    }

    /// Creates a response of type `Kind.deferredChannelMessageWithSource`.
    /// The `.ephemeral` message flag needs to be set here on a deferred message.
    /// The main message's flags can't override this flag.
    /// Discord barely mentions this behavior here: https://discord.com/developers/docs/interactions/receiving-and-responding#create-followup-message
    public static func deferredChannelMessageWithSource(
      isEphemeral: Bool = false
    ) -> Self {
      .init(
        type: .deferredChannelMessageWithSource,
        data: .flags(.init(isEphemeral: isEphemeral))
      )
    }

    /// Creates a response of type `Kind.deferredUpdateMessage`.
    /// The `.ephemeral` message flag needs to be set here on a deferred message.
    /// The main message's flags can't override this flag.
    /// Discord barely mentions this behavior here: https://discord.com/developers/docs/interactions/receiving-and-responding#create-followup-message
    public static func deferredUpdateMessage(isEphemeral: Bool = false) -> Self {
      .init(
        type: .deferredUpdateMessage,
        data: .flags(.init(isEphemeral: isEphemeral))
      )
    }

    /// Creates a response of type `Kind.updateMessage`.
    public static func updateMessage(_ message: Message) -> Self {
      .init(type: .updateMessage, data: .message(message))
    }

    /// Creates a response of type `Kind.applicationCommandAutoCompleteResult`.
    public static func autocompleteResult(_ result: Autocomplete) -> Self {
      .init(
        type: .applicationCommandAutoCompleteResult,
        data: .autocomplete(result)
      )
    }

    /// Creates a response of type `Kind.modal`.
    public static func modal(_ modal: Modal) -> Self {
      .init(type: .modal, data: .modal(modal))
    }

    /// Creates a response of type `Kind.premiumRequired`.
    public static func premiumRequired(isEphemeral: Bool = false) -> Self {
      .init(
        type: .premiumRequired,
        data: .flags(.init(isEphemeral: isEphemeral))
      )
    }
  }

  public struct ImageData: Sendable, Codable {
    public var file: RawFile

    public init(file: RawFile) {
      self.file = file
    }

    public init(from decoder: any Decoder) throws {
      let string = try String(from: decoder)
      guard let file = ImageData.decodeFromString(string) else {
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: decoder.codingPath,
            debugDescription:
              "\(string.debugDescription) can't be base64 decoded into a file"
          )
        )
      }
      self.file = file
    }

    public func encode(to encoder: any Encoder) throws {
      guard let string = self.encodeToString() else {
        throw EncodingError.invalidValue(
          file,
          .init(
            codingPath: encoder.codingPath,
            debugDescription: "Can't base64 encode the file"
          )
        )
      }
      var container = encoder.singleValueContainer()
      try container.encode(string)
    }

    static func decodeFromString(_ string: String) -> RawFile? {
      var filename: String?
      guard string.hasPrefix("data:") else {
        return nil
      }
      guard let semicolon = string.firstIndex(of: ";") else {
        return nil
      }
      let type = string[string.startIndex..<semicolon].dropFirst(5)
      let typeComps = type.split(separator: "/", maxSplits: 1)
      if typeComps.count == 2,
        let ext = fileExtensionMediaTypeMapping.first(
          where: { $1.0 == typeComps[0] && $1.1 == typeComps[1] }
        )?.key
      {
        filename = "unknown.\(ext)"
      }
      guard string[semicolon...].hasPrefix(";base64,") else {
        return nil
      }
      let encodedString = string[semicolon...].dropFirst(8)
      guard let data = Data(base64Encoded: String(encodedString)) else {
        return nil
      }
      return .init(data: .init(data: data), filename: filename ?? "unknown")
    }

    func encodeToString() -> String? {
      guard let type = file.type else { return nil }
      let data = Data(buffer: file.data, byteTransferStrategy: .noCopy)
      let encoded = data.base64EncodedString()
      return "data:\(type);base64,\(encoded)"
    }
  }

  /// https://discord.com/developers/docs/resources/channel#create-message-jsonform-params
  /// https://docs.discord.food/resources/message#create-message
  public struct CreateMessage: Sendable, Hashable, MultipartEncodable,
    ValidatablePayload
  {
    public var content: String?
    public var nonce: StringOrInt?
    public var tts: Bool?
    public var embeds: [Embed]?
    public var allowed_mentions: AllowedMentions?
    public var message_reference: DiscordChannel.Message.MessageReference?
    public var components: Interaction.ComponentSwitch?
    public var sticker_ids: [String]?
    public var files: [RawFile]?
    public var attachments: [Attachment]?
    public var flags: IntBitField<DiscordChannel.Message.Flag>?
    //    public var enforce_nonce: Bool?
    public var poll: CreatePollRequest?

    enum CodingKeys: String, CodingKey {
      case content
      case nonce
      case tts
      case embeds
      case allowed_mentions
      case message_reference
      case components
      case sticker_ids
      case attachments
      case flags
      //      case enforce_nonce
      case poll
    }

    public init(
      content: String? = nil,
      nonce: StringOrInt? = nil,
      tts: Bool? = nil,
      embeds: [Embed]? = nil,
      allowed_mentions: AllowedMentions? = nil,
      message_reference: DiscordChannel.Message.MessageReference? = nil,
      components: Interaction.ComponentSwitch? = nil,
      sticker_ids: [String]? = nil,
      files: [RawFile]? = nil,
      attachments: [Attachment]? = nil,
      flags: IntBitField<DiscordChannel.Message.Flag>? = nil,
      //      enforce_nonce: Bool? = nil,
      poll: CreatePollRequest? = nil
    ) {
      self.content = content
      self.nonce = nonce
      self.tts = tts
      self.embeds = embeds
      self.allowed_mentions = allowed_mentions
      self.message_reference = message_reference
      self.components = components
      self.sticker_ids = sticker_ids
      self.files = files
      self.attachments = attachments
      self.flags = flags
      //      self.enforce_nonce = enforce_nonce
      self.poll = poll
    }

    public func validate() -> [ValidationFailure] {
      validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
      validateElementCountDoesNotExceed(
        sticker_ids,
        max: 3,
        name: "sticker_ids"
      )
      validateCharacterCountDoesNotExceed(content, max: 2_000, name: "content")
      validateCharacterCountDoesNotExceed(
        nonce?.asString,
        max: 25,
        name: "nonce"
      )
      allowed_mentions?.validate()
      validateAtLeastOneIsNotEmpty(
        content?.isEmpty,
        embeds?.isEmpty,
        sticker_ids?.isEmpty,
        components?.legacy?.isEmpty,
        files?.isEmpty,
        poll?.answers.isEmpty,
        names: "content",
        "embeds",
        "sticker_ids",
        "components",
        "files",
        "poll"
      )
      validateCombinedCharacterCountDoesNotExceed(
        embeds?.reduce(into: 0, { $0 += $1.contentLength }),
        max: 6_000,
        names: "embeds"
      )
      validateOnlyContains(
        flags,
        name: "flags",
        reason: "Can only contain 'suppressEmbeds' or 'suppressNotifications'",
        allowed: [.suppressEmbeds, .suppressNotifications]
      )
      attachments?.validate()
      embeds?.validate()
      poll?.validate()
    }
  }

  /// https://discord.com/developers/docs/resources/channel#edit-message-jsonform-params
  public struct EditMessage: Sendable, MultipartEncodable, ValidatablePayload {
    public var content: String?
    public var embeds: [Embed]?
    public var flags: IntBitField<DiscordChannel.Message.Flag>?
    public var allowed_mentions: AllowedMentions?
    public var components: Interaction.ComponentSwitch?
    public var files: [RawFile]?
    public var attachments: [Attachment]?

    enum CodingKeys: String, CodingKey {
      case content
      case embeds
      case flags
      case allowed_mentions
      case components
      case attachments
    }

    public init(
      content: String? = nil,
      embeds: [Embed]? = nil,
      flags: IntBitField<DiscordChannel.Message.Flag>? = nil,
      allowed_mentions: AllowedMentions? = nil,
      components: Interaction.ComponentSwitch? = nil,
      files: [RawFile]? = nil,
      attachments: [Attachment]? = nil
    ) {
      self.content = content
      self.embeds = embeds
      self.flags = flags
      self.allowed_mentions = allowed_mentions
      self.components = components
      self.files = files
      self.attachments = attachments
    }

    public func validate() -> [ValidationFailure] {
      validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
      validateCharacterCountDoesNotExceed(content, max: 2_000, name: "content")
      validateCombinedCharacterCountDoesNotExceed(
        embeds?.reduce(into: 0, { $0 += $1.contentLength }),
        max: 6_000,
        names: "embeds"
      )
      validateOnlyContains(
        flags,
        name: "flags",
        reason: "Can only contain 'suppressEmbeds'",
        allowed: [.suppressEmbeds]
      )
      allowed_mentions?.validate()
      attachments?.validate()
      embeds?.validate()
    }
  }

  /// https://discord.com/developers/docs/resources/webhook#execute-webhook-jsonform-params
  public struct ExecuteWebhook: Sendable, MultipartEncodable, ValidatablePayload {
    public var content: String?
    public var username: String?
    public var avatar_url: String?
    public var tts: Bool?
    public var embeds: [Embed]?
    public var allowed_mentions: AllowedMentions?
    public var components: Interaction.ComponentSwitch?
    public var files: [RawFile]?
    public var attachments: [Attachment]?
    public var flags: IntBitField<DiscordChannel.Message.Flag>?
    public var thread_name: String?
    public var applied_tags: [ForumTagSnowflake]?
    public var poll: CreatePollRequest?

    enum CodingKeys: CodingKey {
      case content
      case username
      case avatar_url
      case tts
      case embeds
      case allowed_mentions
      case components
      case attachments
      case flags
      case thread_name
      case applied_tags
      case poll
    }

    public init(
      content: String? = nil,
      username: String? = nil,
      avatar_url: String? = nil,
      tts: Bool? = nil,
      embeds: [Embed]? = nil,
      allowed_mentions: AllowedMentions? = nil,
      components: Interaction.ComponentSwitch? = nil,
      files: [RawFile]? = nil,
      attachments: [Attachment]? = nil,
      flags: IntBitField<DiscordChannel.Message.Flag>? = nil,
      thread_name: String? = nil,
      applied_tags: [ForumTagSnowflake]? = nil,
      poll: CreatePollRequest? = nil
    ) {
      self.content = content
      self.username = username
      self.avatar_url = avatar_url
      self.tts = tts
      self.embeds = embeds
      self.allowed_mentions = allowed_mentions
      self.components = components
      self.files = files
      self.attachments = attachments
      self.flags = flags
      self.thread_name = thread_name
      self.applied_tags = applied_tags
      self.poll = poll
    }

    public func validate() -> [ValidationFailure] {
      validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
      validateCharacterCountDoesNotExceed(content, max: 2_000, name: "content")
      validateAtLeastOneIsNotEmpty(
        content?.isEmpty,
        components?.legacy?.isEmpty,
        files?.isEmpty,
        embeds?.isEmpty,
        poll?.answers.isEmpty,
        names: "content",
        "components",
        "files",
        "embeds",
        "poll"
      )
      validateCombinedCharacterCountDoesNotExceed(
        embeds?.reduce(into: 0, { $0 += $1.contentLength }),
        max: 6_000,
        names: "embeds"
      )
      validateOnlyContains(
        flags,
        name: "flags",
        reason: "Can only contain 'suppressEmbeds' or 'suppressNotifications'",
        allowed: [.suppressEmbeds, .suppressNotifications]
      )
      allowed_mentions?.validate()
      attachments?.validate()
      embeds?.validate()
      poll?.validate()
    }
  }

  /// https://discord.com/developers/docs/resources/webhook#create-webhook-json-params
  public struct CreateWebhook: Sendable, Encodable, ValidatablePayload {
    public var name: String
    public var avatar: ImageData?

    public init(name: String, avatar: ImageData? = nil) {
      self.name = name
      self.avatar = avatar
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 1, max: 80, name: "name")
      validateCaseInsensitivelyDoesNotContain(
        name,
        name: "name",
        values: ["clyde", "discord"],
        reason: "name can't contain 'clyde' or 'discord' (case-insensitive)"
      )
    }
  }

  /// https://discord.com/developers/docs/resources/webhook#modify-webhook-with-token
  public struct ModifyWebhook: Sendable, Encodable, ValidatablePayload {
    public var name: String?
    public var avatar: ImageData?

    public init(name: String? = nil, avatar: ImageData? = nil) {
      self.name = name
      self.avatar = avatar
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/webhook#modify-webhook-json-params
  public struct ModifyGuildWebhook: Sendable, Encodable, ValidatablePayload {
    public var name: String?
    public var avatar: ImageData?
    public var channel_id: ChannelSnowflake?

    public init(
      name: String,
      avatar: ImageData? = nil,
      channel_id: ChannelSnowflake? = nil
    ) {
      self.name = name
      self.avatar = avatar
      self.channel_id = channel_id
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/webhook#edit-webhook-message-jsonform-params
  public struct EditWebhookMessage: Sendable, MultipartEncodable,
    ValidatablePayload
  {
    public var content: String?
    public var embeds: [Embed]?
    public var allowed_mentions: AllowedMentions?
    public var components: Interaction.ComponentSwitch?
    public var files: [RawFile]?
    public var attachments: [Attachment]?

    enum CodingKeys: String, CodingKey {
      case content
      case embeds
      case allowed_mentions
      case components
      case attachments
    }

    public init(
      content: String? = nil,
      embeds: [Embed]? = nil,
      allowed_mentions: AllowedMentions? = nil,
      components: Interaction.ComponentSwitch? = nil,
      files: [RawFile]? = nil,
      attachments: [Attachment]? = nil
    ) {
      self.content = content
      self.embeds = embeds
      self.allowed_mentions = allowed_mentions
      self.components = components
      self.files = files
      self.attachments = attachments
    }

    public func validate() -> [ValidationFailure] {
      validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
      validateCharacterCountDoesNotExceed(content, max: 2_000, name: "content")
      validateCombinedCharacterCountDoesNotExceed(
        embeds?.reduce(into: 0, { $0 += $1.contentLength }),
        max: 6_000,
        names: "embeds"
      )
      allowed_mentions?.validate()
      attachments?.validate()
      embeds?.validate()
    }
  }

  public struct CreateThreadFromMessage: Sendable, Encodable, ValidatablePayload {
    public var name: String
    public var auto_archive_duration: DiscordChannel.AutoArchiveDuration?
    public var rate_limit_per_user: Int?

    public init(
      name: String,
      auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil,
      rate_limit_per_user: Int? = nil
    ) {
      self.name = name
      self.auto_archive_duration = auto_archive_duration
      self.rate_limit_per_user = rate_limit_per_user
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
      validateNumberInRangeOrNil(
        rate_limit_per_user,
        min: 0,
        max: 21_600,
        name: "rate_limit_per_user"
      )
    }
  }

  public struct CreateThreadWithoutMessage: Sendable, Encodable,
    ValidatablePayload
  {
    public var name: String
    public var auto_archive_duration: DiscordChannel.AutoArchiveDuration?
    public var type: ThreadKind
    public var invitable: Bool?
    public var rate_limit_per_user: Int?

    public init(
      name: String,
      auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil,
      type: ThreadKind,
      invitable: Bool? = nil,
      rate_limit_per_user: Int? = nil
    ) {
      self.name = name
      self.auto_archive_duration = auto_archive_duration
      self.type = type
      self.invitable = invitable
      self.rate_limit_per_user = rate_limit_per_user
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
      validateNumberInRangeOrNil(
        rate_limit_per_user,
        min: 0,
        max: 21_600,
        name: "rate_limit_per_user"
      )
    }
  }

  public struct CreateThreadInForumChannel: Sendable, MultipartEncodable,
    ValidatablePayload
  {

    /// https://discord.com/developers/docs/resources/channel#start-thread-in-forum-channel-forum-thread-message-params-object
    public struct ForumMessage: Sendable, MultipartEncodable, ValidatablePayload {
      public var content: String?
      public var embeds: [Embed]?
      public var allowed_mentions: AllowedMentions?
      public var components: Interaction.ComponentSwitch?
      public var sticker_ids: [String]?
      public var files: [RawFile]?
      public var attachments: [Attachment]?
      public var flags: IntBitField<DiscordChannel.Message.Flag>?
      public var poll: CreatePollRequest?

      enum CodingKeys: String, CodingKey {
        case content
        case embeds
        case allowed_mentions
        case components
        case sticker_ids
        case attachments
        case flags
        case poll
      }

      public init(
        content: String? = nil,
        embeds: [Embed]? = nil,
        allowed_mentions: AllowedMentions? = nil,
        components: Interaction.ComponentSwitch? = nil,
        sticker_ids: [String]? = nil,
        files: [RawFile]? = nil,
        attachments: [Attachment]? = nil,
        flags: IntBitField<DiscordChannel.Message.Flag>? = nil,
        poll: CreatePollRequest? = nil
      ) {
        self.content = content
        self.embeds = embeds
        self.allowed_mentions = allowed_mentions
        self.components = components
        self.sticker_ids = sticker_ids
        self.files = files
        self.attachments = attachments
        self.flags = flags
        self.poll = poll
      }

      public func validate() -> [ValidationFailure] {
        validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
        validateElementCountDoesNotExceed(
          sticker_ids,
          max: 3,
          name: "sticker_ids"
        )
        validateCharacterCountDoesNotExceed(
          content,
          max: 2_000,
          name: "content"
        )
        allowed_mentions?.validate()
        validateAtLeastOneIsNotEmpty(
          content?.isEmpty,
          embeds?.isEmpty,
          sticker_ids?.isEmpty,
          components?.legacy?.isEmpty,
          files?.isEmpty,
          poll?.answers.isEmpty,
          names: "content",
          "embeds",
          "sticker_ids",
          "components",
          "files",
          "poll"
        )
        validateCombinedCharacterCountDoesNotExceed(
          embeds?.reduce(into: 0, { $0 += $1.contentLength }),
          max: 6_000,
          names: "embeds"
        )
        validateOnlyContains(
          flags,
          name: "flags",
          reason:
            "Can only contain 'suppressEmbeds' or 'suppressNotifications'",
          allowed: [.suppressEmbeds, .suppressNotifications]
        )
        attachments?.validate()
        embeds?.validate()
        poll?.validate()
      }
    }

    public var name: String
    public var auto_archive_duration: DiscordChannel.AutoArchiveDuration?
    public var rate_limit_per_user: Int?
    public var message: ForumMessage
    public var applied_tags: [ForumTagSnowflake]?
    public var files: [RawFile]? {
      message.files
    }

    enum CodingKeys: String, CodingKey {
      case name
      case auto_archive_duration
      case rate_limit_per_user
      case message
      case applied_tags
    }

    public init(
      name: String,
      auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil,
      rate_limit_per_user: Int? = nil,
      message: ForumMessage,
      applied_tags: [ForumTagSnowflake]? = nil
    ) {
      self.name = name
      self.auto_archive_duration = auto_archive_duration
      self.rate_limit_per_user = rate_limit_per_user
      self.message = message
      self.applied_tags = applied_tags
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
      validateNumberInRangeOrNil(
        rate_limit_per_user,
        min: 0,
        max: 21_600,
        name: "rate_limit_per_user"
      )
      self.message.validate()
    }
  }

  public struct ApplicationCommandCreate: Sendable, Encodable,
    ValidatablePayload
  {
    public var name: String
    public var name_localizations: DiscordLocaleDict<String>?
    public var description: String?
    public var description_localizations: DiscordLocaleDict<String>?
    public var options: [ApplicationCommand.Option]?
    public var default_member_permissions: StringBitField<Permission>?
    public var dm_permission: Bool?
    public var type: ApplicationCommand.Kind?
    public var nsfw: Bool?
    public var integration_types: [DiscordApplication.IntegrationKind]?
    public var contexts: [Interaction.ContextKind]?

    public init(
      name: String,
      name_localizations: [DiscordLocale: String]? = nil,
      description: String? = nil,
      description_localizations: [DiscordLocale: String]? = nil,
      options: [ApplicationCommand.Option]? = nil,
      default_member_permissions: [Permission]? = nil,
      dm_permission: Bool? = nil,
      type: ApplicationCommand.Kind? = nil,
      nsfw: Bool? = nil,
      integration_types: [DiscordApplication.IntegrationKind]? = nil,
      contexts: [Interaction.ContextKind]? = nil
    ) {
      self.name = name
      self.name_localizations = .init(name_localizations)
      self.description = description
      self.description_localizations = .init(description_localizations)
      self.options = options
      self.default_member_permissions = default_member_permissions.map({
        .init($0)
      })
      self.dm_permission = dm_permission
      self.type = type
      self.nsfw = nsfw
      self.integration_types = integration_types
      self.contexts = contexts
    }

    public func validate() -> [ValidationFailure] {
      validateHasPrecondition(
        condition: options.isNotEmpty,
        allowedIf: (type ?? .chatInput) == .chatInput,
        name: "options",
        reason: "'options' is only allowed if 'type' is 'chatInput'"
      )
      validateHasPrecondition(
        condition: description.isNotEmpty
          || (description_localizations?.values).isNotEmpty,
        allowedIf: (type ?? .chatInput) == .chatInput,
        name: "description+description_localizations",
        reason:
          "'description' or 'description_localizations' are only allowed if 'type' is 'chatInput'"
      )
      validateCharacterCountInRange(name, min: 1, max: 32, name: "name")
      validateCharacterCountDoesNotExceed(
        description,
        max: 100,
        name: "description"
      )
      for (_, value) in name_localizations?.values ?? [:] {
        validateCharacterCountInRange(
          value,
          min: 1,
          max: 32,
          name: "name_localizations.name"
        )
      }
      for (_, value) in description_localizations?.values ?? [:] {
        validateCharacterCountInRange(
          value,
          min: 1,
          max: 32,
          name: "description_localizations.name"
        )
      }
      validateElementCountDoesNotExceed(options, max: 25, name: "options")
      options?.validate()
    }
  }

  public struct ApplicationCommandEdit: Sendable, Encodable, ValidatablePayload {
    public var name: String?
    public var name_localizations: DiscordLocaleDict<String>?
    public var description: String?
    public var description_localizations: DiscordLocaleDict<String>?
    public var options: [ApplicationCommand.Option]?
    public var default_member_permissions: StringBitField<Permission>?
    public var dm_permission: Bool?
    public var nsfw: Bool?
    public var integration_types: [DiscordApplication.IntegrationKind]?
    public var contexts: [Interaction.ContextKind]?

    public init(
      name: String? = nil,
      name_localizations: [DiscordLocale: String]? = nil,
      description: String? = nil,
      description_localizations: [DiscordLocale: String]? = nil,
      options: [ApplicationCommand.Option]? = nil,
      default_member_permissions: [Permission]? = nil,
      dm_permission: Bool? = nil,
      nsfw: Bool? = nil,
      integration_types: [DiscordApplication.IntegrationKind]? = nil,
      contexts: [Interaction.ContextKind]? = nil
    ) {
      self.name = name
      self.name_localizations = .init(name_localizations)
      self.description = description
      self.description_localizations = .init(description_localizations)
      self.options = options
      self.default_member_permissions = default_member_permissions.map({
        .init($0)
      })
      self.dm_permission = dm_permission
      self.nsfw = nsfw
      self.integration_types = integration_types
      self.contexts = contexts
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 1, max: 32, name: "name")
      validateCharacterCountDoesNotExceed(
        description,
        max: 100,
        name: "description"
      )
      for (_, value) in name_localizations?.values ?? [:] {
        validateCharacterCountInRange(
          value,
          min: 1,
          max: 32,
          name: "name_localizations.name"
        )
      }
      for (_, value) in description_localizations?.values ?? [:] {
        validateCharacterCountInRange(
          value,
          min: 1,
          max: 32,
          name: "description_localizations.name"
        )
      }
      validateElementCountDoesNotExceed(options, max: 25, name: "options")
      options?.validate()
    }
  }

  public struct EditApplicationCommandPermissions: Sendable, Encodable,
    ValidatablePayload
  {
    public var permissions: [GuildApplicationCommandPermissions.Permission]

    public init(permissions: [GuildApplicationCommandPermissions.Permission]) {
      self.permissions = permissions
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/channel#modify-channel-json-params-group-dm
  public struct ModifyGroupDMChannel: Sendable, Encodable, ValidatablePayload {
    public var name: String?
    public var icon: ImageData?

    public init(name: String? = nil, icon: ImageData? = nil) {
      self.name = name
      self.icon = icon
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRangeOrNil(name, min: 1, max: 100, name: "name")
    }
  }

  /// https://discord.com/developers/docs/resources/channel#overwrite-object
  public struct PartialChannelOverwrite: Sendable, Encodable {
    public var id: AnySnowflake
    public var type: DiscordChannel.Overwrite.Kind
    public var allow: StringBitField<Permission>?
    public var deny: StringBitField<Permission>?

    public init(
      id: AnySnowflake,
      type: DiscordChannel.Overwrite.Kind,
      allow: StringBitField<Permission>? = nil,
      deny: StringBitField<Permission>? = nil
    ) {
      self.id = id
      self.type = type
      self.allow = allow
      self.deny = deny
    }
  }

  /// https://discord.com/developers/docs/resources/channel#forum-tag-object-forum-tag-structure
  public struct PartialForumTag: Sendable, Encodable, ValidatablePayload {
    public var id: ForumTagSnowflake?
    public var name: String
    public var moderated: Bool?
    public var emoji_id: EmojiSnowflake?
    public var emoji_name: String?

    public init(
      id: ForumTagSnowflake? = nil,
      name: String,
      moderated: Bool? = nil,
      emoji_id: EmojiSnowflake? = nil
    ) {
      self.id = id
      self.name = name
      self.moderated = moderated
      self.emoji_id = emoji_id
    }

    public init(
      id: ForumTagSnowflake? = nil,
      name: String,
      moderated: Bool? = nil,
      emoji_name: String? = nil
    ) {
      self.id = id
      self.name = name
      self.moderated = moderated
      self.emoji_name = emoji_name
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 0, max: 20, name: "name")
    }
  }

  /// https://discord.com/developers/docs/resources/channel#modify-channel-json-params-guild-channel
  public struct ModifyGuildChannel: Sendable, Encodable, ValidatablePayload {
    public var name: String?
    public var type: DiscordChannel.Kind?
    public var position: Int?
    public var topic: String?
    public var nsfw: Bool?
    public var rate_limit_per_user: Int?
    public var bitrate: Int?
    public var user_limit: Int?
    public var permission_overwrites: [PartialChannelOverwrite]?
    public var parent_id: AnySnowflake?
    public var rtc_region: String?
    public var video_quality_mode: DiscordChannel.VideoQualityMode?
    public var default_auto_archive_duration: DiscordChannel.AutoArchiveDuration?
    public var flags: IntBitField<DiscordChannel.Flag>?
    public var available_tags: [PartialForumTag]?
    public var default_reaction_emoji: DiscordChannel.DefaultReaction?
    public var default_thread_rate_limit_per_user: Int?
    public var default_sort_order: DiscordChannel.SortOrder?
    public var default_forum_layout: DiscordChannel.ForumLayout?

    public init(
      name: String? = nil,
      type: DiscordChannel.Kind? = nil,
      position: Int? = nil,
      topic: String? = nil,
      nsfw: Bool? = nil,
      rate_limit_per_user: Int? = nil,
      bitrate: Int? = nil,
      user_limit: Int? = nil,
      permission_overwrites: [PartialChannelOverwrite]? = nil,
      parent_id: AnySnowflake? = nil,
      rtc_region: String? = nil,
      video_quality_mode: DiscordChannel.VideoQualityMode? = nil,
      default_auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil,
      flags: IntBitField<DiscordChannel.Flag>? = nil,
      available_tags: [PartialForumTag]? = nil,
      default_reaction_emoji: DiscordChannel.DefaultReaction? = nil,
      default_thread_rate_limit_per_user: Int? = nil,
      default_sort_order: DiscordChannel.SortOrder? = nil,
      default_forum_layout: DiscordChannel.ForumLayout? = nil
    ) {
      self.name = name
      self.type = type
      self.position = position
      self.topic = topic
      self.nsfw = nsfw
      self.rate_limit_per_user = rate_limit_per_user
      self.bitrate = bitrate
      self.user_limit = user_limit
      self.permission_overwrites = permission_overwrites
      self.parent_id = parent_id
      self.rtc_region = rtc_region
      self.video_quality_mode = video_quality_mode
      self.default_auto_archive_duration = default_auto_archive_duration
      self.flags = flags
      self.available_tags = available_tags
      self.default_reaction_emoji = default_reaction_emoji
      self.default_thread_rate_limit_per_user =
        default_thread_rate_limit_per_user
      self.default_sort_order = default_sort_order
      self.default_forum_layout = default_forum_layout
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRangeOrNil(name, min: 1, max: 100, name: "name")
      validateCharacterCountDoesNotExceed(topic, max: 4_096, name: "topic")
      validateNumberInRangeOrNil(
        rate_limit_per_user,
        min: 0,
        max: 21_600,
        name: "rate_limit_per_user"
      )
      validateNumberInRangeOrNil(
        bitrate,
        min: 8_000,
        max: 384_000,
        name: "bitrate"
      )
      validateNumberInRangeOrNil(
        user_limit,
        min: 0,
        max: 10_000,
        name: "user_limit"
      )
      validateOnlyContains(
        flags,
        name: "flags",
        reason: "Can only contain 'requireTag'",
        allowed: [.requireTag]
      )
      validateElementCountDoesNotExceed(
        available_tags,
        max: 20,
        name: "available_tags"
      )
      available_tags?.validate()
    }
  }

  /// https://discord.com/developers/docs/resources/channel#modify-channel-json-params-thread
  public struct ModifyThreadChannel: Sendable, Encodable, ValidatablePayload {
    public var name: String?
    public var archived: Bool?
    public var auto_archive_duration: DiscordChannel.AutoArchiveDuration?
    public var locked: Bool?
    public var invitable: Bool?
    public var rate_limit_per_user: Int?
    public var flags: IntBitField<DiscordChannel.Flag>?
    public var applied_tags: [PartialForumTag]?

    public init(
      name: String? = nil,
      archived: Bool? = nil,
      auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil,
      locked: Bool? = nil,
      invitable: Bool? = nil,
      rate_limit_per_user: Int? = nil,
      flags: IntBitField<DiscordChannel.Flag>? = nil,
      applied_tags: [PartialForumTag]? = nil
    ) {
      self.name = name
      self.archived = archived
      self.auto_archive_duration = auto_archive_duration
      self.locked = locked
      self.invitable = invitable
      self.rate_limit_per_user = rate_limit_per_user
      self.flags = flags
      self.applied_tags = applied_tags
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRangeOrNil(name, min: 1, max: 100, name: "name")
      validateNumberInRangeOrNil(
        rate_limit_per_user,
        min: 0,
        max: 21_600,
        name: "rate_limit_per_user"
      )
      validateOnlyContains(
        flags,
        name: "flags",
        reason: "Can only contain 'pinned'",
        allowed: [.pinned]
      )
      validateElementCountDoesNotExceed(
        applied_tags,
        max: 5,
        name: "applied_tags"
      )
      applied_tags?.validate()
    }
  }

  /// https://discord.com/developers/docs/resources/guild#create-guild-channel-json-params
  public struct CreateGuildChannel: Sendable, Encodable, ValidatablePayload {
    public var name: String
    public var type: DiscordChannel.Kind?
    public var position: Int?
    public var topic: String?
    public var nsfw: Bool?
    public var rate_limit_per_user: Int?
    public var bitrate: Int?
    public var user_limit: Int?
    public var permission_overwrites: [PartialChannelOverwrite]?
    public var parent_id: AnySnowflake?
    public var rtc_region: String?
    public var video_quality_mode: DiscordChannel.VideoQualityMode?
    public var default_auto_archive_duration: DiscordChannel.AutoArchiveDuration?
    public var available_tags: [PartialForumTag]?
    public var default_reaction_emoji: DiscordChannel.DefaultReaction?
    public var default_sort_order: DiscordChannel.SortOrder?
    public var default_forum_layout: DiscordChannel.ForumLayout?
    public var default_thread_rate_limit_per_user: Int?

    public init(
      name: String,
      type: DiscordChannel.Kind? = nil,
      position: Int? = nil,
      topic: String? = nil,
      nsfw: Bool? = nil,
      rate_limit_per_user: Int? = nil,
      bitrate: Int? = nil,
      user_limit: Int? = nil,
      permission_overwrites: [PartialChannelOverwrite]? = nil,
      parent_id: AnySnowflake? = nil,
      rtc_region: String? = nil,
      video_quality_mode: DiscordChannel.VideoQualityMode? = nil,
      default_auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil,
      available_tags: [PartialForumTag]? = nil,
      default_reaction_emoji: DiscordChannel.DefaultReaction? = nil,
      default_sort_order: DiscordChannel.SortOrder? = nil,
      default_forum_layout: DiscordChannel.ForumLayout? = nil,
      default_thread_rate_limit_per_user: Int? = nil
    ) {
      self.name = name
      self.type = type
      self.position = position
      self.topic = topic
      self.nsfw = nsfw
      self.rate_limit_per_user = rate_limit_per_user
      self.bitrate = bitrate
      self.user_limit = user_limit
      self.permission_overwrites = permission_overwrites
      self.parent_id = parent_id
      self.rtc_region = rtc_region
      self.video_quality_mode = video_quality_mode
      self.default_auto_archive_duration = default_auto_archive_duration
      self.available_tags = available_tags
      self.default_reaction_emoji = default_reaction_emoji
      self.default_sort_order = default_sort_order
      self.default_forum_layout = default_forum_layout
      self.default_thread_rate_limit_per_user =
        default_thread_rate_limit_per_user
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
      validateCharacterCountDoesNotExceed(topic, max: 4_096, name: "topic")
      validateNumberInRangeOrNil(
        rate_limit_per_user,
        min: 0,
        max: 21_600,
        name: "rate_limit_per_user"
      )
      validateNumberInRangeOrNil(
        bitrate,
        min: 8_000,
        max: 384_000,
        name: "bitrate"
      )
      validateNumberInRangeOrNil(
        user_limit,
        min: 0,
        max: 10_000,
        name: "user_limit"
      )
      validateElementCountDoesNotExceed(
        available_tags,
        max: 20,
        name: "available_tags"
      )
      available_tags?.validate()
    }
  }

  public struct CreateGuild: Sendable, Encodable, ValidatablePayload {
    public var name: String
    public var icon: ImageData?
    public var verification_level: Guild.VerificationLevel?
    public var default_message_notifications: Guild.DefaultMessageNotificationLevel?
    public var explicit_content_filter: Guild.ExplicitContentFilterLevel?
    public var roles: [Role]?
    public var channels: [DiscordChannel]?
    public var afk_channel_id: ChannelSnowflake?
    public var afk_timeout: Guild.AFKTimeout?
    public var system_channel_id: ChannelSnowflake?
    public var system_channel_flags: IntBitField<Guild.SystemChannelFlag>?

    public init(
      name: String,
      icon: ImageData? = nil,
      verification_level: Guild.VerificationLevel? = nil,
      default_message_notifications: Guild.DefaultMessageNotificationLevel? =
        nil,
      explicit_content_filter: Guild.ExplicitContentFilterLevel? = nil,
      roles: [Role]? = nil,
      channels: [DiscordChannel]? = nil,
      afk_channel_id: ChannelSnowflake? = nil,
      afk_timeout: Guild.AFKTimeout? = nil,
      system_channel_id: ChannelSnowflake? = nil,
      system_channel_flags: IntBitField<Guild.SystemChannelFlag>? = nil
    ) {
      self.name = name
      self.icon = icon
      self.verification_level = verification_level
      self.default_message_notifications = default_message_notifications
      self.explicit_content_filter = explicit_content_filter
      self.roles = roles
      self.channels = channels
      self.afk_channel_id = afk_channel_id
      self.afk_timeout = afk_timeout
      self.system_channel_id = system_channel_id
      self.system_channel_flags = system_channel_flags
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 2, max: 100, name: "name")
    }
  }

  public struct ModifyGuild: Sendable, Encodable, ValidatablePayload {
    public var name: String?
    public var verification_level: Guild.VerificationLevel?
    public var default_message_notifications: Guild.DefaultMessageNotificationLevel?
    public var explicit_content_filter: Guild.ExplicitContentFilterLevel?
    public var afk_channel_id: ChannelSnowflake?
    public var afk_timeout: Guild.AFKTimeout?
    public var icon: ImageData?
    public var owner_id: UserSnowflake?
    public var splash: ImageData?
    public var discovery_splash: ImageData?
    public var banner: ImageData?
    public var system_channel_id: ChannelSnowflake?
    public var system_channel_flags: IntBitField<Guild.SystemChannelFlag>?
    public var rules_channel_id: ChannelSnowflake?
    public var public_updates_channel_id: ChannelSnowflake?
    public var preferred_locale: DiscordLocale?
    public var features: [Guild.Feature]?
    public var description: String?
    public var premium_progress_bar_enabled: Bool?

    public init(
      name: String? = nil,
      verification_level: Guild.VerificationLevel? = nil,
      default_message_notifications: Guild.DefaultMessageNotificationLevel? =
        nil,
      explicit_content_filter: Guild.ExplicitContentFilterLevel? = nil,
      afk_channel_id: ChannelSnowflake? = nil,
      afk_timeout: Guild.AFKTimeout? = nil,
      icon: ImageData? = nil,
      owner_id: UserSnowflake? = nil,
      splash: ImageData? = nil,
      discovery_splash: ImageData? = nil,
      banner: ImageData? = nil,
      system_channel_id: ChannelSnowflake? = nil,
      system_channel_flags: IntBitField<Guild.SystemChannelFlag>? = nil,
      rules_channel_id: ChannelSnowflake? = nil,
      public_updates_channel_id: ChannelSnowflake? = nil,
      preferred_locale: DiscordLocale? = nil,
      features: [Guild.Feature]? = nil,
      description: String? = nil,
      premium_progress_bar_enabled: Bool? = nil
    ) {
      self.name = name
      self.verification_level = verification_level
      self.default_message_notifications = default_message_notifications
      self.explicit_content_filter = explicit_content_filter
      self.afk_channel_id = afk_channel_id
      self.afk_timeout = afk_timeout
      self.icon = icon
      self.owner_id = owner_id
      self.splash = splash
      self.discovery_splash = discovery_splash
      self.banner = banner
      self.system_channel_id = system_channel_id
      self.system_channel_flags = system_channel_flags
      self.rules_channel_id = rules_channel_id
      self.public_updates_channel_id = public_updates_channel_id
      self.preferred_locale = preferred_locale
      self.features = features
      self.description = description
      self.premium_progress_bar_enabled = premium_progress_bar_enabled
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 2, max: 100, name: "name")
    }
  }

  /// https://docs.discord.food/resources/auto-moderation#automod-trigger-metadata
  public struct AutoModTriggerMetadata: Sendable, Codable, ValidatablePayload {
    public var keyword_filter: [String]
    public var regex_patterns: [String]
    public var presets: [Int]
    public var allow_list: [String]
    public var mention_total_limit: Int
    public var mention_raid_protection_enabled: Bool

    public init(
      keyword_filter: [String],
      regex_patterns: [String],
      presets: [Int],
      allow_list: [String],
      mention_total_limit: Int,
      mention_raid_protection_enabled: Bool
    ) {
      self.keyword_filter = keyword_filter
      self.regex_patterns = regex_patterns
      self.presets = presets
      self.allow_list = allow_list
      self.mention_total_limit = mention_total_limit
      self.mention_raid_protection_enabled = mention_raid_protection_enabled
    }

    public func validate() -> [ValidationFailure] {
      validateElementCountDoesNotExceed(
        keyword_filter,
        max: 1000,
        name: "keyword_filter"
      )
      validateElementCountDoesNotExceed(
        regex_patterns,
        max: 10,
        name: "regex_patterns"
      )
      validateElementCountDoesNotExceed(
        allow_list,
        max: 1000,
        name: "allow_list"
      )
      validateHasPrecondition(
        condition: mention_total_limit <= 50,
        allowedIf: !mention_raid_protection_enabled,
        name: "mention_total_limit",
        reason:
          "'mention_total_limit' must be less than or equal to 50 when 'mention_raid_protection_enabled' is false"
      )
    }
  }

  /// https://docs.discord.food/resources/auto-moderation#execute-automod-alert-action
  public struct ExecuteAutoModAlertAction: Sendable, Codable, ValidatablePayload {
    public var channel_id: ChannelSnowflake
    public var message_id: MessageSnowflake
    public var alert_action_type: AlertActionKind

    public enum AlertActionKind: Int, Sendable, Codable {
      case setCompleted = 1
      case unsetCompleted = 2
      case deleteUserMessage = 3
      case submitFeedback = 4
    }

    public func validate() -> [ValidationFailure] {
    }
  }

  /// https://discord.com/developers/docs/resources/auto-moderation#create-auto-moderation-rule-json-params
  public struct CreateAutoModerationRule: Sendable, Codable, ValidatablePayload {
    public var name: String
    public var event_type: AutoModerationRule.EventKind
    public var trigger_type: AutoModerationRule.TriggerKind
    public var trigger_metadata: AutoModerationRule.TriggerMetadata?
    public var actions: [AutoModerationRule.Action]
    public var enabled: Bool?
    public var exempt_roles: [RoleSnowflake]?
    public var exempt_channels: [ChannelSnowflake]?

    public init(
      name: String,
      event_type: AutoModerationRule.EventKind,
      trigger_type: AutoModerationRule.TriggerKind,
      trigger_metadata: AutoModerationRule.TriggerMetadata? = nil,
      actions: [AutoModerationRule.Action],
      enabled: Bool? = nil,
      exempt_roles: [RoleSnowflake]? = nil,
      exempt_channels: [ChannelSnowflake]? = nil
    ) {
      self.name = name
      self.event_type = event_type
      self.trigger_type = trigger_type
      self.trigger_metadata = trigger_metadata
      self.actions = actions
      self.enabled = enabled
      self.exempt_roles = exempt_roles
      self.exempt_channels = exempt_channels
    }

    public func validate() -> [ValidationFailure] {
      validateElementCountDoesNotExceed(
        exempt_roles,
        max: 50,
        name: "exempt_roles"
      )
      validateElementCountDoesNotExceed(
        exempt_channels,
        max: 50,
        name: "exempt_channels"
      )
    }
  }

  /// https://discord.com/developers/docs/resources/auto-moderation#modify-auto-moderation-rule
  public struct ModifyAutoModerationRule: Sendable, Codable, ValidatablePayload {
    public var name: String?
    public var event_type: AutoModerationRule.EventKind?
    public var trigger_type: AutoModerationRule.TriggerKind?
    public var trigger_metadata: AutoModerationRule.TriggerMetadata?
    public var actions: [AutoModerationRule.Action]?
    public var enabled: Bool?
    public var exempt_roles: [RoleSnowflake]?
    public var exempt_channels: [ChannelSnowflake]?

    public init(
      name: String? = nil,
      event_type: AutoModerationRule.EventKind? = nil,
      trigger_type: AutoModerationRule.TriggerKind? = nil,
      trigger_metadata: AutoModerationRule.TriggerMetadata? = nil,
      actions: [AutoModerationRule.Action]? = nil,
      enabled: Bool? = nil,
      exempt_roles: [RoleSnowflake]? = nil,
      exempt_channels: [ChannelSnowflake]? = nil
    ) {
      self.name = name
      self.event_type = event_type
      self.trigger_type = trigger_type
      self.trigger_metadata = trigger_metadata
      self.actions = actions
      self.enabled = enabled
      self.exempt_roles = exempt_roles
      self.exempt_channels = exempt_channels
    }

    public func validate() -> [ValidationFailure] {
      validateElementCountDoesNotExceed(
        exempt_roles,
        max: 50,
        name: "exempt_roles"
      )
      validateElementCountDoesNotExceed(
        exempt_channels,
        max: 50,
        name: "exempt_channels"
      )
    }
  }

  /// https://discord.com/developers/docs/resources/channel#bulk-delete-messages-json-params
  public struct BulkDeleteMessages: Sendable, Codable, ValidatablePayload {
    public var messages: [MessageSnowflake]

    public init(messages: [MessageSnowflake]) {
      self.messages = messages
    }

    public func validate() -> [ValidationFailure] {
      validateElementCountInRange(messages, min: 2, max: 100, name: "messages")
    }
  }

  /// https://discord.com/developers/docs/resources/channel#edit-channel-permissions-json-params
  public struct EditChannelPermissions: Sendable, Codable, ValidatablePayload {
    public var type: DiscordChannel.Overwrite.Kind
    public var allow: StringBitField<Permission>?
    public var deny: StringBitField<Permission>?

    public init(
      type: DiscordChannel.Overwrite.Kind,
      allow: StringBitField<Permission>? = nil,
      deny: StringBitField<Permission>? = nil
    ) {
      self.type = type
      self.allow = allow
      self.deny = deny
    }

    public func validate() -> [ValidationFailure] {}
  }

  public enum Count: Sendable, Encodable, ExpressibleByIntegerLiteral {
    case unlimited
    case count(Int)

    public init(integerLiteral value: Int) {
      if value == 0 {
        self = .unlimited
      } else {
        self = .count(value)
      }
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .unlimited:
        try container.encode(0)
      case .count(let count):
        try container.encode(count)
      }
    }
  }

  /// https://discord.com/developers/docs/resources/channel#create-channel-invite-json-params
  public struct CreateChannelInvite: Sendable, Encodable, ValidatablePayload {
    public var max_age: Count?
    public var max_uses: Count?
    public var temporary: Bool?
    public var unique: Bool?
    public var target_type: Invite.TargetKind?
    public var target_user_id: UserSnowflake?
    public var target_application_id: ApplicationSnowflake?

    public init(
      max_age: Count? = nil,
      max_uses: Count? = nil,
      temporary: Bool? = nil,
      unique: Bool? = nil,
      target_type: Invite.TargetKind? = nil,
      target_user_id: UserSnowflake? = nil,
      target_application_id: ApplicationSnowflake? = nil
    ) {
      self.max_age = max_age
      self.max_uses = max_uses
      self.temporary = temporary
      self.unique = unique
      self.target_type = target_type
      self.target_user_id = target_user_id
      self.target_application_id = target_application_id
    }

    public func validate() -> [ValidationFailure] {
      switch max_age {
      case .unlimited, .none:
        Optional<ValidationFailure>.none
      case .count(let count):
        validateNumberInRangeOrNil(count, min: 0, max: 604_800, name: "max_age")
      }
      switch max_uses {
      case .unlimited, .none:
        Optional<ValidationFailure>.none
      case .count(let count):
        validateNumberInRangeOrNil(count, min: 0, max: 100, name: "max_uses")
      }
      if target_type == .stream {
        validateHasPrecondition(
          condition: target_user_id != nil,
          allowedIf: target_type == .stream,
          name: "target_user_id",
          reason:
            "'target_user_id' & 'target_type == .stream' require each other"
        )
      }
      if target_type == .embeddedApplication {
        validateHasPrecondition(
          condition: target_application_id != nil,
          allowedIf: target_type == .embeddedApplication,
          name: "target_user_id",
          reason:
            "'target_application_id' & 'target_type == .embeddedApplication' require each other"
        )
      }
    }
  }

  /// https://discord.com/developers/docs/resources/channel#follow-announcement-channel-json-params
  public struct FollowAnnouncementChannel: Sendable, Encodable,
    ValidatablePayload
  {
    public var webhook_channel_id: ChannelSnowflake

    public init(webhook_channel_id: ChannelSnowflake) {
      self.webhook_channel_id = webhook_channel_id
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/channel#group-dm-add-recipient-json-params
  public struct AddGroupDMUser: Sendable, Encodable, ValidatablePayload {
    public var access_token: String
    public var nick: String

    public init(access_token: String, nick: String) {
      self.access_token = access_token
      self.nick = nick
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/emoji#create-guild-emoji-json-params
  public struct CreateGuildEmoji: Sendable, Encodable, ValidatablePayload {
    public var name: String
    public var image: ImageData
    public var roles: [RoleSnowflake]

    public init(name: String, image: ImageData, roles: [RoleSnowflake]) {
      self.name = name
      self.image = image
      self.roles = roles
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/emoji#create-application-emoji-json-params
  public struct CreateApplicationEmoji: Sendable, Encodable, ValidatablePayload {
    public var name: String
    public var image: ImageData

    public init(name: String, image: ImageData) {
      self.name = name
      self.image = image
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/emoji#create-guild-emoji-json-params
  public struct ModifyGuildEmoji: Sendable, Encodable, ValidatablePayload {
    public var name: String
    public var roles: [RoleSnowflake]

    public init(name: String, roles: [RoleSnowflake]) {
      self.name = name
      self.roles = roles
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/emoji#modify-application-emoji-json-params
  public struct ModifyApplicationEmoji: Sendable, Encodable, ValidatablePayload {
    public var name: String

    public init(name: String) {
      self.name = name
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild#modify-guild-channel-positions-json-params
  public struct ModifyGuildChannelPositions: Sendable, Encodable,
    ValidatablePayload
  {
    public var id: ChannelSnowflake
    public var position: Int?
    public var lock_permissions: Bool?
    public var parent_id: ChannelSnowflake?

    public init(
      id: ChannelSnowflake,
      position: Int? = nil,
      lock_permissions: Bool? = nil,
      parent_id: ChannelSnowflake? = nil
    ) {
      self.id = id
      self.position = position
      self.lock_permissions = lock_permissions
      self.parent_id = parent_id
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild#add-guild-member-json-params
  public struct AddGuildMember: Sendable, Encodable, ValidatablePayload {
    public var access_token: String
    public var nick: String?
    public var roles: [RoleSnowflake]?
    public var mute: Bool?
    public var deaf: Bool?

    public init(
      access_token: String,
      nick: String? = nil,
      roles: [RoleSnowflake]? = nil,
      mute: Bool? = nil,
      deaf: Bool? = nil
    ) {
      self.access_token = access_token
      self.nick = nick
      self.roles = roles
      self.mute = mute
      self.deaf = deaf
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild#modify-guild-member-json-params
  public struct ModifyGuildMember: Sendable, Encodable, ValidatablePayload {
    public var nick: String?
    public var roles: [RoleSnowflake]?
    public var mute: Bool?
    public var deaf: Bool?
    public var channel_id: ChannelSnowflake?
    public var communication_disabled_until: DiscordTimestamp?
    public var flags: IntBitField<Guild.Member.Flag>?

    public init(
      nick: String? = nil,
      roles: [RoleSnowflake]? = nil,
      mute: Bool? = nil,
      deaf: Bool? = nil,
      channel_id: ChannelSnowflake? = nil,
      communication_disabled_until: DiscordTimestamp? = nil,
      flags: IntBitField<Guild.Member.Flag>? = nil
    ) {
      self.nick = nick
      self.roles = roles
      self.mute = mute
      self.deaf = deaf
      self.channel_id = channel_id
      self.communication_disabled_until = communication_disabled_until
      self.flags = flags
    }

    public func validate() -> [ValidationFailure] {
      let now = Date().timeIntervalSince1970
      validateNumberInRangeOrNil(
        communication_disabled_until?.date.timeIntervalSince1970,
        min: now,
        max: now + (28 * 24 * 60 * 60),
        name: "communication_disabled_until.date.timeIntervalSince1970"
      )
    }
  }

  /// https://discord.com/developers/docs/resources/guild#modify-current-member-json-params
  public struct ModifyCurrentMember: Sendable, Encodable, ValidatablePayload {
    public var nick: String?

    public init(nick: String? = nil) {
      self.nick = nick
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild#create-guild-ban-json-params
  public struct CreateGuildBan: Sendable, Encodable, ValidatablePayload {
    public var delete_message_seconds: Int?

    public init(delete_message_seconds: Int? = nil) {
      self.delete_message_seconds = delete_message_seconds
    }

    public func validate() -> [ValidationFailure] {
      validateNumberInRangeOrNil(
        delete_message_seconds,
        min: 0,
        max: 604_800,
        name: "delete_message_seconds"
      )
    }
  }

  /// https://discord.com/developers/docs/resources/guild#bulk-guild-ban-json-params
  public struct CreateBulkGuildBan: Sendable, Encodable, ValidatablePayload {
    public var user_ids: [UserSnowflake]
    public var delete_message_seconds: Int?

    public init(user_ids: [UserSnowflake], delete_message_seconds: Int? = nil) {
      self.user_ids = user_ids
      self.delete_message_seconds = delete_message_seconds
    }

    public func validate() -> [ValidationFailure] {
      validateElementCountInRange(user_ids, min: 1, max: 200, name: "user_ids")
      validateNumberInRangeOrNil(
        delete_message_seconds,
        min: 0,
        max: 604_800,
        name: "delete_message_seconds"
      )
    }
  }

  /// https://discord.com/developers/docs/resources/guild#create-guild-role-json-params
  /// https://discord.com/developers/docs/resources/guild#modify-guild-role-json-params
  public struct GuildRole: Sendable, Codable, ValidatablePayload {
    public var name: String?
    public var permissions: StringBitField<Permission>?
    public var color: DiscordColor?
    public var hoist: Bool?
    public var icon: ImageData?
    public var unicode_emoji: String?
    public var mentionable: Bool?

    /// `icon` and `unicode_emoji` require `roleIcons` guild feature,
    /// which most guild don't have.
    /// No fields are required. If you send an empty payload, you'll get a basic role
    /// with a name like "new role".
    public init(
      name: String? = nil,
      permissions: StringBitField<Permission>? = nil,
      color: DiscordColor? = nil,
      hoist: Bool? = nil,
      icon: ImageData? = nil,
      unicode_emoji: String? = nil,
      mentionable: Bool? = nil
    ) {
      self.name = name
      self.permissions = permissions
      self.color = color
      self.hoist = hoist
      self.icon = icon
      self.unicode_emoji = unicode_emoji
      self.mentionable = mentionable
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountDoesNotExceed(name, max: 1_000, name: "name")
    }
  }

  /// https://discord.com/developers/docs/resources/guild#modify-guild-role-positions-json-params
  public struct ModifyGuildRolePositions: Sendable, Encodable,
    ValidatablePayload
  {
    public var id: RoleSnowflake
    public var position: Int?

    public init(id: RoleSnowflake, position: Int? = nil) {
      self.id = id
      self.position = position
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild#modify-guild-mfa-level-json-params
  public struct ModifyGuildMFALevel: Sendable, Encodable, ValidatablePayload {
    public var level: Guild.MFALevel

    public init(level: Guild.MFALevel) {
      self.level = level
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild#begin-guild-prune-json-params
  public struct BeginGuildPrune: Sendable, Encodable, ValidatablePayload {
    public var days: Int
    public var compute_prune_count: Bool
    public var include_roles: [RoleSnowflake]

    public init(
      days: Int,
      compute_prune_count: Bool,
      include_roles: [RoleSnowflake]
    ) {
      self.days = days
      self.compute_prune_count = compute_prune_count
      self.include_roles = include_roles
    }

    public func validate() -> [ValidationFailure] {
      validateNumberInRangeOrNil(days, min: 1, max: 30, name: "days")
    }
  }

  /// https://discord.com/developers/docs/resources/guild#get-guild-widget-image-widget-style-options
  /// Cases show sizes from small to big.
  /// See Discord docs for examples.
  public enum WidgetStyle: String, Sendable {
    case shield = "small"
    case banner1 = "banner1"
    case banner2 = "banner2"
    case banner3 = "banner3"
    case banner4 = "banner4"

    public static let `default`: WidgetStyle = .shield
  }

  /// https://discord.com/developers/docs/resources/guild#modify-guild-widget
  public struct ModifyWidgetSettings: Sendable, Encodable, ValidatablePayload {
    public var enabled: Bool?
    public var channel_id: ChannelSnowflake?

    public init(enabled: Bool? = nil, channel_id: ChannelSnowflake? = nil) {
      self.enabled = enabled
      self.channel_id = channel_id
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild#modify-guild-welcome-screen-json-params
  public struct ModifyGuildWelcomeScreen: Sendable, Encodable,
    ValidatablePayload
  {
    public var enabled: Bool?
    public var welcome_channels: [Guild.WelcomeScreen.Channel]?
    public var description: String?

    public init(
      enabled: Bool? = nil,
      welcome_channels: [Guild.WelcomeScreen.Channel]? = nil,
      description: String? = nil
    ) {
      self.enabled = enabled
      self.welcome_channels = welcome_channels
      self.description = description
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild#modify-current-user-voice-state-json-params
  public struct ModifyCurrentUserVoiceState: Sendable, Encodable,
    ValidatablePayload
  {
    public var channel_id: ChannelSnowflake?
    public var suppress: Bool?
    public var request_to_speak_timestamp: DiscordTimestamp?

    public init(
      channel_id: ChannelSnowflake? = nil,
      suppress: Bool? = nil,
      request_to_speak_timestamp: DiscordTimestamp? = nil
    ) {
      self.channel_id = channel_id
      self.suppress = suppress
      self.request_to_speak_timestamp = request_to_speak_timestamp
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild#modify-user-voice-state-json-params
  public struct ModifyUserVoiceState: Sendable, Encodable, ValidatablePayload {
    public var channel_id: ChannelSnowflake?
    public var suppress: Bool?

    public init(channel_id: ChannelSnowflake? = nil, suppress: Bool? = nil) {
      self.channel_id = channel_id
      self.suppress = suppress
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild-scheduled-event#create-guild-scheduled-event-json-params
  public struct CreateGuildScheduledEvent: Sendable, Encodable,
    ValidatablePayload
  {
    public var channel_id: ChannelSnowflake?
    public var entity_metadata: GuildScheduledEvent.EntityMetadata?
    public var name: String
    public var privacy_level: GuildScheduledEvent.PrivacyLevel
    public var scheduled_start_time: DiscordTimestamp
    public var scheduled_end_time: DiscordTimestamp?
    public var description: String?
    public var entity_type: GuildScheduledEvent.EntityKind
    public var image: ImageData?
    public var recurrence_rule: GuildScheduledEvent.RecurrenceRule?

    public init(
      channel_id: ChannelSnowflake? = nil,
      entity_metadata: GuildScheduledEvent.EntityMetadata? = nil,
      name: String,
      privacy_level: GuildScheduledEvent.PrivacyLevel,
      scheduled_start_time: DiscordTimestamp,
      scheduled_end_time: DiscordTimestamp? = nil,
      description: String? = nil,
      entity_type: GuildScheduledEvent.EntityKind,
      image: ImageData? = nil,
      recurrence_rule: GuildScheduledEvent.RecurrenceRule? = nil
    ) {
      self.channel_id = channel_id
      self.entity_metadata = entity_metadata
      self.name = name
      self.privacy_level = privacy_level
      self.scheduled_start_time = scheduled_start_time
      self.scheduled_end_time = scheduled_end_time
      self.description = description
      self.entity_type = entity_type
      self.image = image
      self.recurrence_rule = recurrence_rule
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild-scheduled-event#modify-guild-scheduled-event-json-params
  public struct ModifyGuildScheduledEvent: Sendable, Encodable,
    ValidatablePayload
  {
    public var channel_id: ChannelSnowflake?
    public var entity_metadata: GuildScheduledEvent.EntityMetadata?
    public var name: String?
    public var privacy_level: GuildScheduledEvent.PrivacyLevel?
    public var scheduled_start_time: DiscordTimestamp?
    public var scheduled_end_time: DiscordTimestamp?
    public var description: String?
    public var entity_type: GuildScheduledEvent.EntityKind?
    public var status: GuildScheduledEvent.Status?
    public var image: ImageData?
    public var recurrence_rule: GuildScheduledEvent.RecurrenceRule?

    public init(
      channel_id: ChannelSnowflake? = nil,
      entity_metadata: GuildScheduledEvent.EntityMetadata? = nil,
      name: String? = nil,
      privacy_level: GuildScheduledEvent.PrivacyLevel? = nil,
      scheduled_start_time: DiscordTimestamp? = nil,
      scheduled_end_time: DiscordTimestamp? = nil,
      description: String? = nil,
      entity_type: GuildScheduledEvent.EntityKind? = nil,
      status: GuildScheduledEvent.Status? = nil,
      image: ImageData? = nil,
      recurrence_rule: GuildScheduledEvent.RecurrenceRule? = nil
    ) {
      self.channel_id = channel_id
      self.entity_metadata = entity_metadata
      self.name = name
      self.privacy_level = privacy_level
      self.scheduled_start_time = scheduled_start_time
      self.scheduled_end_time = scheduled_end_time
      self.description = description
      self.entity_type = entity_type
      self.status = status
      self.image = image
      self.recurrence_rule = recurrence_rule
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/guild-template#create-guild-from-guild-template-json-params
  public struct CreateGuildFromGuildTemplate: Sendable, Encodable,
    ValidatablePayload
  {
    public var name: String
    public var icon: ImageData?

    public init(name: String, icon: ImageData? = nil) {
      self.name = name
      self.icon = icon
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 2, max: 100, name: "name")
    }
  }

  /// https://discord.com/developers/docs/resources/guild-template#create-guild-template-json-params
  public struct CreateGuildTemplate: Sendable, Encodable, ValidatablePayload {
    public var name: String
    public var description: String?

    public init(name: String, description: String? = nil) {
      self.name = name
      self.description = description
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
      validateCharacterCountDoesNotExceed(
        description,
        max: 120,
        name: "description"
      )
    }
  }

  /// https://discord.com/developers/docs/resources/guild-template#modify-guild-template-json-params
  public struct ModifyGuildTemplate: Sendable, Encodable, ValidatablePayload {
    public var name: String?
    public var description: String?

    public init(name: String? = nil, description: String? = nil) {
      self.name = name
      self.description = description
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
      validateCharacterCountDoesNotExceed(
        description,
        max: 120,
        name: "description"
      )
    }
  }

  /// https://discord.com/developers/docs/resources/stage-instance#create-stage-instance-json-params
  public struct CreateStageInstance: Sendable, Encodable, ValidatablePayload {
    public var channel_id: ChannelSnowflake
    public var topic: String
    public var privacy_level: StageInstance.PrivacyLevel?
    public var send_start_notification: Bool?
    public var guild_scheduled_event_id: GuildScheduledEventSnowflake?

    public init(
      channel_id: ChannelSnowflake,
      topic: String,
      privacy_level: StageInstance.PrivacyLevel? = nil,
      send_start_notification: Bool? = nil,
      guild_scheduled_event_id: GuildScheduledEventSnowflake? = nil
    ) {
      self.channel_id = channel_id
      self.topic = topic
      self.privacy_level = privacy_level
      self.send_start_notification = send_start_notification
      self.guild_scheduled_event_id = guild_scheduled_event_id
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(topic, min: 1, max: 120, name: "topic")
    }
  }

  /// https://discord.com/developers/docs/resources/stage-instance#modify-stage-instance-json-params
  public struct ModifyStageInstance: Sendable, Encodable, ValidatablePayload {
    public var topic: String?
    public var privacy_level: StageInstance.PrivacyLevel?

    public init(
      topic: String? = nil,
      privacy_level: StageInstance.PrivacyLevel? = nil
    ) {
      self.topic = topic
      self.privacy_level = privacy_level
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRangeOrNil(topic, min: 1, max: 120, name: "topic")
    }
  }

  /// https://discord.com/developers/docs/resources/sticker#create-guild-sticker-form-params
  public struct CreateGuildSticker: Sendable, Encodable, MultipartEncodable,
    ValidatablePayload
  {
    public var name: String
    public var description: String
    public var tags: String
    public var file: RawFile

    public static var rawEncodable: Bool { true }
    public var files: [RawFile]? {
      [self.file]
    }

    public init(name: String, description: String, tags: String, file: RawFile) {
      self.name = name
      self.description = description
      self.tags = tags
      self.file = file
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 2, max: 30, name: "name")
      validateCharacterCountInRangeOrNil(
        description,
        min: 2,
        max: 100,
        name: "description"
      )
      validateCharacterCountDoesNotExceed(tags, max: 200, name: "tags")
    }
  }

  /// https://discord.com/developers/docs/resources/sticker#modify-guild-sticker-json-params
  public struct ModifyGuildSticker: Sendable, Encodable, ValidatablePayload {
    public var name: String?
    public var description: String?
    public var tags: String?

    public init(
      name: String? = nil,
      description: String? = nil,
      tags: String? = nil
    ) {
      self.name = name
      self.description = description
      self.tags = tags
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(name, min: 2, max: 30, name: "name")
      validateCharacterCountInRangeOrNil(
        description,
        min: 2,
        max: 100,
        name: "description"
      )
      validateCharacterCountDoesNotExceed(tags, max: 200, name: "tags")
    }
  }

  /// https://discord.com/developers/docs/resources/user#modify-current-user-json-params
  public struct ModifyCurrentUser: Sendable, Encodable, ValidatablePayload {
    public var username: String?
    public var avatar: ImageData?
    public var banner: ImageData?

    public init(
      username: String? = nil,
      avatar: ImageData? = nil,
      banner: ImageData? = nil
    ) {
      self.username = username
      self.avatar = avatar
      self.banner = banner
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/user#create-dm-json-params
  /// https://discord.com/developers/docs/resources/user#create-group-dm-json-params
  /// https://docs.discord.food/resources/channel#json-params
  public struct CreateDM: Sendable, Encodable, ValidatablePayload {
    //    public var recipient_id: UserSnowflake? // deprecated
    public var recipients: [UserSnowflake]?

    @inlinable
    public init(recipient: UserSnowflake) {
      self.recipients = [recipient]
    }

    @inlinable
    public init(recipients: [UserSnowflake]) {
      self.recipients = recipients
    }

    public func validate() -> [ValidationFailure] {
      if let recipients {
        validateElementCountInRange(
          recipients,
          min: 1,
          max: 10,
          name: "recipients"
        )
      }
    }
  }

  //  public struct CreateGroupDM: Sendable, Encodable, ValidatablePayload {
  //    public var recipients: [UserSnowflake]
  //
  //    public init(recipients: [UserSnowflake]) {
  //      self.recipients = recipients
  //    }
  //
  //    public func validate() -> [ValidationFailure] {}
  //  }

  /// https://discord.com/developers/docs/resources/user#update-user-application-role-connection-json-params
  public struct UpdateUserApplicationRoleConnection: Sendable, Encodable,
    ValidatablePayload
  {
    public var platform_name: String?
    public var platform_username: String?
    public var metadata: [String: ApplicationRoleConnectionMetadata]?

    public init(
      platform_name: String? = nil,
      platform_username: String? = nil,
      metadata: [ApplicationRoleConnectionMetadata]? = nil
    ) {
      self.platform_name = platform_name
      self.platform_username = platform_username
      self.metadata = metadata.map { meta in
        Dictionary(
          meta.map({ ($0.key, $0) }),
          uniquingKeysWith: { l, _ in l }
        )
      }
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountDoesNotExceed(
        platform_name,
        max: 50,
        name: "platform_name"
      )
      validateCharacterCountDoesNotExceed(
        platform_username,
        max: 100,
        name: "platform_username"
      )
    }
  }

  /// https://discord.com/developers/docs/resources/guild#modify-guild-onboarding-json-params
  public struct UpdateGuildOnboarding: Sendable, Encodable, ValidatablePayload {
    public var prompts: [Guild.Onboarding.Prompt]?
    public var default_channel_ids: [ChannelSnowflake]?
    public var enabled: Bool?
    public var mode: Guild.Onboarding.Mode?

    public init(
      prompts: [Guild.Onboarding.Prompt]? = nil,
      default_channel_ids: [ChannelSnowflake]? = nil,
      enabled: Bool? = nil,
      mode: Guild.Onboarding.Mode? = nil
    ) {
      self.prompts = prompts
      self.default_channel_ids = default_channel_ids
      self.enabled = enabled
      self.mode = mode
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/monetization/entitlements#create-test-entitlement-json-params
  public struct CreateTestEntitlement: Sendable, Encodable, ValidatablePayload {

    public enum OwnerKind: Int, Sendable, Codable {
      case guildSubscription = 1
      case userSubscription = 2
    }

    public var sku_id: SKUSnowflake
    public var owner_id: AnySnowflake
    public var owner_type: OwnerKind

    public init(sku_id: SKUSnowflake, owner_id: GuildSnowflake) {
      self.sku_id = sku_id
      self.owner_id = AnySnowflake(owner_id)
      self.owner_type = .guildSubscription
    }

    public init(sku_id: SKUSnowflake, owner_id: UserSnowflake) {
      self.sku_id = sku_id
      self.owner_id = AnySnowflake(owner_id)
      self.owner_type = .userSubscription
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://discord.com/developers/docs/resources/application#edit-current-application-json-params
  public struct UpdateOwnApplication: Sendable, Encodable, ValidatablePayload {
    public var custom_install_url: String?
    public var description: String?
    public var role_connections_verification_url: String?
    public var install_params: DiscordApplication.InstallParams?
    public var integration_types_config:
      [DiscordApplication.IntegrationKind: DiscordApplication
        .IntegrationKindConfiguration]?
    public var flags: IntBitField<DiscordApplication.Flag>?
    public var icon: ImageData?
    public var cover_image: ImageData?
    public var interactions_endpoint_url: String?
    public var tags: [String]?

    public init(
      custom_install_url: String? = nil,
      description: String? = nil,
      role_connections_verification_url: String? = nil,
      install_params: DiscordApplication.InstallParams? = nil,
      integration_types_config: [DiscordApplication.IntegrationKind:
        DiscordApplication
        .IntegrationKindConfiguration]? = nil,
      flags: IntBitField<DiscordApplication.Flag>? = nil,
      icon: ImageData? = nil,
      cover_image: ImageData? = nil,
      interactions_endpoint_url: String? = nil,
      tags: [String]? = nil
    ) {
      self.custom_install_url = custom_install_url
      self.description = description
      self.role_connections_verification_url = role_connections_verification_url
      self.install_params = install_params
      self.flags = flags
      self.icon = icon
      self.cover_image = cover_image
      self.interactions_endpoint_url = interactions_endpoint_url
      self.tags = tags
    }

    public func validate() -> [ValidationFailure] {
      validateOnlyContains(
        flags,
        name: "flags",
        reason:
          "Can only contain 'gatewayPresenceLimited', 'gatewayGuildMembersLimited' and 'gatewayMessageContentLimited'",
        allowed: [
          .gatewayPresenceLimited,
          .gatewayGuildMembersLimited,
          .gatewayMessageContentLimited,
        ]
      )
      validateElementCountDoesNotExceed(tags, max: 5, name: "tags")
      for (idx, tag) in (tags ?? []).enumerated() {
        validateCharacterCountDoesNotExceed(tag, max: 20, name: "tags[\(idx)]")
      }
    }
  }

  /// https://discord.com/developers/docs/resources/poll#poll-create-request-object
  public struct CreatePollRequest: Sendable, Codable, Hashable,
    ValidatablePayload
  {
    public var question: Poll.Media
    public var answers: [Poll.Answer]
    /// "Number of hours the poll should be open for, up to 32 days"
    public var duration: Int
    public var allow_multiselect: Bool
    public var layout_type: Poll.LayoutKind?

    public init(
      question: Poll.Media,
      answers: [Poll.Answer],
      duration: Int,
      allow_multiselect: Bool,
      layout_type: Poll.LayoutKind? = nil
    ) {
      self.question = question
      self.answers = answers
      self.duration = duration
      self.allow_multiselect = allow_multiselect
      self.layout_type = layout_type
    }

    public func validate() -> [ValidationFailure] {
      question.validate()
      answers.map(\.poll_media).validate()
      validateElementCountDoesNotExceed(answers, max: 10, name: "answers")
      validateNumberInRangeOrNil(duration, min: 1, max: 768, name: "duration")/// 32 days max
    }
  }

  /// https://docs.discord.food/resources/relationships#send-friend-request
  public struct SendFriendRequest: Sendable, Encodable, ValidatablePayload {
    public var username: String
    public var discriminator: String?  // nil for migrated users

    public init(username: String, discriminator: String? = nil) {
      self.username = username
      self.discriminator = discriminator
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(username, min: 2, max: 32, name: "username")
      if let discriminator {
        validateCharacterCountInRange(
          discriminator,
          min: 4,
          max: 4,
          name: "discriminator"
        )
      }
    }
  }

  /// https://docs.discord.food/resources/relationships#create-relationship
  public struct CreateRelationship: Sendable, Encodable, ValidatablePayload {
    public var type: DiscordRelationship.Kind?
    public var from_friend_suggestion: Bool?

    public init(
      type: DiscordRelationship.Kind?,
      from_friend_suggestion: Bool? = nil
    ) {
      self.type = type
      self.from_friend_suggestion = from_friend_suggestion
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://docs.discord.food/resources/relationships#modify-relationship
  public struct ModifyRelationship: Sendable, Encodable, ValidatablePayload {
    public var nickname: String?

    public init(nickname: String?) {
      self.nickname = nickname
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRangeOrNil(
        nickname,
        min: 1,
        max: 32,
        name: "nickname"
      )
    }
  }

  /// https://docs.discord.food/resources/relationships#bulk-remove-relationships
  public struct BulkRemoveRelationships: Sendable, Encodable, ValidatablePayload {
    public var filters: Set<Filter>?
    public init(filters: Set<Filter>? = nil) {
      self.filters = filters
    }
    public func validate() -> [ValidationFailure] {}

    public enum Filter: Int, Sendable, Codable {
      case spam = 1
      case ignored = 2
    }
  }

  /// https://docs.discord.food/resources/relationships#bulk-add-relationships
  public struct BulkAddRelationships: Sendable, Encodable, ValidatablePayload {
    public var user_ids: [UserSnowflake]
    public var token: String  // contact sync is the only way to bulk add. contact sync token required.
    public init(user_ids: [UserSnowflake], token: String) {
      self.user_ids = user_ids
      self.token = token
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://docs.discord.food/resources/soundboard#send-soundboard-sound
  public struct SendSoundboardSound: Sendable, Encodable, ValidatablePayload {
    public var sound_id: SoundSnowflake
    public var source_guild_id: GuildSnowflake?

    public init(
      sound_id: SoundSnowflake,
      source_guild_id: GuildSnowflake? = nil
    ) {
      self.sound_id = sound_id
      self.source_guild_id = source_guild_id
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://docs.discord.food/resources/invite#accept-invite
  public struct AcceptInvite: Sendable, Encodable, ValidatablePayload {
    public var session_id: String?

    public init(session_id: String? = nil) {
      self.session_id = session_id
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://docs.discord.food/resources/invite#create-user-invite
  public struct CreateUserInvite: Sendable, Encodable, ValidatablePayload {
    public var code: String?

    public init(code: String? = nil) {
      self.code = code
    }

    public func validate() -> [ValidationFailure] {}
  }

  /// https://docs.discord.food/interactions/receiving-and-responding#create-interaction
  public struct CreateInteraction: Sendable, Encodable, ValidatablePayload {
    public var type: Interaction.Kind
    public var application_id: ApplicationSnowflake
    public var guild_id: GuildSnowflake?
    public var channel_id: ChannelSnowflake
    public var message_id: MessageSnowflake?  // Only for MESSAGE_COMPONENT type
    public var message_flags: IntBitField<DiscordChannel.Message.Flag>?  // Only for MESSAGE_COMPONENT type
    public var session_id: String?  // Required so Discord can send send accompanying interaction events
    public var data: Interaction.Data
    public var files: [RawFile]?
    public var nonce: StringOrInt?
    //    public var analytics_location
    public var section_name: String?
    //    public var source

    public func validate() -> [ValidationFailure] {
      // TODO: validate fields here
    }

    init(
      type: Interaction.Kind,
      application_id: ApplicationSnowflake,
      guild_id: GuildSnowflake? = nil,
      channel_id: ChannelSnowflake,
      message_id: MessageSnowflake? = nil,
      message_flags: IntBitField<DiscordChannel.Message.Flag>? = nil,
      session_id: String? = nil,
      files: [RawFile]? = nil,
      nonce: StringOrInt? = nil,
      section_name: String? = nil,
      data: Interaction.Data
    ) {
      self.type = type
      self.application_id = application_id
      self.guild_id = guild_id
      self.channel_id = channel_id
      self.message_id = message_id
      self.message_flags = message_flags
      self.session_id = session_id
      self.files = files
      self.nonce = nonce
      self.section_name = section_name
      self.data = data
    }

    enum CodingKeys: String, CodingKey {
      case type
      case application_id
      case guild_id
      case channel_id
      case message_id
      case message_flags
      case data
      case session_id
      case files
      case nonce
      case section_name
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(type, forKey: .type)
      try container.encode(application_id, forKey: .application_id)
      try container.encodeIfPresent(guild_id, forKey: .guild_id)
      try container.encode(channel_id, forKey: .channel_id)
      try container.encodeIfPresent(message_id, forKey: .message_id)
      try container.encodeIfPresent(message_flags, forKey: .message_flags)
      try container.encodeIfPresent(session_id, forKey: .session_id)
      try container.encodeIfPresent(nonce, forKey: .nonce)
      try container.encodeIfPresent(section_name, forKey: .section_name)
      try container.encodeIfPresent(files, forKey: .files)

      switch data {
      case .applicationCommand(let applicationCommand):
        try container.encode(applicationCommand, forKey: .data)
      case .messageComponent(let messageComponent):
        try container.encode(messageComponent, forKey: .data)
      case .modalSubmit(let modalSubmit):
        try container.encode(modalSubmit, forKey: .data)
      }
    }
  }

  /// https://docs.discord.food/resources/message#create-attachments
  public struct CreateAttachments: Sendable, Encodable, ValidatablePayload {
    public var files: [UploadAttachment]

    public init(files: [UploadAttachment]) {
      self.files = files
    }

    public func validate() -> [ValidationFailure] {}

    public struct UploadAttachment: Sendable, Encodable {
      public var id: AttachmentSnowflake?
      public var filename: String
      public var file_size: Int

      public init(
        id: AttachmentSnowflake? = nil,
        filename: String,
        file_size: Int
      ) {
        self.id = id
        self.filename = filename
        self.file_size = file_size
      }
    }
  }

  /// https://docs.discord.food/remote-authentication/mobile#create-remote-auth-session
  public struct CreateRemoteAuthSession: Sendable, Encodable, ValidatablePayload {
    public var fingerprint: String

    public init(fingerprint: String) {
      self.fingerprint = fingerprint
    }
    public func validate() -> [ValidationFailure] {}
  }

  /// https://docs.discord.food/remote-authentication/mobile#finish-remote-auth
  public struct RemoteAuthSession: Sendable, Encodable, ValidatablePayload {
    public var handshake_token: String
    /// Unsupported as of writing.
    public var temporary_token: Bool?

    public init(handshake_token: String, temporary_token: Bool? = nil) {
      self.handshake_token = handshake_token
      self.temporary_token = temporary_token
    }

    public func validate() -> [ValidationFailure] {}
  }

  public struct ExchangeRemoteAuthTicket: Sendable, Encodable,
    ValidatablePayload
  {
    public var ticket: String

    public init(ticket: String) {
      self.ticket = ticket
    }

    public func validate() -> [ValidationFailure] {}
  }
}
