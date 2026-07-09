//
//  CookieStore.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 10/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import NIOHTTP1

public struct Cookie: Codable, Sendable {
  public let name: String
  public let value: String
  public let domain: String
  public let path: String
  public let expires: Date?
  public let secure: Bool

  public var isExpired: Bool {
    guard let expires = expires else { return false }
    return expires < Date()
  }

  // Returns the string format for the "Cookie" request header
  public var headerString: String {
    return "\(name)=\(value)"
  }
}

@usableFromInline
actor CookieStore {
  private var cookies: [String: Cookie] = [:]

  // gets cookies
  @usableFromInline
  func checkIncomingHeaders(_ headers: HTTPHeaders) {
    for header in headers[canonicalForm: "set-cookie"] {  // canonicalForm gets like the raw header field (commas and stuff)
      let header = String(header)
      if let cookie = self.parseSetCookie(header) {
        cookies[cookie.name] = cookie
      }
    }
  }

  func checkIncomingHeaders(_ headers: [String: String]) {
    for (key, value) in headers where key.lowercased() == "set-cookie" {
      if let cookie = parseSetCookie(value) {
        cookies[cookie.name] = cookie
      }
    }
  }

  @usableFromInline
  func applyCookies(to headers: inout HTTPHeaders) {
    // Drop expired before sending
    cookies = cookies.filter { !$0.value.isExpired }
    guard !cookies.isEmpty else { return }

    let cookieHeader = cookies.values
      .map { "\($0.name)=\($0.value)" }
      .joined(separator: "; ")

    headers.add(name: "Cookie", value: cookieHeader)
  }

  private func parseSetCookie(_ header: String) -> Cookie? {
    let parts = header.components(separatedBy: ";").map {
      $0.trimmingCharacters(in: .whitespaces)
    }
    guard let firstPart = parts.first,
      let eqIndex = firstPart.firstIndex(of: "=")
    else { return nil }

    let name = String(firstPart[..<eqIndex])
    let value = String(firstPart[firstPart.index(after: eqIndex)...])

    var domain = "discord.com"
    var path = "/"
    var expires: Date? = nil
    var secure = false

    for part in parts.dropFirst() {
      let lower = part.lowercased()
      if lower.hasPrefix("domain=") {
        domain = String(part.dropFirst(7))
      } else if lower.hasPrefix("path=") {
        path = String(part.dropFirst(5))
      } else if lower.hasPrefix("expires=") {
        expires = parseDate(String(part.dropFirst(8)))
      } else if lower == "secure" {
        secure = true
      }
    }

    return Cookie(
      name: name,
      value: value,
      domain: domain,
      path: path,
      expires: expires,
      secure: secure
    )
  }

  private func parseDate(_ dateStr: String) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(abbreviation: "GMT")
    let formats = ["E, dd MMM yyyy HH:mm:ss Z", "EEEE, dd-MMM-yy HH:mm:ss Z"]
    for format in formats {
      formatter.dateFormat = format
      if let date = formatter.date(from: dateStr) { return date }
    }
    return nil
  }
}
