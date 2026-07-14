//
//  ContinuationBox.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 13/07/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation

final class ContinuationBox<Value: Sendable>: @unchecked Sendable {
  private let lock = NSLock()
  private var continuations: [AsyncStream<Value>.Continuation] = []

  func append(_ continuation: AsyncStream<Value>.Continuation) {
    lock.lock()
    continuations.append(continuation)
    lock.unlock()
  }

  func yieldToAll(_ value: Value) {
    lock.lock()
    let current = continuations
    lock.unlock()
    for continuation in current {
      continuation.yield(value)
    }
  }
}
