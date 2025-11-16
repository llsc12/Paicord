//
//  PlaceholderMessageCell.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 07/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//  

import PaicordLib
import SwiftUIX

struct PlaceholderMessageCell: View {

  /// Controls the size of the avatar in the message cell.
  #if os(iOS)
    static let avatarSize: CGFloat = 40
  #elseif os(macOS)
    static let avatarSize: CGFloat = 35
  #endif

  @State var cellHighlighted = false

  var body: some View {
    Group {
      DefaultMessage()
    }
    .background(Color.almostClear)
    .padding(.horizontal, 10)
    .padding(.vertical, 2)
    #if os(macOS)
      .onHover { self.cellHighlighted = $0 }
      .background(
        cellHighlighted
          ? Color(NSColor.secondaryLabelColor).opacity(0.1) : .clear
      )
    #endif
  }
}

#Preview {
  PlaceholderMessageCell()
}

extension PlaceholderMessageCell {
  struct DefaultMessage: View {
    enum PlaceholderLength {
      case short
      case medium
      case long
    }
    
    var length: PlaceholderLength = .medium
    
    var body: some View {
      VStack {
        HStack(alignment: .bottom) {
          Button {
          } label: {
            Circle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: avatarSize, height: avatarSize)
          }
          .buttonStyle(.borderless)
          .frame(maxHeight: .infinity, alignment: .top)  // align pfp to top of cell
#if os(macOS)
          .padding(.trailing, 4)  // balancing
#endif
          userAndMessage
        }
        .fixedSize(horizontal: false, vertical: true)
      }
    }
    
    @ViewBuilder
    var userAndMessage: some View {
      VStack(spacing: 2) {
        HStack(alignment: .center) {
          Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 100, height: 14)
            .clipShape(.rounded)
        }
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .bottomLeading
        )
        .fixedSize(horizontal: false, vertical: true)
        
        FlowLayout {
          switch length {
          case .short:
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 120, height: 14)
              .clipShape(.rounded)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 80, height: 14)
              .clipShape(.rounded)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 150, height: 14)
              .clipShape(.rounded)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 90, height: 14)
              .clipShape(.rounded)
          case .medium:
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 200, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 150, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 20, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 180, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 130, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 160, height: 14)
          case .long:
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 250, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 200, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 150, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 220, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 180, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 30, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 240, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 170, height: 14)
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 190, height: 14)
          }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)  // align text to bottom of cell
      }
    }
  }
}
