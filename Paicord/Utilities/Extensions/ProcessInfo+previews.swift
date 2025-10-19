//
//  ProcessInfo+previews.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 08/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation

extension ProcessInfo {
  static var isRunningInXcodePreviews: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  }
}
