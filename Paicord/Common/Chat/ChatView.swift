//
//  ChatView.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import Observation
import SwiftUI

//struct ChatView: View {
//	var viewModel = ChatViewModel()
//	var body: some View {
//		List {
//			ForEach(viewModel.messages) { message in
//				HStack {
//					Circle()
//						.fill(Color.blue)
//						.frame(width: 50, height: 50)
//					VStack(alignment: .leading) {
//						Text("User \(message.id.uuidString.prefix(4))")
//							.font(.headline)
//						Text(message.text)
//							.font(.subheadline)
//							.foregroundColor(.gray)
//					}
//					Spacer()
//					Text(message.date, style: .time)
//						.font(.caption)
//						.foregroundColor(.gray)
//				}
//				.padding(.vertical, 8)
//			}
////			Text("soon")
//		}
//		.scrollContentBackground(.hidden)
//		.background(.tableBackground)
//		.listStyle(.plain)
//	}
//}
//
//@Observable
//class ChatViewModel {
//	var messages: [Message] = [.init(text: "wagwan"), .init(text: "hello"), .init(text: "hi"), .init(text: "how are you?")]
//
//	func addMessage(_ text: String) {
//		messages.append(.init(text: "gm"))
//	}
//
//	struct Message: Identifiable {
//		let id = UUID()
//		let date: Date = .now
//		let text: String
//	}
//}
//
//#Preview {
//	ContentView()
//}

// MARK: - Simple Message model
struct Message: Identifiable {
	let id = UUID()
	let text: String
	let date: Date = .now
	let username: String = "User \(Int.random(in: 1...100))"
}

// MARK: - Tiny ViewModel
@Observable
@MainActor
final class ChatViewModel {
	var messages: [Message] = [
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
		Message(text: "gm"),
	]
	var latestMessageID: UUID? {
		messages.last?.id
	}

	init() {
		// Simulate new incoming messages every 2 seconds
		Task {
			let sample = [
				"test message 1",
				"test message 2",
				"test message 3",
				"test message 4",
				"test message 5",
				"test message 6",
				"test message 7",
			]

			while true {
				try? await Task.sleep(for: .seconds(.random(in: 0.5...2.5)))
				let msg = Message(text: sample.randomElement() ?? "...")
				messages.append(msg)
			}
		}
	}
}

// MARK: - ChatView
struct ChatView: View {
	private var vm = ChatViewModel()
	@State private var isNearBottom = true

	var body: some View {
		ScrollViewReader { proxy in
			List {
				ForEach(vm.messages) { msg in
					MessageCell(for: msg)
				}
				.listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))  // remove padding
				.listRowSeparator(.hidden)  // hide divider

				Color.clear
					.frame(height: 1)  // zero height
					.id("BOTTOM")
					.listRowInsets(EdgeInsets())  // remove padding
					.listRowSeparator(.hidden)  // hide divider
					.onAppear { self.isNearBottom = true }
					.onDisappear { self.isNearBottom = false }
					.padding(.top, -10)

			}
			.defaultScrollAnchor(.bottom)
			.scrollDismissesKeyboard(.interactively)
			.onAppear { proxy.scrollTo("BOTTOM", anchor: .bottom) }
			.onChange(of: vm.latestMessageID) {
				if isNearBottom {
					proxy.scrollTo("BOTTOM", anchor: .bottom)
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .navigation) {
				VStack(alignment: .leading) {
					Text("Title").font(.headline)
					Text("Subtitle").font(.subheadline)
				}
			}
		}
	}

	struct MessageCell: View {
		var message: Message
		@State var profileOpen = false

		init(for message: Message) {
			self.message = message
		}

		var body: some View {
			HStack {
				Button {
					profileOpen = true
				} label: {
					Circle()
						.scaledToFit()
						.frame(maxWidth: 35)
				}
				.buttonStyle(.borderless)
				.popover(isPresented: $profileOpen) {
					Text("Profile for \(message.username)")
						.padding()
				}

				VStack {
					HStack {
						Text(message.username)
							.font(.headline)
						Text(message.date, style: .time)
							.font(.caption)
							.foregroundStyle(.secondary)
					}
					.frame(maxWidth: .infinity, alignment: .leading)

					Text(message.text)
						.font(.body)
						.foregroundStyle(.primary)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
		}
	}
}

// MARK: - Preview
#Preview {
	ChatView()
}
