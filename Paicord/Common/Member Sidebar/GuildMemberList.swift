//
//  GuildMemberList.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 03/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUIX

extension MemberSidebarView {
  struct GuildMemberList: View {
    var guildStore: GuildStore
    var channelStore: ChannelStore
    var accumulator: ChannelStore.MemberListAccumulator

    @State var upperBound: Int? = 0

    var scrollPairs: [IntPair] {
      var pairs: [(Int, Int)] = [(0, 99)]
      guard let upperBound else {
        return pairs.map(IntPair.init)
      }
      let maxIndex = accumulator.rowCount - 1
      guard maxIndex >= 100 else {
        return pairs.map(IntPair.init)
      }
      let currentBlock = upperBound / 100
      let maxBlock = maxIndex / 100
      let clampedBlock = min(currentBlock, maxBlock)
      var blocks: [Int] = []
      for i in stride(
        from: clampedBlock,
        through: max(clampedBlock - 1, 1),
        by: -1
      ) {
        blocks.append(i)
      }
      for block in blocks {
        let start = block * 100
        pairs.insert((start, start + 99), at: 1)
      }
      let mapped = pairs.map(IntPair.init)
      return mapped.count <= 3 ? mapped : [.init(0, 99)]
    }

    var body: some View {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 2) {
          ForEach(0...accumulator.rowCount, id: \.self) { itemIndex in
            cell(itemIndex)
          }
        }
        .scrollTargetLayout()
        .padding(.horizontal, 2)
      }
      .scrollPosition(id: $upperBound, anchor: .bottom)
      .task(id: scrollPairs) {
        await channelStore.requestMemberListRange(scrollPairs)
      }
    }

    @ViewBuilder
    func cell(_ itemIndex: Int) -> some View {
      HStack(alignment: .bottom) {
        if let item = accumulator[row: itemIndex] {
          switch item {
          case .member(let member):
            if let user = member.user {
              MemberRowView(member: member.toPartialMember(), user: user)
            }
          case .group(let group):
            if let group = accumulator.groups[group.id] {
              let text: Text = {
                if let role = guildStore.roles[group.id] {
                  return (Text(verbatim: role.name) + Text(verbatim: " - \(group.count)"))
                } else {
                  let name: String = group.id.rawValue.capitalized
                  return Text(verbatim: "\(name) - \(group.count)")
                }
              }()

              text
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(
                  maxWidth: .infinity,
                  maxHeight: .infinity,
                  alignment: .bottomLeading
                )
                .padding([.bottom, .leading], 6)
            } else {
              // idk man
              Text(verbatim: "\(group.id.rawValue)")
            }
          }
        }
      }
      .frame(height: 45)
    }
  }
}
