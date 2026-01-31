//
//  EmojiPicker.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 30/01/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import PaicordLib
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
    default:
      #if os(iOS)
        sheetLayout
      #else
        EmptyView()
      #endif
    }
  }

  // Platform Layouts
  @ViewBuilder
  var popoverLayout: some View {
    VStack {
      HStack {
        Button("GIFS") {
          self.chosenPicker = .gif
        }
        .buttonStyle(.borderless)
        .padding(.small)
        .background(.gray.opacity(chosenPicker == .gif ? 0.1 : 0))
        .clipShape(.rounded)

        Button("Stickers") {
          self.chosenPicker = .sticker
        }
        .buttonStyle(.borderless)
        .padding(.small)
        .background(.gray.opacity(chosenPicker == .sticker ? 0.1 : 0))
        .clipShape(.rounded)

        Button("Emojis") {
          self.chosenPicker = .emoji
        }
        .buttonStyle(.borderless)
        .padding(.small)
        .background(.gray.opacity(chosenPicker == .emoji ? 0.1 : 0))
        .clipShape(.rounded)
      }

      // pickers
    }
    .padding(.regular)
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
            emojiPickerTab
              .tag(ChosenPicker.emoji)
            gifPickerTab
              .tag(ChosenPicker.gif)
            stickerPickerTab
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

  
  #if os(iOS)
  // Views iOS
  @ViewBuilder
  var emojiPickerTab: some View {
    EmojiGridView(detent: $detent) { emoji in
      onEmojiPicked?(emoji)
    }
  }

  @ViewBuilder
  var gifPickerTab: some View {
    GifGridView(detent: $detent) { gifURL in
      onGIFPicked?(gifURL)
    }
  }

  @ViewBuilder
  var stickerPickerTab: some View {
    StickerGridView(detent: $detent) { sticker in
      onStickerPicked?(sticker)
    }
  }
  
    struct EmojiGridView: View {
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

            }
            .scrollTargetLayout()
          }
        }
        .animation(.spring(), value: detent)
      }
    }

    struct GifGridView: View {
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

    struct StickerGridView: View {
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
}

#Preview {
  @Previewable @State var sheet = true
  @Previewable @State var detent: PresentationDetent = .medium
  Button("Show Emoji Picker") {
    sheet.toggle()
  }
  .sheet(isPresented: $sheet) {
    EmojiPicker(detent: $detent)
      .fontDesign(.rounded)
      .presentationDetents([.height(302.0), .large], selection: $detent)
  }
}
