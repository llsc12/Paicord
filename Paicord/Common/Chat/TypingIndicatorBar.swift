//
//  TypingIndicatorBar.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 21/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

extension ChatView {
  struct TypingIndicatorBar: View {
    @Environment(\.gateway) var gw
    @Environment(\.userInterfaceIdiom) var idiom
    var vm: ChannelStore
    var body: some View {

      if !vm.typingTimeoutTokens.isEmpty {
        let typingUserIds = vm.typingTimeoutTokens.keys
        let typingUsers = typingUserIds.compactMap {
          gw.user.users[$0]
        }
        let typingUsernames = typingUsers.compactMap {
          vm.guildStore?.members[$0.id]?.nick ?? $0.global_name ?? $0.username
        }
        if !typingUsernames.isEmpty {
          HStack {
            TypingIndicator()
              .padding(.horizontal, 9)
            if typingUsernames.count == 1, let username = typingUsernames.first {
              Text(username).fontWeight(.heavy) + Text(" is typing...")
            } else if typingUsernames.count == 2,
              let first = typingUsernames.first,
              let last = typingUsernames.last
            {
              Text(first).fontWeight(.heavy) + Text(" and ")
                + Text(last).fontWeight(.heavy)
                + Text(" are typing...")
            } else {
              let ppl = typingUsernames.reduce(Text(verbatim: "")) {
                partialResult,
                username in
                if username == typingUsernames.last {
                  return partialResult + Text("and ")
                    + Text(username).fontWeight(.heavy)
                } else {
                  return partialResult + Text(username).fontWeight(.heavy)
                    + Text(", ")
                }
              }
              ppl + Text(" are typing...")
            }
            Spacer()
          }
          .font(idiom == .phone ? .footnote : .subheadline)
          .lineLimit(1)
          .truncationMode(.head)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
        }
      }
    }
  }

  struct TypingIndicator: View {
    @State var dotsToggle: Bool = false

    let dotSize: CGFloat = 6
    let dotMinScale: CGFloat = 0.8
    let dotMaxScale: CGFloat = 1.1

    let dotAnim: Animation = .easeInOut(duration: 0.6)
      .repeatForever(autoreverses: true)

    var body: some View {
      HStack(spacing: 3) {
        ForEach(0..<3) { i in
          let i = Double(i)
          Circle()
            .width(dotSize)
            .height(dotSize)
            .scaleEffect(dotsToggle ? dotMaxScale : dotMinScale)
            .foregroundStyle(dotsToggle ? .primary : .tertiary)
            .animation(dotAnim.delay(0.2 * i), value: dotsToggle)
        }
      }
      .onAppearOnce {
        dotsToggle = true
      }
    }
  }

}
