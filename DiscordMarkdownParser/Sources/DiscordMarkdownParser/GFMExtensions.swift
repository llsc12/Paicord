/// GitHub Flavored Markdown (GFM) extensions
///
/// This file implements GFM extensions including tables, task lists, strikethrough,
/// and autolinks as specified in the GitHub Flavored Markdown Spec.
import Foundation

// MARK: - GFM Utilities

/// Utilities for GitHub Flavored Markdown parsing
public enum GFMUtils {

	/// Check if text contains strikethrough
	public static func containsStrikethrough(_ text: String) -> Bool {
		return text.contains("~~")
	}

	/// Parse strikethrough spans in text
	public static func parseStrikethrough(_ text: String)
		-> [GFMStrikethroughSpan]
	{
		var spans: [GFMStrikethroughSpan] = []
		var currentIndex = text.startIndex

		while currentIndex < text.endIndex {
			// Find next ~~
			guard
				let startRange = text.range(
					of: "~~", range: currentIndex..<text.endIndex)
			else {
				break
			}

			let afterStart = startRange.upperBound

			// Find closing ~~
			guard
				let endRange = text.range(of: "~~", range: afterStart..<text.endIndex)
			else {
				break
			}

			let content = String(text[afterStart..<endRange.lowerBound])

			// Strikethrough cannot be empty or contain only whitespace
			if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				let span = GFMStrikethroughSpan(
					range: startRange.lowerBound..<endRange.upperBound,
					content: content
				)
				spans.append(span)
			}

			currentIndex = endRange.upperBound
		}

		return spans
	}

	/// Check if text contains autolinks
	public static func containsAutolinks(_ text: String) -> Bool {
		return text.contains("http://") || text.contains("https://")
			|| text.contains("www.") || text.contains("@")
	}

	/// Parse autolinks in text
	public static func parseAutolinks(_ text: String) -> [GFMAutolinkSpan] {
		var spans: [GFMAutolinkSpan] = []

		// Parse URL autolinks
		spans.append(contentsOf: parseURLAutolinks(text))

		// Parse email autolinks
		spans.append(contentsOf: parseEmailAutolinks(text))

		return spans.sorted { $0.range.lowerBound < $1.range.lowerBound }
	}

	/// Parse URL autolinks
	static func parseURLAutolinks(_ text: String) -> [GFMAutolinkSpan] {
		var spans: [GFMAutolinkSpan] = []
		let urlPattern = #"(https?://[^\s<>\[\]]+)"#

		do {
			let regex = try NSRegularExpression(pattern: urlPattern, options: [])
			let matches = regex.matches(
				in: text, options: [], range: NSRange(location: 0, length: text.count))

			for match in matches {
				if let range = Range(match.range, in: text) {
					let url = String(text[range])
					let span = GFMAutolinkSpan(
						range: range,
						url: url,
						type: .url
					)
					spans.append(span)
				}
			}
		} catch {
			// Regex failed, skip URL autolinks
		}

		return spans
	}

	/// Parse email autolinks
	static func parseEmailAutolinks(_ text: String) -> [GFMAutolinkSpan] {
		var spans: [GFMAutolinkSpan] = []
		let emailPattern = #"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"#

		do {
			let regex = try NSRegularExpression(pattern: emailPattern, options: [])
			let matches = regex.matches(
				in: text, options: [], range: NSRange(location: 0, length: text.count))

			for match in matches {
				if let range = Range(match.range, in: text) {
					let email = String(text[range])
					let span = GFMAutolinkSpan(
						range: range,
						url: "mailto:" + email,
						type: .email
					)
					spans.append(span)
				}
			}
		} catch {
			// Regex failed, skip email autolinks
		}

		return spans
	}
}

// MARK: - GFM Data Types

/// Strikethrough span information for GFM
public struct GFMStrikethroughSpan: Sendable, Equatable {
	/// Range in the original text
	public let range: Range<String.Index>

	/// Content within the strikethrough
	public let content: String
}

/// Autolink span information for GFM
public struct GFMAutolinkSpan: Sendable, Equatable {
	/// Range in the original text
	public let range: Range<String.Index>

	/// The URL (including mailto: for emails)
	public let url: String

	/// Type of autolink
	public let type: GFMAutolinkType
}

/// Type of autolink for GFM
public enum GFMAutolinkType: String, Sendable, CaseIterable {
	case url = "url"
	case email = "email"
	// TODO: change this
}

// MARK: - GFM AST Node Extensions (using nodes defined in AST.swift)

// MARK: - GFM Block Parser Extensions

// MARK: - GFM Inline Parser Extensions

extension InlineParser {

	/// Parse GFM strikethrough
	func parseGFMStrikethrough(_ text: String) -> [AST.StrikethroughNode] {
		let spans = GFMUtils.parseStrikethrough(text)
		return spans.map { span in
			AST.StrikethroughNode(
				content: [AST.TextNode(content: span.content)],
				sourceLocation: nil
			)
		}
	}

	/// Parse GFM autolinks
	func parseGFMAutolinks(_ text: String) -> [AST.AutolinkNode] {
		let spans = GFMUtils.parseAutolinks(text)
		return spans.map { span in
			AST.AutolinkNode(
				url: span.url,
				text: span.type == .email ? String(span.url.dropFirst(7)) : span.url,  // Remove "mailto:" for display
				sourceLocation: nil
			)
		}
	}
}
