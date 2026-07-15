//
//  EmojiPicker.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 30/01/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftEmojiIndex
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

#if os(macOS)
  import AppKit
#endif

/// This is meant to be used in a Popover/Sheet. It provides an emoji picker, GIF picker, and sticker picker.
struct EmojiPicker: View {
  // Properties
  @Environment(\.gateway) var gw
  @Environment(\.userInterfaceIdiom) var deviceIdiom
  var forcedStyle: UserInterfaceIdiom? = nil
  var idiom: UserInterfaceIdiom {
    forcedStyle ?? deviceIdiom
  }

  var onEmojiPicked: ((DiscordModels.Emoji) -> Void)? = nil
  var onGIFPicked: ((String) -> Void)? = nil
  var onStickerPicked: ((Sticker) -> Void)? = nil
  var allowsShiftToKeepOpen: Bool = true

  // State
  @State var chosenPicker: ChosenPicker = .emoji
  // only ios uses detents. macos uses popovers and has different layouts
  @StateOrBinding var detent: PresentationDetent

  init(detent: Binding<PresentationDetent>? = nil) {
    self._detent = .init(detent, initialValue: .medium)
  }

  var body: some View {
    switch idiom {
    case .pad, .mac:
      popoverLayout
        .frame(width: 500, height: 485)
    default:
      #if os(iOS)
        sheetLayout
      #else
        EmptyView()
      #endif
    }
  }

  @Namespace var namespace

  // Platform Layouts
  @ViewBuilder
  var popoverLayout: some View {
    VStack {
      HStack {
        Button("GIFS") {
          self.chosenPicker = .gif
        }
        .buttonStyle(.plain)
        .padding(.small)
        .background {
          if chosenPicker == .gif {
            Color.gray.opacity(0.1)
              .clipShape(.rounded)
              .matchedGeometryEffect(
                id: "pickerHighlight",
                in: namespace,
                properties: .frame,
                anchor: .bottomLeading
              )
          }
        }

        Button("Stickers") {
          self.chosenPicker = .sticker
        }
        .buttonStyle(.plain)
        .padding(.small)
        .background {
          if chosenPicker == .sticker {
            Color.gray.opacity(0.1)
              .clipShape(.rounded)
              .matchedGeometryEffect(
                id: "pickerHighlight",
                in: namespace,
                properties: .frame,
                anchor: .bottomLeading
              )
          }
        }

        Button("Emojis") {
          self.chosenPicker = .emoji
        }
        .buttonStyle(.plain)
        .padding(.small)
        .background {
          if chosenPicker == .emoji {
            Color.gray.opacity(0.1)
              .clipShape(.rounded)
              .matchedGeometryEffect(
                id: "pickerHighlight",
                in: namespace,
                properties: .frame,
                anchor: .bottomLeading
              )
          }
        }

        Spacer()
      }
      .fontWeight(.semibold)
      .animation(
        .interactiveSpring(
          response: 2,
          dampingFraction: 0.6,
          blendDuration: 0.2
        )
        .speed(5.0),
        value: chosenPicker
      )

      // pickers content
      VStack(spacing: 0) {
        switch chosenPicker {
        case .emoji:
          EmojiGridView(
            onEmojiPicked: onEmojiPicked,
            allowsShiftToKeepOpen: allowsShiftToKeepOpen
          )
        case .gif:
          GifGridView { gifURL in
            onGIFPicked?(gifURL)
          }
        case .sticker:
          StickerGridView { sticker in
            onStickerPicked?(sticker)
          }
        }
      }
    }
    .padding()
  }

  /// An emoji as displayed in the picker grid, either a guild custom emoji or a unicode emoji.
  enum PickerEmoji: Identifiable, Hashable {
    // discord emoji and source guild
    case custom(DiscordModels.Emoji, guildID: GuildSnowflake)
    // unicode emoji and discord name
    case unicode(SwiftEmojiIndex.Emoji, String)

    var id: String {
      switch self {
      case .custom(let emoji, let guildID):
        return
          "custom_\(guildID.rawValue)_\(emoji.id?.rawValue ?? emoji.name ?? "")"
      case .unicode(let emoji, _):
        return "unicode_\(emoji.character)"
      }
    }

    var name: String {
      switch self {
      case .custom(let emoji, _): return emoji.name ?? ""
      case .unicode(_, let name): return name
      }
    }

    func toDiscordEmoji() -> DiscordModels.Emoji {
      switch self {
      case .custom(let emoji, _): return emoji
      case .unicode(let emoji, _):
        return DiscordModels.Emoji(name: emoji.character)
      }
    }
  }

  enum EmojiPickerSection: Equatable, Hashable, Identifiable {
    case favourites
    case frequents  // "frecency"
    case top  // top in a guild (if in a guild)
    case guild(GuildSnowflake)
    case unicodeCategory(EmojiCategory)

    var id: String {
      switch self {
      case .favourites:
        return "favourites"
      case .frequents:
        return "frequents"
      case .top:
        return "top"
      case .guild(let guildID):
        return "guild_\(guildID.rawValue)"
      case .unicodeCategory(let category):
        return "unicode_\(category.rawValue)"
      }
    }
  }

  struct EmojiGridView: View {
    @Environment(\.gateway) var gw
    @Environment(\.dismiss) var dismiss
    var onEmojiPicked: ((DiscordModels.Emoji) -> Void)?
    var allowsShiftToKeepOpen: Bool = true

    enum FocusTarget: Hashable {
      case search
      case grid
    }

    @State private var searchText = ""
    @State private var searchResults: [PickerEmoji] = []
    @State private var highlightedIndex = 0
    @State private var highlightMovedByKeyboard = false
    #if os(macOS)
      @State private var lastHoverMouseLocation: CGPoint?
    #endif

    @State private var scrollPosition: String?
    @FocusState private var focus: FocusTarget?

    @State private var cachedGridSections: [GridSection] = []
    @State private var cachedRenderSections: [RenderSection] = []

    private let columnCount = 8
    private var gridColumns: [GridItem] {
      Array(repeating: GridItem(.flexible(), spacing: 4), count: columnCount)
    }

    var body: some View {
      VStack {
        searchField
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            guildBar
            gridScrollView
              .maxWidth(.infinity)
          }
          highlightedPreview
            .maxWidth(.infinity)
            .height(50)
            .background(.black.opacity(0.2))
        }
        .padding([.horizontal, .bottom], -15)
      }
      .task {
        try? await EmojiIndexProvider.shared.load()
        rebuildGridSections()
      }
      .onAppear {
        focus = .search
        rebuildGridSections()
      }
      .onChange(of: gw.user.emojis) { _, _ in rebuildGridSections() }
      .onChange(of: gw.settings.frecencySettings) { _, _ in rebuildGridSections() }
      .onChange(of: searchText) { _, newValue in
        highlightedIndex = 0
        Task { await performSearch(newValue) }
      }
      .onChange(of: flatItems.count) { _, newCount in
        highlightedIndex = min(highlightedIndex, max(0, newCount - 1))
      }
    }

    @ViewBuilder
    var searchField: some View {
      HStack {
        Image(systemName: "magnifyingglass")
          .foregroundStyle(.secondary)
        TextField("Find the perfect emoji", text: $searchText)
          .textFieldStyle(.plain)
          .focused($focus, equals: .search)
          .onKeyPress { handleKeyPress($0) }
      }
      .padding(8)
      .background(.black.opacity(0.15))
      .clipShape(.rounded)
    }

    @ViewBuilder
    var gridScrollView: some View {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 4) {
            if searchText.isEmpty {
              ForEach(cachedRenderSections) { rs in
                LazyVStack(alignment: .leading, spacing: 4) {
                  sectionHeader(rs.section.section)
                  LazyVGrid(columns: gridColumns, spacing: 4) {
                    ForEach(Array(rs.section.items.enumerated()), id: \.offset) {
                      (i, item) in
                      emojiButton(item, flatIndex: rs.startIndex + i)
                    }
                  }
                }
                .id(rs.section.id)
              }
            } else {
              LazyVGrid(columns: gridColumns, spacing: 4) {
                ForEach(Array(searchResults.enumerated()), id: \.offset) {
                  (i, item) in
                  emojiButton(item, flatIndex: i)
                }
              }
            }
          }
          .scrollTargetLayout()
          .padding(8)
        }
        .scrollPosition(id: $scrollPosition, anchor: .top)
        .focusable()
        .focusEffectDisabled()
        .focused($focus, equals: .grid)
        .onKeyPress { handleKeyPress($0) }
        .onChange(of: highlightedIndex) { _, newValue in
          guard highlightMovedByKeyboard else { return }
          highlightMovedByKeyboard = false
          guard flatItems.indices.contains(newValue) else { return }
          withAnimation {
            proxy.scrollTo(newValue, anchor: .center)
          }
        }
      }
    }

    @ViewBuilder
    func emojiButton(_ item: PickerEmoji, flatIndex: Int) -> some View {
      Button {
        highlightedIndex = flatIndex
        pick(item, shiftHeld: currentShiftHeld())
      } label: {
        emojiCell(item)
          .frame(width: 38, height: 38)
          .padding(2)
          .background(
            flatIndex == highlightedIndex
              ? Color.accentColor.opacity(0.3) : Color.clear
          )
          .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
      }
      .buttonStyle(.plain)
      .id(flatIndex)
      .onHover { hovering in
        guard hovering else { return }
        #if os(macOS)
          let location = NSEvent.mouseLocation
          if let last = lastHoverMouseLocation, last == location {
            // focus with arrow keys gets messed up when you
            // leave mouse cursor over grid, often crashes the app
            return
          }
          lastHoverMouseLocation = location
        #endif
        highlightedIndex = flatIndex
      }
    }

    @ViewBuilder
    func emojiCell(_ item: PickerEmoji) -> some View {
      switch item {
      case .custom(let emoji, _):
        if let url = customEmojiURL(id: emoji.id, animated: emoji.animated) {
          WebImage(url: url)
            .resizable()
            .scaledToFit()
        }
      case .unicode(let emoji, _):
        Text(emoji.character)
          .font(.system(size: 30))
          .minimumScaleFactor(0.1)
      }
    }

    func customEmojiURL(id: EmojiSnowflake?, animated: Bool?) -> URL? {
      guard let id else { return nil }
      return URL(
        string: CDNEndpoint.customEmoji(emojiId: id).url
          + ".\((animated ?? false) ? "gif" : "png")?size=64&animated=\((animated ?? false).description)"
      )
    }

    @ViewBuilder
    var highlightedPreview: some View {
      HStack(spacing: 4) {
        if let item = flatItems[safe: highlightedIndex] {
          emojiCell(item)
            .width(38)
            .padding([.leading, .vertical], 12)
          VStack(alignment: .leading) {
            Text(verbatim: ":\(item.name):")
              .font(.title3.bold())
              .lineLimit(1)

            if case .custom(_, let guild) = item,
              let guild = gw.user.guilds[guild]
            {
              Text("from ") + Text(verbatim: guild.name).bold()
            }
          }
          
          Spacer()
          if case .custom(_, let guildID) = item,
            let guild = gw.user.guilds[guildID]
          {
            guildButton(from: guild, shape: .rounded)
              .frame(width: 38, height: 38)
              .padding(.trailing, 6)
          }
        }
      }
    }
    
    @ViewBuilder
    var guildBar: some View {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack {
            ForEach(scrollbarSections) { section in
              Button {
                withAnimation {
                  scrollPosition = section.id
                }
              } label: {
                Group {
                  switch section {
                  case .favourites:
                    Color.clear
                      .overlay {
                        Image(systemName: "star.fill")
                          .font(.system(size: 24))
                      }
                  case .frequents:
                    Color.clear
                      .overlay {
                        Image(systemName: "clock.fill")
                          .font(.system(size: 24))
                      }
                  case .top:
                    Color.clear
                      .overlay {
                        Image(systemName: "trophy.fill")
                          .font(.system(size: 24))
                      }
                  case .unicodeCategory(let category):
                    Color.clear
                      .overlay {
                        Image(systemName: category.symbolName)
                          .font(.system(size: 24))
                      }
                  case .guild(let id):
                    if let guild = gw.user.guilds[id] {
                      guildButton(
                        from: guild,
                        shape: scrollPosition == section.id ? .rounded : .circle
                      )
                    } else {
                      Circle()
                    }
                  }
                }
                .foregroundStyle(scrollPosition == section.id ? .primary : .secondary)
                .scaledToFit()
                .aspectRatio(1, contentMode: .fit)
              }
              .buttonStyle(.borderless)
              .padding(.horizontal, .small)
              .id(section.id)
            }
          }
        }
        .width(50)
        .background(.black.opacity(0.2))
        .scrollIndicators(.never)
        .onChange(of: scrollPosition) { _, newValue in
          guard let newValue else { return }
          withAnimation {
            proxy.scrollTo(newValue, anchor: .center)
          }
        }
      }
    }

    func guildButton(from guild: Guild, shape: any Shape = .circle) -> some View {
      Group {
        if let icon = guild.icon,
          let url = iconURL(id: guild.id, icon: icon, animated: false)
        {
          WebImage(url: url)
            .resizable()
            .scaledToFill()
            .clipShape(AnyShape(shape))
        } else {
          Rectangle()
            .fill(.clear)
            .aspectRatio(1, contentMode: .fit)
            .background(.gray.opacity(0.3))
            .overlay {
              // get initials from guild name
              let initials = guild.name
                .split(separator: " ")
                .compactMap(\.first)
                .reduce("") { $0 + String($1) }

              Text(initials)
                .font(.title2)
                .minimumScaleFactor(0.1)
                .foregroundStyle(.primary)
            }
            .clipShape(AnyShape(shape))
        }
      }
    }

    func iconURL(id: GuildSnowflake, icon: String, animated: Bool) -> URL? {
      if icon.starts(with: "a_") {
        return URL(
          string: CDNEndpoint.guildIcon(guildId: id, icon: icon).url
            + ".\(animated ? "gif" : "png")?size=128&animated=\(animated.description)"
        )
      } else {
        return URL(
          string: CDNEndpoint.guildIcon(guildId: id, icon: icon).url
            + ".png?size=128&animated=false"
        )
      }
    }

    struct GridSection: Identifiable {
      let section: EmojiPickerSection
      let items: [PickerEmoji]
      var id: String { section.id }
    }

    struct RenderSection: Identifiable {
      let section: GridSection
      let startIndex: Int
      var id: String { section.id }
    }

    var orderedGuildIDs: [GuildSnowflake] {
      var guilds: [GuildSnowflake] = []
      if let userID = gw.user.currentUser?.id {
        let unlistedGuilds = gw.user.guilds.values.filter { guild in
          !gw.settings.userSettings.guildFolders.folders.contains { folder in
            folder.guildIds.contains(where: {
              $0.description == guild.id.rawValue
            })
          }
        }.sorted(by: { a, b in
          let aMember = gw.user.guilds[a.id]?.members?.first(where: {
            $0.user?.id == userID
          })
          let bMember = gw.user.guilds[b.id]?.members?.first(where: {
            $0.user?.id == userID
          })
          return (bMember?.joined_at ?? .init(date: .now))
            < (aMember?.joined_at ?? .init(date: .now))
        })
        guilds.append(contentsOf: unlistedGuilds.map(\.id))
      }
      guilds.append(
        contentsOf: gw.settings.userSettings.guildFolders.folders.flatMap(
          \.guildIds
        ).map { GuildSnowflake($0) }
      )
      return guilds
    }

    func computeGuildSections() -> [(GuildSnowflake, [PickerEmoji])] {
      orderedGuildIDs.compactMap { guildID in
        guard let emojis = gw.user.emojis[guildID], !emojis.isEmpty else {
          return nil
        }
        let items =
          emojis.values
          .filter { $0.available ?? true }
          .sorted { ($0.name ?? "") < ($1.name ?? "") }
          .map { PickerEmoji.custom($0, guildID: guildID) }
        return items.isEmpty ? nil : (guildID, items)
      }
    }

    func computeUnicodeSections() -> [(EmojiCategory, [PickerEmoji])] {
      EmojiCategory.allCases.compactMap {
        category -> (EmojiCategory, [PickerEmoji])? in
        guard
          let emojis = EmojiIndexProvider.shared.currentCategories[category],
          !emojis.isEmpty
        else { return nil }
        return (
          category,
          emojis.map {
            PickerEmoji.unicode(
              $0,
              DiscordEmojiNameIndex.names(for: $0.character)?.first
                ?? $0.name.replacingOccurrences(of: " ", with: "_")
            )
          }
        )
      }
    }

    var favouriteEmojis: [PickerEmoji] {
      guard gw.settings.frecencySettings.hasFavoriteEmojis else { return [] }
      return gw.settings.frecencySettings.favoriteEmojis.emojis.compactMap {
        resolveFrecencyEmoji($0)
      }
    }

    var frequentEmojis: [PickerEmoji] {
      guard gw.settings.frecencySettings.hasEmojiFrecency else { return [] }
      return gw.settings.frecencySettings.emojiFrecency.emojis
        .sorted { $0.value.score > $1.value.score }
        .compactMap { resolveFrecencyEmoji($0.key) }
    }

    func resolveFrecencyEmoji(_ raw: String) -> PickerEmoji? {
      if !raw.isEmpty, raw.allSatisfy(\.isNumber) {
        let id = EmojiSnowflake(raw)
        for (guildID, emojis) in gw.user.emojis {
          if let emoji = emojis[id] {
            return .custom(emoji, guildID: guildID)
          }
        }
        return nil
      } else if let character = DiscordEmojiNameIndex.character(forName: raw) {
        return .unicode(.init(character), raw)
      }
      return nil
    }

    func rebuildGridSections() {
      var result: [GridSection] = []
      let favourites = favouriteEmojis
      if !favourites.isEmpty {
        result.append(.init(section: .favourites, items: favourites))
      }
      let frequents = frequentEmojis
      if !frequents.isEmpty {
        result.append(.init(section: .frequents, items: frequents))
      }
      for (guildID, items) in computeGuildSections() {
        result.append(.init(section: .guild(guildID), items: items))
      }
      for (category, items) in computeUnicodeSections() {
        result.append(.init(section: .unicodeCategory(category), items: items))
      }
      cachedGridSections = result

      var running = 0
      var rendered: [RenderSection] = []
      for section in result {
        rendered.append(.init(section: section, startIndex: running))
        running += section.items.count
      }
      cachedRenderSections = rendered
    }
    
    var scrollbarSections: [EmojiPickerSection] {
      var result: [EmojiPickerSection] = []
      if !favouriteEmojis.isEmpty {
        result.append(.favourites)
      }
      if !frequentEmojis.isEmpty {
        result.append(.frequents)
      }
      result.append(
        contentsOf: cachedGridSections.compactMap { section in
          if case .guild = section.section { return section.section }
          return nil
        }
      )
      result.append(
        contentsOf: EmojiCategory.allCases.map { .unicodeCategory($0) }
      )
      return result
    }

    var flatItems: [PickerEmoji] {
      searchText.isEmpty ? cachedGridSections.flatMap(\.items) : searchResults
    }

    @MainActor
    func performSearch(_ query: String) async {
      guard !query.isEmpty else {
        searchResults = []
        return
      }
      let lower = query.lowercased()
      let customMatches = computeGuildSections().flatMap(\.1).filter { item in
        if case .custom = item {
          return item.name.lowercased().contains(lower)
        }
        return false
      }
      let unicodeMatches = await EmojiIndexProvider.shared.search(query)
        .map {
          PickerEmoji.unicode(
            $0,
            DiscordEmojiNameIndex.names(for: $0.character)?.first
              ?? $0.name.replacingOccurrences(of: " ", with: "_")
          )
        }
      guard !Task.isCancelled, query == searchText else { return }
      searchResults = customMatches + unicodeMatches
    }

    func sectionHeader(_ section: EmojiPickerSection) -> some View {
      Text(sectionTitle(section))
        .font(.caption)
        .fontWeight(.bold)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }

    func sectionTitle(_ section: EmojiPickerSection) -> String {
      switch section {
      case .favourites: return "Favourites"
      case .frequents: return "Frequently Used"
      case .top: return "Top in Server"
      case .guild(let id): return gw.user.guilds[id]?.name ?? "Unknown Server"
      case .unicodeCategory(let category): return category.displayName
      }
    }

    // MARK: Selection

    func pick(_ item: PickerEmoji, shiftHeld: Bool) {
      onEmojiPicked?(item.toDiscordEmoji())
      if !(allowsShiftToKeepOpen && shiftHeld) {
        dismiss()
      }
    }

    func currentShiftHeld() -> Bool {
      #if os(macOS)
        return NSEvent.modifierFlags.contains(.shift)
      #else
        return false
      #endif
    }

    func handleKeyPress(_ keyPress: KeyPress) -> KeyPress.Result {
      switch keyPress.key {
      case .escape:
        dismiss()
        return .handled
      case .return:
        selectHighlighted(shiftHeld: keyPress.modifiers.contains(.shift))
        return .handled
      case .upArrow:
        moveHighlight(by: -columnCount)
        return .handled
      case .downArrow:
        moveHighlight(by: columnCount)
        return .handled
      case .leftArrow:
        moveHighlight(by: -1)
        return .handled
      case .rightArrow:
        moveHighlight(by: 1)
        return .handled
      default:
        if focus == .grid,
          let characters = keyPress.characters.isEmpty
            ? nil : keyPress.characters,
          keyPress.modifiers.isDisjoint(with: [.command, .control, .option])
        {
          searchText += characters
          focus = .search
          return .handled
        }
        return .ignored
      }
    }

    func moveHighlight(by delta: Int) {
      focus = .grid
      guard !flatItems.isEmpty else { return }
      let newIndex = min(max(highlightedIndex + delta, 0), flatItems.count - 1)
      guard newIndex != highlightedIndex else { return }
      highlightMovedByKeyboard = true
      highlightedIndex = newIndex
    }

    func selectHighlighted(shiftHeld: Bool) {
      guard let item = flatItems[safe: highlightedIndex] else { return }
      pick(item, shiftHeld: shiftHeld)
    }
  }

  struct GifGridView: View {
    var onGIFPicked: (String) -> Void
    @State private var searchText = ""
    var body: some View {
      VStack {
        SearchBar("Search Tenor", text: $searchText)
        ScrollView {
          LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 8),
            spacing: 12
          ) {
            Text("GIF Picker Coming Soon!")
          }
        }
      }
    }
  }

  struct StickerGridView: View {
    var onStickerPicked: (Sticker) -> Void
    @State private var searchText = ""
    var body: some View {
      VStack {
        SearchBar("Find the perfect Sticker", text: $searchText)
        ScrollView {
          LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 8),
            spacing: 12
          ) {
            Text("Sticker Picker Coming Soon!")
          }
        }
      }
    }
  }

  #if os(iOS)
    @ViewBuilder
    var sheetLayout: some View {
      VStack(spacing: 0) {
        Picker("", selection: $chosenPicker) {
          Text("Emojis").tag(ChosenPicker.emoji)
          Text("GIFS").tag(ChosenPicker.gif)
          Text("Stickers").tag(ChosenPicker.sticker)
        }
        .pickerStyle(.segmented)
        .padding([.top, .horizontal], 8)
        .padding(.top, 7)
        .padding(.bottom, detent == .large ? 0 : 8)

        // pickers
        VStack(spacing: 0) {
          TabView(selection: $chosenPicker) {
            SheetEmojiGridView(detent: $detent) { emoji in
              onEmojiPicked?(emoji)
            }
            .tag(ChosenPicker.emoji)
            SheetGifGridView(detent: $detent) { gifURL in
              onGIFPicked?(gifURL)
            }
            .tag(ChosenPicker.gif)
            SheetStickerGridView(detent: $detent) { sticker in
              onStickerPicked?(sticker)
            }
            .tag(ChosenPicker.sticker)
          }
          .tabViewStyle(.page(indexDisplayMode: .never))
          .animation(.default, value: chosenPicker)
          // disable switching tabs via swipe, only allow via picker
          .introspect(.tabView(style: .page), on: .iOS(.v17...)) { tabView in
            tabView.isScrollEnabled = false
          }
        }
        .maxHeight(.infinity)
      }
    }

    struct SheetEmojiGridView: View {
      // grid of emojis, with a safe area inset at the bottom to select categories
      // categories are: favorites, all discord servers, then unicode categories
      // unicode emoji data from SwiftEmojiIndex.
      @Environment(\.gateway) var gw
      @Environment(\.appState) var appState
      @Binding var detent: PresentationDetent
      var onEmojiPicked: (DiscordModels.Emoji) -> Void
      var guildEmojis: [GuildSnowflake: [EmojiSnowflake: DiscordModels.Emoji]] {
        gw.user.emojis
      }
      @State private var searchText: String = ""
      var body: some View {
        VStack {
          if detent == .large {
            SearchBar("Find the perfect emoji", text: $searchText)
              .searchBarStyle(.prominent)
              .scaleEffect(1.02)
              .clipped()
              .scaleEffect(1 / 1.02)
          }
          ScrollView {
            LazyVStack(spacing: 0) {
              Text("Emoji Picker Coming Soon!")
            }
            .scrollTargetLayout()
          }
        }
        .animation(.spring(), value: detent)
      }
    }

    struct SheetGifGridView: View {
      @Environment(\.gateway) var gw
      @Environment(\.appState) var appState
      @Binding var detent: PresentationDetent
      var onGIFPicked: (String) -> Void
      @State private var searchText: String = ""
      var body: some View {
        VStack {
          if detent == .large {
            SearchBar("Search Tenor", text: $searchText)
              .searchBarStyle(.prominent)
              .scaleEffect(1.02)
              .clipped()
              .scaleEffect(1 / 1.02)
          }
          ScrollView {
            LazyVStack(spacing: 0) {
              Text("GIF Picker Coming Soon!")
            }
            .scrollTargetLayout()
          }
        }
        .animation(.spring(), value: detent)
      }
    }

    struct SheetStickerGridView: View {
      @Environment(\.gateway) var gw
      @Environment(\.appState) var appState
      @Binding var detent: PresentationDetent
      var onStickerPicked: (Sticker) -> Void
      var guildStickers: [GuildSnowflake: [StickerSnowflake: Sticker]] {
        gw.user.stickers
      }
      @State private var searchText: String = ""
      var body: some View {
        VStack {
          if detent == .large {
            SearchBar("Find the perfect sticker", text: $searchText)
              .searchBarStyle(.prominent)
              .scaleEffect(1.02)
              .clipped()
              .scaleEffect(1 / 1.02)
          }
          ScrollView {
            LazyVStack(spacing: 0) {
              Text("Sticker Picker Coming Soon!")
            }
            .scrollTargetLayout()
          }
        }
        .animation(.spring(), value: detent)
      }
    }
  #endif

  // Initialiser Modifiers
  // Avoid modifying these values after initialisation, keep them constant.
  func defaultChosenPicker(_ picker: ChosenPicker) -> Self {
    var copy = self
    copy._chosenPicker = State(initialValue: picker)
    return copy
  }

  func onPickedEmoji(_ action: @escaping (DiscordModels.Emoji) -> Void) -> Self
  {
    var copy = self
    copy.onEmojiPicked = action
    return copy
  }

  func onPickedGIF(_ action: @escaping (String) -> Void) -> Self {
    var copy = self
    copy.onGIFPicked = action
    return copy
  }

  func onPickedSticker(_ action: @escaping (Sticker) -> Void) -> Self {
    var copy = self
    copy.onStickerPicked = action
    return copy
  }

  func forcedStyle(_ style: UserInterfaceIdiom) -> Self {
    var copy = self
    copy.forcedStyle = style
    return copy
  }

  func allowsShiftToKeepOpen(_ bool: Bool) -> Self {
    var copy = self
    copy.allowsShiftToKeepOpen = bool
    return copy
  }

  // Types
  enum ChosenPicker: Int {
    case emoji
    case gif
    case sticker
  }
}

#Preview {
  @Previewable @State var sheet = true
  @Previewable @State var detent: PresentationDetent = .medium
  Button("Show Emoji Picker") {
    sheet.toggle()
  }
  .popover(isPresented: $sheet, arrowEdge: .bottom) {
    EmojiPicker(detent: $detent)
      .fontDesign(.rounded)
      .presentationDetents([.height(302.0), .large], selection: $detent)
  }
}
