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

enum ImageAnimation {
  case never
  case always
  case enabled(Bool)

  var wantsAnimation: Bool {
    switch self {
    case .never: false
    case .always: true
    case .enabled(let enabled): enabled
    }
  }
}

struct NukeImage<Placeholder: View>: View {
  let urlForVariant: (_ animated: Bool) -> URL?
  var animation: ImageAnimation = .always
  var placeholder: (() -> Placeholder)?

  private var isResizable = false

  private var wantsAnimation: Bool { animation.wantsAnimation }

  var body: some View {
    LazyImage(url: urlForVariant(wantsAnimation)) { state in
      if let container = state.imageContainer {
        content(for: container)
      } else if wantsAnimation, let stillURL = urlForVariant(false),
        stillURL != urlForVariant(true)
      {
        // the animated variant is the heavy one, so hold the still (usually already cached from
        // before the policy flipped on) rather than blanking out while it loads.
        // old paicord problem i wanted to fix for a while.
        stillContent(for: stillURL)
      } else if let placeholder {
        placeholder()
      } else {
        Color.clear
      }
    }
  }

  @ViewBuilder
  private func content(for container: ImageContainer) -> some View {
    // only build animation setup work if the image is even animated
    if wantsAnimation, let data = container.data,
      let source = AnimatedImageFrameSource(
        data: data,
        utType: container.type?.rawValue as CFString?
      ),
      source.isAnimated
    {
      AnimatedImageRenderer(
        source: source,
        isAnimating: true,
        isResizable: isResizable
      )
    } else {
      resized(Image(platformImage: container.image))
    }
  }

  @ViewBuilder
  private func stillContent(for url: URL) -> some View {
    LazyImage(url: url) { state in
      if let container = state.imageContainer {
        resized(Image(platformImage: container.image))
      } else if let placeholder {
        placeholder()
      } else {
        Color.clear
      }
    }
  }

  @ViewBuilder
  private func resized(_ image: Image) -> some View {
    if isResizable {
      image.resizable()
    } else {
      image
    }
  }

  func resizable() -> Self {
    var copy = self
    copy.isResizable = true
    return copy
  }
}

// extra initialisers

extension NukeImage where Placeholder == EmptyView {
  init(
    animation: ImageAnimation = .always,
    url urlForVariant: @escaping (_ animated: Bool) -> URL?
  ) {
    self.urlForVariant = urlForVariant
    self.animation = animation
    self.placeholder = nil
  }
}

extension NukeImage {
  init(
    animation: ImageAnimation = .always,
    url urlForVariant: @escaping (_ animated: Bool) -> URL?,
    @ViewBuilder placeholder: @escaping () -> Placeholder
  ) {
    self.urlForVariant = urlForVariant
    self.animation = animation
    self.placeholder = placeholder
  }
}

extension NukeImage where Placeholder == EmptyView {
  init(url: URL?, isAnimating: Bool = true) {
    self.urlForVariant = { _ in url }
    self.animation = isAnimating ? .always : .never
    self.placeholder = nil
  }
}

extension NukeImage {
  init(
    url: URL?,
    isAnimating: Bool = true,
    @ViewBuilder placeholder: @escaping () -> Placeholder
  ) {
    self.urlForVariant = { _ in url }
    self.animation = isAnimating ? .always : .never
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
