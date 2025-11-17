//
//  FlowLayout.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 16/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

struct FlowLayout: Layout {
  var xSpacing: CGFloat
  var ySpacing: CGFloat
  var alignment: HorizontalAlignment = .leading
  
  init(spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading) {
    self.xSpacing = spacing
    self.ySpacing = spacing
    self.alignment = alignment
  } 

  init(
    xSpacing: CGFloat = 8,
    ySpacing: CGFloat = 8,
    alignment: HorizontalAlignment = .leading
  ) {
    self.xSpacing = xSpacing
    self.ySpacing = ySpacing
    self.alignment = alignment
  }

  struct Cache {
    var rows: [[(Subviews.Element, CGSize)]]
    var totalSize: CGSize
  }

  func makeCache(subviews: Subviews) -> Cache {
    Cache(rows: [], totalSize: .zero)
  }

  func updateCache(
    _ cache: inout Cache,
    subviews: Subviews,
    proposal: ProposedViewSize
  ) {
    let maxWidth = proposal.replacingUnspecifiedDimensions().width
    guard maxWidth > 0 else {
      cache = Cache(rows: [], totalSize: .zero)
      return
    }

    var rows: [[(Subviews.Element, CGSize)]] = []
    var currentRow: [(Subviews.Element, CGSize)] = []
    var rowWidth: CGFloat = 0
    var rowHeight: CGFloat = 0

    for sub in subviews {
      let size = sub.sizeThatFits(.unspecified)

      if !currentRow.isEmpty, rowWidth + size.width + xSpacing > maxWidth {
        rows.append(currentRow)
        currentRow = []
        rowWidth = 0
        rowHeight = 0
      }

      currentRow.append((sub, size))
      rowWidth += size.width + (currentRow.count > 1 ? xSpacing : 0)
      rowHeight = max(rowHeight, size.height)
    }

    if !currentRow.isEmpty {
      rows.append(currentRow)
    }

    var totalHeight: CGFloat = 0
    var maxRowWidth: CGFloat = 0

    for (i, row) in rows.enumerated() {
      let width =
        row.reduce(0) { $0 + $1.1.width } + CGFloat(max(0, row.count - 1))
        * xSpacing

      let height = row.map { $0.1.height }.max() ?? 0

      maxRowWidth = max(maxRowWidth, width)
      totalHeight += height

      if i != rows.count - 1 {
        totalHeight += ySpacing  // no top spacing for first row
      }
    }

    cache = Cache(
      rows: rows,
      totalSize: CGSize(width: maxRowWidth, height: totalHeight)
    )
  }

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGSize {
    updateCache(&cache, subviews: subviews, proposal: proposal)
    return cache.totalSize
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    var y = bounds.minY

    for row in cache.rows {
      let rowHeight = row.map { $1.height }.max() ?? 0

      // Row alignment
      let rowWidth =
        row.reduce(0) { $0 + $1.1.width } + CGFloat(max(0, row.count - 1))
        * xSpacing

      let xOffset: CGFloat
      switch alignment {
      case .leading:
        xOffset = bounds.minX
      case .center:
        xOffset = bounds.minX + (bounds.width - rowWidth) / 2
      case .trailing:
        xOffset = bounds.maxX - rowWidth
      default:
        xOffset = bounds.minX
      }

      var x = xOffset

      for (sub, size) in row {
        sub.place(
          at: CGPoint(x: x, y: y),
          anchor: .topLeading,
          proposal: ProposedViewSize(size)
        )
        x += size.width + xSpacing
      }

      y += rowHeight + ySpacing
    }
  }
}
