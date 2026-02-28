import PaicordLib

extension DiscordLocaleRust {
    init(locale: DiscordLocale) {
        switch locale {
        case .danish:
            self = .Danish
        case .german:
            self = .German
        case .englishUK:
            self = .EnglishUK
        case .englishUS:
            self = .EnglishUS
        case .spanish:
            self = .Spanish
        case .french:
            self = .French
        case .croatian:
            self = .Croatian
        case .italian:
            self = .Italian
        case .lithuanian:
            self = .Lithuanian
        case .hungarian:
            self = .Hungarian
        case .dutch:
            self = .Dutch
        case .norwegian:
            self = .Norwegian
        case .polish:
            self = .Polish
        case .portuguese:
            self = .Portuguese
        case .romanian:
            self = .Romanian
        case .finnish:
            self = .Finnish
        case .swedish:
            self = .Swedish
        case .vietnamese:
            self = .Vietnamese
        case .turkish:
            self = .Turkish
        case .czech:
            self = .Czech
        case .greek:
            self = .Greek
        case .bulgarian:
            self = .Bulgarian
        case .russian:
            self = .Russian
        case .ukrainian:
            self = .Ukrainian
        case .hindi:
            self = .Hindi
        case .thai:
            self = .Thai
        case .chineseChina:
            self = .ChineseChina
        case .japanese:
            self = .Japanese
        case .chineseTaiwan:
            self = .ChineseTaiwan
        case .korean:
            self = .Korean
        case .__undocumented(let inner):
            self = .Undocumented(inner.intoRustString())
        }
    }
}

extension DiscordColorRust {
    init(color: DiscordColor) {
        self.inner = Int32(color.value)
    }
}

extension DiscordTimestampRust {
    init(timestamp: DiscordTimestamp) {
        self.inner = timestamp.date.timeIntervalSince1970
    }
}