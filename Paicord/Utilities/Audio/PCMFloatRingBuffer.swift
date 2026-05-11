//
//  PCMFloatRingBuffer.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 11/03/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import AVFoundation

/// Efficient ring buffer for PCM float data from microphone.
struct PCMFloatRingBuffer {
  let channels: Int
  let capacityFrames: Int
  private var storage: [[Float]]
  private var readIndex: Int = 0
  private var writeIndex: Int = 0
  private(set) var availableFrames: Int = 0

  init(channels: Int, capacityFrames: Int) {
    self.channels = channels
    self.capacityFrames = capacityFrames
    self.storage = (0..<channels).map { _ in
      Array(repeating: 0, count: capacityFrames)
    }
  }

  mutating func write(
    from src: UnsafePointer<UnsafeMutablePointer<Float>>,
    frames: Int,
    srcChannels: Int
  ) {
    guard frames > 0 else { return }

    // keep tail if overflow.
    let framesToWrite = min(frames, capacityFrames)
    let dropHead = max(0, availableFrames + framesToWrite - capacityFrames)
    if dropHead > 0 { discard(frames: dropHead) }

    let start = frames - framesToWrite

    for i in 0..<framesToWrite {
      let dstIdx = (writeIndex + i) % capacityFrames

      if srcChannels == 1 && channels >= 2 {
        let s = src[0][start + i]
        storage[0][dstIdx] = s
        storage[1][dstIdx] = s
      } else {
        for ch in 0..<channels {
          let srcCh = min(ch, srcChannels - 1)
          storage[ch][dstIdx] = src[srcCh][start + i]
        }
      }
    }

    writeIndex = (writeIndex + framesToWrite) % capacityFrames
    availableFrames += framesToWrite
  }

  mutating func read(
    into dst: UnsafePointer<UnsafeMutablePointer<Float>>,
    frames: Int
  ) -> Bool {
    guard frames <= availableFrames else { return false }

    for i in 0..<frames {
      let srcIdx = (readIndex + i) % capacityFrames
      for ch in 0..<channels {
        dst[ch][i] = storage[ch][srcIdx]
      }
    }

    readIndex = (readIndex + frames) % capacityFrames
    availableFrames -= frames
    return true
  }

  mutating func discard(frames: Int) {
    let d = min(frames, availableFrames)
    readIndex = (readIndex + d) % capacityFrames
    availableFrames -= d
  }
}
