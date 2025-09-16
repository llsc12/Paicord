//
//  CookieStore.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 10/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import NIOHTTP1

@usableFromInline
actor CookieStore {
	var cookies: [String: HTTPCookie] = [:]

	// gets cookies
	@usableFromInline
	func checkIncomingHeaders(_ headers: HTTPHeaders) {
		for header in headers[canonicalForm: "set-cookie"] {  // canonicalForm gets like the raw header field (commas and stuff)
			let header = String(header)
			if let cookie = HTTPCookie(fromSetCookieString: header) {
				var finalCookie = cookie
				if cookie.expiresDate == nil, let customExpiry = parseExpires(header) {
					// idk why foundation doesnt parse expiry date
					if let rebuilt = HTTPCookie(properties: [
						.name: cookie.name,
						.value: cookie.value,
						.domain: cookie.domain,
						.path: cookie.path,
						.expires: customExpiry,
						.secure: cookie.isSecure,
					]) {
						finalCookie = rebuilt
					}
				}
				cookies[finalCookie.name] = finalCookie
			}
		}
	}

	// applies cookies
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

	private func parseExpires(_ setCookie: String) -> Date? {
		guard let range = setCookie.range(of: "expires=", options: .caseInsensitive)
		else { return nil }
		let dateStr = setCookie[range.upperBound...].split(
			separator: ";", maxSplits: 1
		).first?.trimmingCharacters(in: .whitespaces)
		if let dateStr {
			let formatter = DateFormatter()
			formatter.locale = Locale(identifier: "en_US_POSIX")
			formatter.timeZone = TimeZone(abbreviation: "GMT")
			formatter.dateFormat = "E, dd-MMM-yy HH:mm:ss zzz"
			return formatter.date(from: dateStr)
		}
		return nil
	}

}
extension HTTPCookie {
	convenience init?(fromSetCookieString string: String) {
		let cookies = HTTPCookie.cookies(
			withResponseHeaderFields: ["Set-Cookie": string],
			for: URL(string: "https://discord.com")!
		)

		guard let cookie = cookies.first,
			let new = HTTPCookie(properties: [
				.name: cookie.name,
				.value: cookie.value,
				.domain: cookie.domain,
				.path: cookie.path,
				.version: cookie.version,
			])
		else {
			return nil
		}

		self.init(properties: [
			.name: new.name,
			.value: new.value,
			.domain: new.domain,
			.path: new.path,
			.version: new.version,
		])!
	}
}

extension HTTPCookie {
	var isExpired: Bool {
		if let expiry = expiresDate {
			return expiry < Date.now
		}
		return false
	}
}
