//
//  Utilities.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 11/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUIX

extension MessageCell {
  struct AvatarBalancing: View {
    var body: some View {
      Button {
      } label: {
        Text("")
          .frame(width: avatarSize)
      }
      .buttonStyle(.borderless)
      .height(1)
      .disabled(true)  // btn used for spacing only
      #if os(macOS)
        .padding(.trailing, 4)  // balancing
      #endif
    }
  }

  struct ReplyLine: View {
    var body: some View {
      RoundedRectangle(cornerRadius: 5)
        .trim(from: 0.5, to: 0.75)
        .stroke(.gray.opacity(0.4), lineWidth: 2)
        .frame(width: 60, height: 20)
        .padding(.top, 8)
        .padding(.bottom, -12)
        .padding(.trailing, -30)
    }
  }
}
