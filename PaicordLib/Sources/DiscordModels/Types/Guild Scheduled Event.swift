/// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object
public struct GuildScheduledEvent: Sendable, Codable, ValidatablePayload {

  /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-privacy-level
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum PrivacyLevel: Sendable, Codable {
    case guildOnly  // 2
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-status
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum Status: Sendable, Codable {
    case scheduled  // 1
    case active  // 2
    case completed  // 3
    case canceled  // 4
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-entity-types
  #if Non64BitSystemsCompatibility
    @UnstableEnum<Int64>
  #else
    @UnstableEnum<Int>
  #endif
  public enum EntityKind: Sendable, Codable {
    case stageInstance  // 1
    case voice  // 2
    case external  // 3
    #if Non64BitSystemsCompatibility
      case __undocumented(Int64)
    #else
      case __undocumented(Int)
    #endif
  }

  /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-entity-metadata
  public struct EntityMetadata: Sendable, Codable, ValidatablePayload {
    public var location: String?

    public init(location: String? = nil) {
      self.location = location
    }

    public func validate() -> [ValidationFailure] {
      validateCharacterCountInRange(
        location,
        min: 1,
        max: 100,
        name: "location"
      )
    }
  }

  /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-recurrence-rule-object-guild-scheduled-event-recurrence-rule-structure
  public struct RecurrenceRule: Sendable, Codable {

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-recurrence-rule-object-guild-scheduled-event-recurrence-rule-frequency
    #if Non64BitSystemsCompatibility
      @UnstableEnum<Int64>
    #else
      @UnstableEnum<Int>
    #endif
    public enum Frequency: Sendable, Codable {
      case yearly  // 0
      case monthly  // 1
      case weekly  // 2
      case daily  // 3
      #if Non64BitSystemsCompatibility
        case __undocumented(Int64)
      #else
        case __undocumented(Int)
      #endif
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-recurrence-rule-object-guild-scheduled-event-recurrence-rule-weekday
    #if Non64BitSystemsCompatibility
      @UnstableEnum<Int64>
    #else
      @UnstableEnum<Int>
    #endif
    public enum Weekday: Sendable, Codable {
      case monday  // 0
      case tuesday  // 1
      case wednesday  // 2
      case thursday  // 3
      case friday  // 4
      case saturday  // 5
      case sunday  // 6
      #if Non64BitSystemsCompatibility
        case __undocumented(Int64)
      #else
        case __undocumented(Int)
      #endif
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-recurrence-rule-object-guild-scheduled-event-recurrence-rule-weekday
    public enum WeekdaySet: Sendable, Codable {
      case mondayToFriday
      case tuesdayToSaturday
      case sundayToThursday
      case fridayAndSaturday
      case saturdayAndSunday
      case sundayAndMonday
      case __DO_NOT_USE_THIS_CASE

      public func toWeekdays() -> [Weekday] {
        switch self {
        case .mondayToFriday:
          return [.monday, .tuesday, .wednesday, .thursday, .friday]
        case .tuesdayToSaturday:
          return [.tuesday, .wednesday, .thursday, .friday, .saturday]
        case .sundayToThursday:
          return [.sunday, .monday, .tuesday, .wednesday, .thursday]
        case .fridayAndSaturday:
          return [.friday, .saturday]
        case .saturdayAndSunday:
          return [.saturday, .sunday]
        case .sundayAndMonday:
          return [.sunday, .monday]
        case .__DO_NOT_USE_THIS_CASE:
          fatalError(
            "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
          )
        }
      }
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-recurrence-rule-object-guild-scheduled-event-recurrence-rule-nweekday-structure
    public struct NWeekday: Sendable, Codable {
      public var n: Int
      public var day: Weekday

      public init(n: Int, day: Weekday) {
        self.n = n
        self.day = day
      }
    }

    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-recurrence-rule-object-guild-scheduled-event-recurrence-rule-month
    #if Non64BitSystemsCompatibility
      @UnstableEnum<Int64>
    #else
      @UnstableEnum<Int>
    #endif
    public enum Month: Sendable, Codable {
      case january  // 1
      case february  // 2
      case march  // 3
      case april  // 4
      case may  // 5
      case june  // 6
      case july  // 7
      case august  // 8
      case september  // 9
      case october  // 10
      case november  // 11
      case december  // 12
      #if Non64BitSystemsCompatibility
        case __undocumented(Int64)
      #else
        case __undocumented(Int)
      #endif
    }

    public var start: DiscordTimestamp
    public var end: DiscordTimestamp?
    public var frequency: Frequency
    public var interval: Int
    public var by_weekday: [Weekday]?
    public var by_n_weekday: [NWeekday]?
    public var by_month: [Month]?
    public var by_month_day: [Int]?
    public var by_year_day: [Int]?
    public var count: Int?

    init(
      start: DiscordTimestamp,
      frequency: Frequency,
      interval: Int,
      by_weekday: [Weekday]? = nil,
      by_n_weekday: [NWeekday]? = nil,
      by_month: [Month]? = nil,
      by_month_day: [Int]? = nil
    ) {
      self.start = start
      self.end = nil
      self.frequency = frequency
      self.interval = interval
      self.by_weekday = by_weekday
      self.by_n_weekday = by_n_weekday
      self.by_month = by_month
      self.by_month_day = by_month_day
      self.by_year_day = nil
      self.count = nil
    }

    public static func dailyByWeekday(
      start: DiscordTimestamp,
      interval: Int,
      weekdays: WeekdaySet
    ) -> Self {
      self.init(
        start: start,
        frequency: .daily,
        interval: interval,
        by_weekday: weekdays.toWeekdays()
      )
    }

    /// Interval can only be set to a value other than 1.
    public static func weeklyByWeekday(
      start: DiscordTimestamp,
      interval: Int,
      weekday: Weekday
    ) -> Self {
      self.init(
        start: start,
        frequency: .weekly,
        interval: interval,
        by_weekday: [weekday]
      )
    }

    public static func monthlyByNWeekday(
      start: DiscordTimestamp,
      interval: Int,
      nWeekday: NWeekday
    ) -> Self {
      self.init(
        start: start,
        frequency: .monthly,
        interval: interval,
        by_n_weekday: [nWeekday]
      )
    }

    public static func yearlyByMonth(
      start: DiscordTimestamp,
      interval: Int,
      month: Month,
      monthDay: Int
    ) -> Self {
      self.init(
        start: start,
        frequency: .yearly,
        interval: interval,
        by_month: [month],
        by_month_day: [monthDay]
      )
    }
  }

  public var id: GuildScheduledEventSnowflake
  public var guild_id: GuildSnowflake
  public var channel_id: ChannelSnowflake?
  public var creator_id: UserSnowflake?
  public var name: String
  public var description: String?
  public var scheduled_start_time: DiscordTimestamp
  public var scheduled_end_time: DiscordTimestamp?
  public var privacy_level: PrivacyLevel
  public var status: Status
  public var entity_type: EntityKind
  // FIXME: use `Snowflake<Type>` instead
  public var entity_id: AnySnowflake?
  public var entity_metadata: EntityMetadata?
  public var creator: DiscordUser?
  public var user_count: Int?
  public var image: String?
  public var recurrence_rule: RecurrenceRule?
  /// Only for Gateway `guildScheduledEventUserAdd` events.
  public var user_ids: [UserSnowflake]?

  public func validate() -> [ValidationFailure] {
    validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
    validateCharacterCountInRange(
      description,
      min: 1,
      max: 100,
      name: "description"
    )
    entity_metadata?.validate()
  }
}

extension GuildScheduledEvent {
  /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-user-object-guild-scheduled-event-user-structure
  public struct User: Sendable, Codable {
    public var guild_scheduled_event_id: GuildScheduledEventSnowflake
    public var user: DiscordUser
    public var member: Guild.Member?
  }
}

public struct GuildScheduledEventException: Sendable, Codable {
  public var event_id: GuildScheduledEventSnowflake
  public var event_exception_id: GuildScheduledEventExceptionSnowflake
  public var is_canceled: Bool
  public var scheduled_start_time: DiscordTimestamp?
  public var scheduled_end_time: DiscordTimestamp?
}
