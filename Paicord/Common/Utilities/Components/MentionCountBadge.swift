//
//  MentionCountBadge.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 09/07/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//  

import PaicordLib
import SwiftUIX

struct MentionCountBadge: View {
    var count: Int

    var body: some View {
      if count > 0 {
        Text(count > 99 ? "99+" : "\(count)")
          .font(.caption2)
          .fontWeight(.bold)
          .foregroundStyle(.white)
          .padding(.horizontal, count > 9 ? 5 : 0)
          .frame(minWidth: 16, minHeight: 16)
          .background(Color.red, in: .capsule)
      }
    }
  }
