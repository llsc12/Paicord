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
          EmojiGridView { emoji in
            onEmojiPicked?(emoji)
          }
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

  struct EmojiGridView: View {
    @Environment(\.gateway) var gw
    var onEmojiPicked: (DiscordModels.Emoji) -> Void
    @State private var searchText = ""
    var body: some View {
      VStack {
        SearchBar("Find the perfect emoji", text: $searchText)
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            guildBar
            ScrollView {
              LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 8),
                spacing: 12
              ) {
                Text("Emoji Picker Coming Soon!")
              }
            }
            .maxWidth(.infinity)
          }
          HStack {
            Text("highlighted")
          }
          .maxWidth(.infinity)
          .height(50)
          .background(.black.opacity(0.2))
        }
        .padding([.horizontal, .bottom], -15)
      }
    }

    @ViewBuilder
    var guildBar: some View {
      ScrollView {
        ForEach(sections) { section in
          LazyVStack {
            Button {

            } label: {
              Group {
                switch section {
                case .favourites:
                  Image(systemName: "star.fill")
                    .resizable()
                case .frequents:
                  Image(systemName: "clock.fill")
                    .resizable()
                case .top:
                  Image(systemName: "trophy.fill")
                    .resizable()
                case .unicodeCategory(let category):
                  Image(systemName: category.symbolName)
                    .resizable()
                case .guild(let id):
                  if let guild = gw.user.guilds[id] {
                    guildButton(from: guild)
                  } else {
                    Circle()
                  }
                }
              }
              .scaledToFit()
              .aspectRatio(1, contentMode: .fit)
            }
            .buttonStyle(.borderless)
          }
          .padding(.horizontal, .small)
        }
      }
      .width(50)
      .background(.black.opacity(0.2))
      .scrollIndicators(.never)
    }

    func guildButton(from guild: Guild) -> some View {
      Group {
        if let icon = guild.icon,
           let url = iconURL(id: guild.id, icon: icon, animated: false)
        {
          WebImage(url: url)
            .resizable()
            .scaledToFill()
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
          return "guild_\(guildID)"
        case .unicodeCategory(let category):
          return "unicode_\(category.rawValue)"
        }
      }
    }

    var orderedGuildIDs: [GuildSnowflake] {
      var guilds: [GuildSnowflake] = []
      // retrieve guilds that weren't ordered
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
      #warning(
        "replace with integer initialiser once pr discordbm-changes is merged"
      )
      guilds.append(
        contentsOf: gw.settings.userSettings.guildFolders.folders.flatMap(
          \.guildIds
        ).map { GuildSnowflake($0.description) }
      )
      return guilds
    }

    var sections: [EmojiPickerSection] {
      var sections: [EmojiPickerSection] = []
      print(gw.settings.frecencySettings)
      if gw.settings.frecencySettings.hasFavoriteEmojis {
        sections.append(.favourites)
      }
      if gw.settings.frecencySettings.hasEmojiFrecency {
        sections.append(.frequents)
      }

      return sections + orderedGuildIDs.map { .guild($0) }
        + EmojiCategory.allCases.map { .unicodeCategory($0) }
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
