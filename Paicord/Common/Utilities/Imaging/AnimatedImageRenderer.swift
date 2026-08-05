//
//  AnimatedImageRenderer.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 04/08/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import ImageIO
import Nuke
import SwiftUI

#if os(macOS)
  import AppKit
#else
  import UIKit
#endif

/// Handles animated images. Also caches frames within a budget. Decoding is
/// done in the background, with out-of-budget images decoded on demand.
final class AnimatedImageFrameSource: @unchecked Sendable {
  // if the total decoded size is larger than this, we decode frames on demand
  private static let cacheBudgetBytes = 48 * 1024 * 1024
  // sane limit
  private static let minimumFrameDuration: TimeInterval = 0.011
  private static let fallbackFrameDuration: TimeInterval = 0.1

  private let source: CGImageSource
  let frameCount: Int
  let durations: [TimeInterval]
  let totalDuration: TimeInterval
  let pixelSize: CGSize

  private let lock = NSLock()
  private var cache: [Int: CGImage] = [:]
  private var isFullyCached = false

  init?(data: Data, utType: CFString?) {
    var options: [CFString: Any] = [kCGImageSourceShouldCache: true]
    if let utType {
      options[kCGImageSourceTypeIdentifierHint] = utType
    }
    guard
      let source = CGImageSourceCreateWithData(
        data as CFData,
        options as CFDictionary
      )
    else { return nil }

    let count = CGImageSourceGetCount(source)
    guard count > 0 else { return nil }

    self.source = source
    self.frameCount = count
    self.durations = (0..<count).map {
      Self.frameDuration(source: source, index: $0)
    }
    self.totalDuration = durations.reduce(0, +)

    let properties =
      CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
    let width = (properties?[kCGImagePropertyPixelWidth] as? CGFloat) ?? 0
    let height = (properties?[kCGImagePropertyPixelHeight] as? CGFloat) ?? 0
    self.pixelSize = CGSize(width: width, height: height)
  }

  var isAnimated: Bool { frameCount > 1 }

  // rough estimate only for deciding caching policy
  private var estimatedDecodedBytes: Int {
    Int(pixelSize.width * pixelSize.height) * 4 * frameCount
  }

  func frame(at index: Int) -> CGImage? {
    lock.lock()
    if let cached = cache[index] {
      lock.unlock()
      return cached
    }
    lock.unlock()

    guard let image = CGImageSourceCreateImageAtIndex(source, index, nil) else {
      return nil
    }

    if estimatedDecodedBytes <= Self.cacheBudgetBytes {
      lock.lock()
      cache[index] = image
      lock.unlock()
    }
    return image
  }

  func prefetchIfAffordable() {
    guard isAnimated, estimatedDecodedBytes <= Self.cacheBudgetBytes else {
      return
    }
    lock.lock()
    let alreadyDone = isFullyCached
    isFullyCached = true
    lock.unlock()
    guard !alreadyDone else { return }

    DispatchQueue.global(qos: .utility).async { [weak self] in
      guard let self else { return }
      for index in 0..<self.frameCount {
        guard
          let image = CGImageSourceCreateImageAtIndex(self.source, index, nil)
        else { continue }
        self.lock.lock()
        self.cache[index] = image
        self.lock.unlock()
      }
    }
  }

  private static func frameDuration(source: CGImageSource, index: Int)
    -> TimeInterval
  {
    guard
      let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        as? [CFString: Any]
    else { return fallbackFrameDuration }

    // get real delay time of the frame
    let containers: [(CFString, CFString, CFString)] = [
      (
        kCGImagePropertyGIFDictionary, kCGImagePropertyGIFUnclampedDelayTime,
        kCGImagePropertyGIFDelayTime
      ),
      (
        kCGImagePropertyPNGDictionary, kCGImagePropertyAPNGUnclampedDelayTime,
        kCGImagePropertyAPNGDelayTime
      ),
      (
        kCGImagePropertyWebPDictionary, kCGImagePropertyWebPUnclampedDelayTime,
        kCGImagePropertyWebPDelayTime
      ),
    ]

    for (dictionaryKey, unclampedKey, clampedKey) in containers {
      guard let dictionary = properties[dictionaryKey] as? [CFString: Any]
      else {
        continue
      }
      let unclamped = dictionary[unclampedKey] as? TimeInterval
      let clamped = dictionary[clampedKey] as? TimeInterval
      if let duration = unclamped ?? clamped {
        return duration < minimumFrameDuration
          ? fallbackFrameDuration : duration
      }
    }
    return fallbackFrameDuration
  }
}

// Draws animated images against a display link.
// Single frame images don't use display links.
struct AnimatedImageRenderer: View {
  let source: AnimatedImageFrameSource
  var isAnimating: Bool = true
  var isResizable: Bool = false

  var body: some View {
    #if os(iOS)
      IOSAnimatedImageView(
        source: source,
        isAnimating: isAnimating,
        isResizable: isResizable
      )
    #elseif os(macOS)
      MacOSAnimatedImageView(
        source: source,
        isAnimating: isAnimating,
        isResizable: isResizable
      )
    #endif
  }

  // sizing like swiftui
  static func size(
    for proposal: ProposedViewSize,
    naturalSize: CGSize?,
    isResizable: Bool
  ) -> CGSize? {
    guard isResizable else { return naturalSize }
    if let width = proposal.width, let height = proposal.height {
      return CGSize(width: width, height: height)
    }
    return naturalSize
  }

  #if os(iOS)
    struct IOSAnimatedImageView: UIViewRepresentable {
      let source: AnimatedImageFrameSource
      var isAnimating: Bool
      var isResizable: Bool

      func makeUIView(context: Context) -> AnimatedImagePlayerView {
        let view = AnimatedImagePlayerView()
        view.setContentCompressionResistancePriority(
          .defaultLow,
          for: .horizontal
        )
        view.setContentCompressionResistancePriority(
          .defaultLow,
          for: .vertical
        )
        view.configure(with: source)
        view.isPlaying = isAnimating
        return view
      }

      func updateUIView(_ uiView: AnimatedImagePlayerView, context: Context) {
        uiView.configure(with: source)
        uiView.isPlaying = isAnimating
      }

      func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: AnimatedImagePlayerView,
        context: Context
      ) -> CGSize? {
        AnimatedImageRenderer.size(
          for: proposal,
          naturalSize: uiView.naturalSize,
          isResizable: isResizable
        )
      }

      static func dismantleUIView(
        _ uiView: AnimatedImagePlayerView,
        coordinator: ()
      ) {
        uiView.stop()
      }
    }
  #elseif os(macOS)
    struct MacOSAnimatedImageView: NSViewRepresentable {
      let source: AnimatedImageFrameSource
      var isAnimating: Bool
      var isResizable: Bool

      func makeNSView(context: Context) -> AnimatedImagePlayerView {
        let view = AnimatedImagePlayerView()
        view.configure(with: source)
        view.isPlaying = isAnimating
        return view
      }

      func updateNSView(_ nsView: AnimatedImagePlayerView, context: Context) {
        nsView.configure(with: source)
        nsView.isPlaying = isAnimating
      }

      func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: AnimatedImagePlayerView,
        context: Context
      ) -> CGSize? {
        AnimatedImageRenderer.size(
          for: proposal,
          naturalSize: nsView.naturalSize,
          isResizable: isResizable
        )
      }

      static func dismantleNSView(
        _ nsView: AnimatedImagePlayerView,
        coordinator: ()
      ) {
        nsView.stop()
      }
    }
  #endif
}

// MARK: - Platform player view

#if os(iOS)
  final class AnimatedImagePlayerView: UIView {
    private var source: AnimatedImageFrameSource?
    private var link: CADisplayLink?
    private var frameIndex = 0
    private var elapsed: TimeInterval = 0

    private var staticSize: CGSize?

    var naturalSize: CGSize? {
      if let source, source.pixelSize.width > 0, source.pixelSize.height > 0 {
        return source.pixelSize
      }
      return staticSize
    }

    func displayStatic(_ image: CGImage) {
      stop()
      source = nil
      staticSize = CGSize(width: image.width, height: image.height)
      layer.contents = image
      invalidateIntrinsicContentSize()
    }

    var isPlaying: Bool = true {
      didSet {
        guard isPlaying != oldValue else { return }
        isPlaying ? start() : stop()
      }
    }

    override init(frame: CGRect) {
      super.init(frame: frame)
      layer.contentsGravity = .resizeAspect
      layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
      super.init(coder: coder)
      layer.contentsGravity = .resizeAspect
      layer.masksToBounds = true
    }

    func configure(with newSource: AnimatedImageFrameSource) {
      guard source !== newSource else { return }
      stop()
      source = newSource
      frameIndex = 0
      elapsed = 0
      newSource.prefetchIfAffordable()
      layer.contents = newSource.frame(at: 0)
      invalidateIntrinsicContentSize()
      if isPlaying { start() }
    }

    private func start() {
      guard let source, source.isAnimated, link == nil else { return }
      let link = CADisplayLink(target: self, selector: #selector(step(_:)))
      link.add(to: .main, forMode: .common)
      self.link = link
    }

    func stop() {
      link?.invalidate()
      link = nil
    }

    @objc private func step(_ link: CADisplayLink) {
      advance(by: link.targetTimestamp - link.timestamp)
    }

    private func advance(by delta: TimeInterval) {
      guard let source, source.isAnimated, source.totalDuration > 0 else {
        return
      }
      elapsed += delta
      var guardrail = 0
      while elapsed >= source.durations[frameIndex],
        guardrail < source.frameCount
      {
        elapsed -= source.durations[frameIndex]
        frameIndex = (frameIndex + 1) % source.frameCount
        guardrail += 1
      }
      if let image = source.frame(at: frameIndex) {
        layer.contents = image
      }
    }

    override func didMoveToWindow() {
      super.didMoveToWindow()
      if window == nil {
        stop()
      } else if isPlaying {
        start()
      }
    }

    deinit { link?.invalidate() }
  }
#elseif os(macOS)
  final class AnimatedImagePlayerView: NSView {
    private var source: AnimatedImageFrameSource?
    private var link: CADisplayLink?
    private var frameIndex = 0
    private var elapsed: TimeInterval = 0

    private var staticSize: CGSize?

    var naturalSize: CGSize? {
      if let source, source.pixelSize.width > 0, source.pixelSize.height > 0 {
        return source.pixelSize
      }
      return staticSize
    }

    func displayStatic(_ image: CGImage) {
      stop()
      source = nil
      staticSize = CGSize(width: image.width, height: image.height)
      layer?.contents = image
      invalidateIntrinsicContentSize()
    }

    var isPlaying: Bool = true {
      didSet {
        guard isPlaying != oldValue else { return }
        isPlaying ? start() : stop()
      }
    }

    override init(frame frameRect: NSRect) {
      super.init(frame: frameRect)
      wantsLayer = true
      layer?.contentsGravity = .resizeAspect
      layer?.masksToBounds = true
    }

    required init?(coder: NSCoder) {
      super.init(coder: coder)
      wantsLayer = true
      layer?.contentsGravity = .resizeAspect
      layer?.masksToBounds = true
    }

    func configure(with newSource: AnimatedImageFrameSource) {
      guard source !== newSource else { return }
      stop()
      source = newSource
      frameIndex = 0
      elapsed = 0
      newSource.prefetchIfAffordable()
      layer?.contents = newSource.frame(at: 0)
      invalidateIntrinsicContentSize()
      if isPlaying { start() }
    }

    private func start() {
      guard let source, source.isAnimated, link == nil, window != nil else {
        return
      }
      // view must be in a window
      let link = displayLink(target: self, selector: #selector(step(_:)))
      link.add(to: .main, forMode: .common)
      self.link = link
    }

    func stop() {
      link?.invalidate()
      link = nil
    }

    @objc private func step(_ link: CADisplayLink) {
      advance(by: link.targetTimestamp - link.timestamp)
    }

    private func advance(by delta: TimeInterval) {
      guard let source, source.isAnimated, source.totalDuration > 0 else {
        return
      }
      elapsed += delta
      var guardrail = 0
      while elapsed >= source.durations[frameIndex],
        guardrail < source.frameCount
      {
        elapsed -= source.durations[frameIndex]
        frameIndex = (frameIndex + 1) % source.frameCount
        guardrail += 1
      }
      if let image = source.frame(at: frameIndex) {
        layer?.contents = image
      }
    }

    override func viewDidMoveToWindow() {
      super.viewDidMoveToWindow()
      if window == nil {
        stop()
      } else if isPlaying {
        start()
      }
    }

    deinit { link?.invalidate() }
  }
#endif

// MARK: - Imperative loading

extension PlatformImage {
  var displayCGImage: CGImage? {
    #if os(macOS)
      return cgImage(forProposedRect: nil, context: nil, hints: nil)
    #else
      return cgImage
    #endif
  }
}

extension AnimatedImagePlayerView {

  /// Drop-in replacement for `sd_setImage` but with Nuke.
  func load(url: URL, onReady: @escaping (CGSize) -> Void) {
    Task { @MainActor in
      guard
        let container = try? await ImagePipeline.shared
          .imageTask(with: url).response.container
      else { return }

      if let data = container.data,
        let frames = AnimatedImageFrameSource(
          data: data,
          utType: container.type?.rawValue as CFString?
        ),
        frames.isAnimated
      {
        configure(with: frames)
      } else if let image = container.image.displayCGImage {
        displayStatic(image)
      } else {
        return
      }

      if let size = naturalSize { onReady(size) }
    }
  }
}
