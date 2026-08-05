//
//  NukeImage.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 04/08/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Nuke
import NukeUI
import SwiftUI

/// Loads a remote image, playing it if the data turns out to be animated.
struct NukeImage<Placeholder: View>: View {
  let url: URL?
  var isAnimating: Bool = true
  var placeholder: (() -> Placeholder)?

  private var isResizable = false

  var body: some View {
    LazyImage(url: url) { state in
      if let container = state.imageContainer {
        content(for: container)
      } else if let placeholder {
        placeholder()
      } else {
        Color.clear
      }
    }
  }

  @ViewBuilder
  private func content(for container: ImageContainer) -> some View {
    if let data = container.data,
      let source = AnimatedImageFrameSource(
        data: data,
        utType: container.type?.rawValue as CFString?
      ),
      source.isAnimated
    {
      AnimatedImageRenderer(
        source: source,
        isAnimating: isAnimating,
        isResizable: isResizable
      )
    } else {
      let image = Image(platformImage: container.image)
      if isResizable {
        image.resizable()
      } else {
        image
      }
    }
  }

  func resizable() -> Self {
    var copy = self
    copy.isResizable = true
    return copy
  }
}

extension NukeImage where Placeholder == EmptyView {
  init(url: URL?, isAnimating: Bool = true) {
    self.url = url
    self.isAnimating = isAnimating
    self.placeholder = nil
  }
}

extension NukeImage {
  init(
    url: URL?,
    isAnimating: Bool = true,
    @ViewBuilder placeholder: @escaping () -> Placeholder
  ) {
    self.url = url
    self.isAnimating = isAnimating
    self.placeholder = placeholder
  }
}

extension Image {
  init(platformImage: PlatformImage) {
    #if os(macOS)
      self.init(nsImage: platformImage)
    #else
      self.init(uiImage: platformImage)
    #endif
  }
}
