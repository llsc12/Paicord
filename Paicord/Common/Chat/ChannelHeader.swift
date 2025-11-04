//
//  ChannelHeader.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 11/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUIX

extension ChatView {
  struct ChannelHeader: View {
    @Environment(\.userInterfaceIdiom) var idiom
    var vm: ChannelStore

    var body: some View {
      if let name = vm.channel?.name {
        HStack(spacing: 4) {
          Image(systemName: "number")
            .foregroundStyle(.secondary)
            .imageScale(idiom == .phone ? .medium : .large)

          Text(name)
            .font(idiom == .phone ? .headline : .title3)
            .fontWeight(.semibold)
        }
      } else if let ppl = vm.channel?.recipients {
        Text(
          ppl.map({
            $0.global_name ?? $0.username
          }).joined(separator: ", ")
        )
      }
    }
  }

  //  struct ChannelTopic: View {
  //    var topic: String
  //    @State private var showChannelInfo: Bool = false
  //
  //    var body: some View {
  //      Button {
  //        showChannelInfo.toggle()
  //      } label: {
  //        LabeledContent {
  //          HStack(spacing: 5) {
  //            Text("•")
  //              .foregroundStyle(.tertiary)
  //
  //            Text(topic)
  //              .lineLimit(1)
  //              .truncationMode(.tail)
  //              .foregroundStyle(.secondary)
  //              .font(.body)
  //          }
  //        } label: {
  //          Text(topic)
  //        }
  //      }
  //      .buttonStyle(.plain)
  //      .sheet(isPresented: $showChannelInfo) {
  //        Text(topic)
  //          .padding()
  //      }
  //    }
  //  }
}
