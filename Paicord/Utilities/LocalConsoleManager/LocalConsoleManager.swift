//
//  LocalConsoleManager.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 15/11/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation

//
//  StdOutInterceptor.swift
//  DiscordBotShell
//
//  Created by Lakhan Lothiyi on 23/09/2024.
//

class StdOutInterceptor {
  static let shared = StdOutInterceptor()

  private let stdoutPipe = Pipe()
  private let stderrPipe = Pipe()

  private var stdoutBackup: Int32?
  private var stderrBackup: Int32?

  private var stdoutReader: FileHandle?
  private var stderrReader: FileHandle?

  private var logBuffer: [LogItem] = []

  private var isActive = false

  private let queue = DispatchQueue(
    label: "com.llsc12.paicord.stdoutinterceptor"
  )

  private init() {}

  func items(from str: String, source: LogItem.LogType) -> [LogItem] {
    //    let lines = str.components(separatedBy: "\n")
    //    return lines.map { LogItem(str: $0, type: source) }
    [.init(str: str, type: source)]
  }

  // Add log items based on incoming stdout or stderr
  func _addLog(_ item: String, source: LogItem.LogType) {
    queue.async {
      guard self.isActive else { return }
      let new = self.items(from: item, source: source)
      self.logBuffer.append(contentsOf: new)
    }
  }

  func startIntercepting() {
    if ProcessInfo.processInfo.environment["DISABLE_STD_INTERCEPT"] == "1" {
      return
    }
      
    queue.sync {
      guard !self.isActive else { return }
      self.isActive = true

      // Backup original stdout and stderr
      self.stdoutBackup = dup(STDOUT_FILENO)
      self.stderrBackup = dup(STDERR_FILENO)

      // Redirect stdout and stderr to pipes
      dup2(self.stdoutPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
      dup2(self.stderrPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)

      // Disable C buffering
      setbuf(stdout, nil)
      setbuf(stderr, nil)

      self.stdoutReader = self.stdoutPipe.fileHandleForReading
      self.stderrReader = self.stderrPipe.fileHandleForReading

      // Handle stdout data
      self.stdoutReader?.readabilityHandler = { [weak self] handle in
        guard let self = self else { return }
        let data = handle.availableData
        if !data.isEmpty {
          let output = String(decoding: data, as: UTF8.self)
          let items = self.items(from: output, source: .out)
          // append new items to buffer on our queue
          self.queue.async {
            guard self.isActive else { return }
            self.logBuffer.append(contentsOf: items)
          }

          if let fd = self.stdoutBackup {
            data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
              var remaining = ptr.count
              var base = ptr.baseAddress
              while remaining > 0 {
                let written = Darwin.write(fd, base, remaining)
                if written <= 0 { break }
                remaining -= written
                if let advanced = base?.advanced(by: written) {
                  base = advanced
                }
              }
            }
          }

          DispatchQueue.main.async {
            NotificationCenter.default.post(name: .newLogAdded, object: items)
          }
        }
      }

      // Handle stderr data
      self.stderrReader?.readabilityHandler = { [weak self] handle in
        guard let self = self else { return }
        let data = handle.availableData
        if !data.isEmpty {
          let output = String(decoding: data, as: UTF8.self)
          let items = self.items(from: output, source: .err)
          self.queue.async {
            guard self.isActive else { return }
            self.logBuffer.append(contentsOf: items)
          }

          if let fd = self.stderrBackup {
            data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
              var remaining = ptr.count
              var base = ptr.baseAddress
              while remaining > 0 {
                let written = Darwin.write(fd, base, remaining)
                if written <= 0 { break }
                remaining -= written
                if let advanced = base?.advanced(by: written) {
                  base = advanced
                }
              }
            }
          }

          DispatchQueue.main.async {
            NotificationCenter.default.post(name: .newLogAdded, object: items)
          }
        }
      }
    }
  }

  func stopIntercepting() {
    queue.sync {
      guard self.isActive else { return }
      self.isActive = false

      // Remove readability handlers and close pipe file handles
      if let sr = self.stdoutReader {
        sr.readabilityHandler = nil
        sr.closeFile()
      }

      if let er = self.stderrReader {
        er.readabilityHandler = nil
        er.closeFile()
      }

      // Restore original stdout and stderr
      if let stdoutBackup = self.stdoutBackup {
        dup2(stdoutBackup, STDOUT_FILENO)
        // close the duplicated backup FD now that it's restored
        close(stdoutBackup)
        self.stdoutBackup = nil
      }
      if let stderrBackup = self.stderrBackup {
        dup2(stderrBackup, STDERR_FILENO)
        close(stderrBackup)
        self.stderrBackup = nil
      }

      // Close the write ends of the pipes we used for interception
      // (closing the write end will eventually cause EOF on the reader)
      self.stdoutPipe.fileHandleForWriting.closeFile()
      self.stderrPipe.fileHandleForWriting.closeFile()
      self.stdoutPipe.fileHandleForReading.closeFile()
      self.stderrPipe.fileHandleForReading.closeFile()
    }
  }

  struct LogItem: Identifiable, Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }

    let id: UUID = UUID()
    let str: String
    var type: LogType

    init(str: String, type: LogType) {
      // Extract and analyze OSLog metadata first
      let (metadata, cleanedLog) = LogItem.extractAndCleanMetadata(from: str)

      // Determine the log type based on the metadata
      self.type = LogItem.determineLogType(from: metadata, defaultType: type)

      // Set the cleaned-up log string
      self.str = cleanedLog
    }

    // Enum to represent the log type (stdout, warning, error)
    enum LogType {
      case out  // out
      case err  // error
      case flt  // fault
    }

    // Extracts the OSLog metadata and returns both the metadata and the cleaned-up log message
    static func extractAndCleanMetadata(from log: String) -> (
      metadata: String?, cleanedLog: String
    ) {
      // Regex to match OSLog metadata pattern (adjust based on actual format)
      let osLogRegex = #"OSLOG-[A-F0-9-]+.+?\{.+?\}"#

      // Try to find the metadata using the regex
      if let range = log.range(of: osLogRegex, options: .regularExpression) {
        let metadata = String(log[range])
        let cleanedLog = log.replacingOccurrences(of: metadata, with: "")
          .trimmingCharacters(in: .whitespacesAndNewlines)
        return (metadata: metadata, cleanedLog: cleanedLog)
      }

      return (metadata: nil, cleanedLog: log)
    }

    static func determineLogType(from metadata: String?, defaultType: LogType)
      -> LogType
    {
      guard let metadata = metadata else { return defaultType }

      if metadata.localizedCaseInsensitiveContains("fault") {
        return .flt
      }

      if metadata.localizedCaseInsensitiveContains("error") {
        return .err
      }

      return defaultType
    }
  }

  func getLogs() -> [LogItem] {
    var copied: [LogItem] = []
    queue.sync {
      self.logBuffer = self.logBuffer.compactMap {
        $0.str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
          ? nil : $0
      }
      copied = self.logBuffer
    }
    return copied
  }
}

extension Notification.Name {
  static let newLogAdded = Notification.Name("newLogAdded")
}
