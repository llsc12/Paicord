//
//  QuickSwitcherModifier.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUIX

extension View {
  func quickSwitcher() -> some View {
    self.modifier(QuickSwitcherModifier())
  }
}

struct QuickSwitcherModifier: ViewModifier {
  @Environment(\.appState) var appState
  @AppStorage("Paicord.QuickSwitcher.Position")
  @Storage var persistedPosition: CGPoint = .zero

  @State var currentPosition: CGPoint = .zero
  @State var switcherFrame: CGRect = .zero
  @State var viewableFrame: CGRect = .zero

  func body(content: Content) -> some View {
    content
      .overlay {
        if appState.showingQuickSwitcher {
          QuickSwitcherView()
            .onGeometryChange(
              for: CGRect.self,
              of: { $0.frame(in: .local) },
              action: { newValue in
                if switcherFrame != newValue {
                  switcherFrame = newValue
                }
              }
            )
            .position(
              x: currentPosition.x,
              y: currentPosition.y + (switcherFrame.height / 2)
            )
            .gesture(barDragGesture)
            .task(id: viewableFrame) { await validatePosition() }
            .task(id: switcherFrame) { await validatePosition() }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
              Color.black.opacity(0.25)
                .onTapGesture {
                  appState.showingQuickSwitcher = false
                }
            }
            .onGeometryChange(
              for: CGRect.self,
              of: { $0.frame(in: .local) },
              action: { newValue in
                if viewableFrame != newValue {
                  viewableFrame = newValue
                }
              }
            )
            .transition(.opacity.animation(.easeInOut(duration: 0.1)))
            .onKeyPress(.escape) {
              appState.showingQuickSwitcher = false
              return .handled
            }
            .onAppear {
              currentPosition = persistedPosition
            }
        }
      }
  }

  @Sendable
  func validatePosition() async {
    // Wait for valid frames
    guard switcherFrame.width > 0, viewableFrame.width > 0 else { return }

    let targetX: CGFloat
    let targetY: CGFloat

    // if the position is zero (first launch), center it
    if persistedPosition == .zero {
      targetX = viewableFrame.midX
      targetY = viewableFrame.midY - (switcherFrame.height / 2)

      let initialPos = CGPoint(x: targetX, y: targetY)
      currentPosition = initialPos
      persistedPosition = initialPos
      return
    }

    // Calculate clamped bounds
    targetX = min(
      max(currentPosition.x, switcherFrame.width / 2),
      viewableFrame.width - switcherFrame.width / 2
    )
    targetY = min(
      max(currentPosition.y, 0),
      viewableFrame.height - switcherFrame.height
    )

    let validatedPos = CGPoint(x: targetX, y: targetY)

    // CRITICAL: Only update state if it actually changed to prevent loops
    if currentPosition != validatedPos {
      currentPosition = validatedPos
    }
  }

  @ViewStorage private var dragStartPosition: CGPoint = .zero

  var barDragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        if dragStartPosition == .zero {
          dragStartPosition = currentPosition
        }

        let targetX = dragStartPosition.x + value.translation.width
        let targetY = dragStartPosition.y + value.translation.height

        let newX = min(
          max(targetX, switcherFrame.width / 2),
          viewableFrame.width - switcherFrame.width / 2
        )
        let newY = min(
          max(targetY, 0),
          viewableFrame.height - switcherFrame.height
        )

        let newPos = CGPoint(x: newX, y: newY)
        if currentPosition != newPos {
          currentPosition = newPos
        }
      }
      .onEnded { _ in
        dragStartPosition = .zero
        // Save to disk ONLY when the interaction ends
        persistedPosition = currentPosition
      }
  }
}
struct QuickSwitcherView: View {
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  @FocusState private var searchFieldFocused: Bool

  @State var query: String = ""
  @State var generatingResults: Bool = false
  @State var results: [QuickSwitcherProviderStore.SearchResult] = []

  @State var contentSize: CGSize = .zero

  private let cornerRadius: CGFloat = 14

  @State var focusedRow: Int? = nil
  @State var scrolledRow: Int? = nil
  var body: some View {
    VStack(spacing: 0) {
      HStack {
        TextField("Where would you like to go?", text: $query)
          .textFieldStyle(LargeTextFieldStyle())
          .focused($searchFieldFocused)
          .onAppear {
            searchFieldFocused = true
          }
          .onKeyPress { keyPress in
            if keyPress.key == .downArrow {
              if keyPress.modifiers.contains(.command) {
                self.focusedRow = results.count - 1
                return .handled
              } else if focusedRow == nil {
                focusedRow = 0
                return .handled
              } else if let focusedRow {
                self.focusedRow = min(focusedRow + 1, results.count - 1)
                return .handled
              }
            } else if keyPress.key == .upArrow {
              if keyPress.modifiers.contains(.command) {
                self.focusedRow = 0
                return .handled
              } else if let focusedRow {
                if focusedRow == 0 {
                  self.focusedRow = nil
                } else {
                  self.focusedRow = max(0, focusedRow - 1)
                }
                return .handled
              }
            } else if keyPress.key == .return {
              if let focusedRow {
                Task {
                  do {
                    try await actionForResult(
                      results[focusedRow],
                      i: focusedRow
                    )
                  } catch {
                    appState.error = error
                  }
                }
                return .handled
              } else if results.count != 0 {
                Task {
                  do {
                    try await actionForResult(results[0], i: 0)
                  } catch {
                    appState.error = error
                  }
                }
                return .handled
              }
            }
            return .ignored
          }

        if generatingResults {
          ProgressView()
            .progressViewStyle(.circular)
        } else if !results.isEmpty {
          Text("\(results.count) Result\(results.count == 1 ? "" : "s")")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .padding(14)
      .maxHeight(50)

      if !query.isEmpty, !results.isEmpty {
        Divider()
        ScrollView {
          LazyVStack {
            ForEach(Array(results.enumerated()), id: \.offset) { (i, result) in
              AsyncButton {
                try await actionForResult(result, i: i)
              } catch: { error in
                appState.error = error
              } label: {
                resultCell(result)
              }
              .buttonStyle(.borderless)
              .background(
                i == (self.focusedRow ?? -1) ? Color.accentColor : Color.clear
              )
              .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
              .padding(.horizontal, 8)
            }
          }
          .onGeometryChange(
            for: CGSize.self,
            of: { $0.size },
            action: { newValue in
              contentSize = newValue
            }
          )
          .scrollTargetLayout()
        }
        .scrollClipDisabled()
        .scrollPosition(id: $scrolledRow)
        .scrollDisabled(contentSize.height <= 300)
        .maxHeight(min(contentSize.height, 300))
        .padding(.vertical, 8)
        .clipped()
        .onChange(of: focusedRow) { scrolledRow = focusedRow }
        .onDisappear {
          contentSize = .zero
        }
      }
    }
    .maxWidth(600)
    .background(.ultraThinMaterial.blendMode(.darken))
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .circular))
    .overlay {
      RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
        .strokeBorder(.black, lineWidth: 0.5)
    }
    .overlay {
      RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
        .strokeBorder(.gray.opacity(0.4), lineWidth: 0.85)
        .padding(0.5)
    }
    .shadow(color: .black.opacity(0.65), radius: 20, x: 0, y: 20)
    .task(id: query) {
      guard !query.isEmpty else {
        self.results = []
        self.generatingResults = false
        return
      }
      self.focusedRow = nil

      self.generatingResults = true
      for await newResults in gw.switcher.search(query) {
        if Task.isCancelled { break }
        self.results = newResults
      }

      self.generatingResults = false
    }
  }

  @ViewBuilder
  func resultCell(_ result: QuickSwitcherProviderStore.SearchResult)
    -> some View
  {
    Group {
      switch result {
      case .user(let user):  // or dm ykyk
        HStack {
          Profile.AvatarWithPresence(user: user)
            .frame(width: 30, height: 30)
            .padding(10)

          Text(user.global_name ?? user.username ?? "Unknown User")

          Text(user.username ?? "")
            .fontWeight(.regular)
            .foregroundStyle(.secondary)
        }
      case .groupDM(let channel):
        let ppl = channel.recipients ?? []
        HStack(spacing: 8) {
          Group {
            if let icon = channel.icon {
              let url = URL(
                string: CDNEndpoint.channelIcon(
                  channelId: channel.id,
                  icon: icon
                )
                .url + ".png?size=80"
              )
              WebImage(url: url)
                .resizable()
                .scaledToFit()
                .clipShape(.circle)
            } else {
              VStack {
                if let firstUser = ppl.first(where: {
                  $0.id != gw.user.currentUser?.id
                }),
                  let lastUser = ppl.last(where: {
                    $0.id != gw.user.currentUser?.id && $0.id != firstUser.id
                  })
                {
                  Group {
                    Profile.Avatar(
                      member: nil,
                      user: firstUser.toPartialUser()
                    )
                    .profileShowsAvatarDecoration()
                    .scaleEffect(0.75, anchor: .topLeading)
                    .overlay(
                      Profile.Avatar(
                        member: nil,
                        user: lastUser.toPartialUser()
                      )
                      .profileShowsAvatarDecoration()
                      .scaleEffect(0.75, anchor: .bottomTrailing)
                    )
                  }
                } else if let user = ppl.first {
                  Profile.AvatarWithPresence(
                    member: nil,
                    user: user.toPartialUser()
                  )
                  .profileShowsAvatarDecoration()
                } else {
                  Circle()
                    .fill(Color.gray)
                }
              }
              .aspectRatio(1, contentMode: .fit)
            }
          }
          .frame(width: 30, height: 30)
          .padding(10)

          Text(
            channel.name
              ?? ppl.map({
                $0.global_name ?? $0.username
              }).joined(separator: ", ")
          )
        }
      case .guildChannel(let channel, let category, let guild):
        HStack {
          Group {
            switch channel.type {
            case .guildText:
              Image(systemName: "number")
                .imageScale(.medium)
            case .guildAnnouncement:
              Image(systemName: "megaphone.fill")
                .imageScale(.medium)
            case .guildVoice:
              Image(systemName: "speaker.wave.2.fill")
                .imageScale(.medium)
            default:
              Image(systemName: "number")
                .imageScale(.medium)
            }
          }
          .frame(width: 30, height: 30)
          .padding(10)

          Text(channel.name ?? "unknown")

          Text(category?.name ?? "")
            .font(.body)
            .fontWeight(.regular)
            .foregroundStyle(.secondary)

          Spacer()

          Text(guild.name)
            .font(.body)
            .fontWeight(.regular)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
        }
      case .guild(let guild):
        HStack {
          Group {
            if let icon = guild.icon {
              let url =
                CDNEndpoint.guildIcon(
                  guildId: guild.id,
                  icon: icon
                ).url + "?size=80"
              WebImage(url: URL(string: url))
                .resizable()
                .scaledToFit()
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
          .clipShape(.rect(cornerRadius: 6, style: .continuous))
          .frame(width: 30, height: 30)
          .padding(10)

          Text(guild.name)
        }
      }
    }
    .fontWeight(.semibold)
    .font(.title2)
    .lineLimit(1)
    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
  }

  func actionForResult(
    _ result: QuickSwitcherProviderStore.SearchResult,
    i: Int
  ) async throws {
    defer { appState.showingQuickSwitcher = false }
    self.focusedRow = i  // highlight it?

    switch result {
    case .user(let user):
      let res = try await gw.client.createDm(payload: .init(recipient: user.id))
      try res.guardSuccess()
      let channel = try res.decode()
      appState.selectedGuild = nil
      appState.selectedChannel = channel.id
    case .groupDM(let channel):
      appState.selectedGuild = nil
      appState.selectedChannel = channel.id
    case .guildChannel(let channel, _, let guild):
      appState.selectedGuild = guild.id
      switch channel.type {
      case .guildText, .guildAnnouncement:
        appState.selectedChannel = channel.id
      default: break
      }
    case .guild(let guild):
      appState.selectedGuild = guild.id
    }
  }
}

struct LargeTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(.secondary)
        .font(.title)
      configuration
        .textFieldStyle(.plain)
        .font(.largeTitle)
    }
  }
}

#Preview {
  TextField("Where would you like to go?", text: .constant(""))
    .textFieldStyle(LargeTextFieldStyle())
    .width(600)
    .padding()
}

extension CGPoint: AppStorageConvertible {
  init?(_ storedValue: String) {
    let components = storedValue.split(separator: ",").compactMap { Double($0) }
    guard components.count == 2 else { return nil }
    self.init(x: components[0], y: components[1])
  }

  var storedValue: String {
    "\(x),\(y)"
  }
}
