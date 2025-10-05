//
//  ChatView.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import Combine
import PaicordLib
import SDWebImageSwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

struct ChatView: View {
	var vm: ChannelStore
	@State private var isNearBottom = true
	@State private var isScrolling = false

	@State private var showChannelInfo = false

	@Environment(GatewayStore.self) var gw

	init(vm: ChannelStore) { self.vm = vm }

	@State private var text: String = ""

	var channelName: String {
		if let name = vm.channel?.name {
			return name
		} else if let ppl = vm.channel?.recipients {
			return ppl.map({
				$0.global_name ?? $0.username
			}).joined(separator: ", ")
		}
		return "Unknown Channel"
	}

	var body: some View {
		ScrollViewReader { proxy in
			List {
				ForEach(vm.messages.values) { msg in
					// check if prior message is from same author and within 5 minutes, and ensure there are no replies
					let priorMessage = vm.getMessage(before: msg)
					let isInline =
						priorMessage?.author?.id == msg.author?.id
						&& msg.timestamp.date.timeIntervalSince(
							priorMessage?.timestamp.date ?? Date.distantPast
						) < 300 && msg.referenced_message == nil
					MessageCell(for: msg, inline: isInline)
				}
				.listRowInsets(.init())  // remove padding
				.listRowSeparator(.hidden)  // hide divider
				.listRowBackground(Color.clear)  // make background clear
			}
			.listStyle(.plain)
			.defaultScrollAnchor(.bottom)
			.onAppear {
				proxy.scrollTo(vm.messages.values.last?.id, anchor: .bottom)
			}
			.onChange(of: vm.messages) {
				if isNearBottom && !isScrolling {
					proxy.scrollTo(vm.messages.values.last?.id, anchor: .bottom)
				}
			}
			.background(.tableBackground)
			.detectScrollStates(
				isNearBottom: $isNearBottom,
				isScrolling: $isScrolling
			)
			.safeAreaInset(edge: .bottom) {
				TextField(
					"Message #\(channelName)",
					text: $text
				)
				.textFieldStyle(.roundedBorder)
				.onSubmit {
					let text = self.text
					self.text = ""
					Task {
						try await gw.client.createMessage(
							channelId: vm.channelId,
							payload: .init(content: text)
						)
					}
				}
			}
		}
		.scrollContentBackground(.hidden)
		.scrollDismissesKeyboard(.interactively)
		.toolbar {
			ToolbarItem(placement: .navigation) {
				if let name = vm.channel?.name {
					Text(name)
				} else if let ppl = vm.channel?.recipients {
					Text(
						ppl.map({
							$0.global_name ?? $0.username
						}).joined(separator: ", ")
					)
				}
				if let topic = vm.channel?.topic, !topic.isEmpty {
					Text(vm.channel?.topic ?? "")
						.font(.caption)
						.foregroundStyle(.secondary)
						.sheet(isPresented: $showChannelInfo) {
							Text(topic)
								.padding()
						}
				}
			}
		}
	}

	struct MessageCell: View {
		var message: DiscordChannel.Message
		var inline: Bool
		@State var profileOpen = false
		@State var avatarAnimated = false

		init(for message: DiscordChannel.Message, inline: Bool) {
			self.message = message
			self.inline = inline
		}

		var body: some View {
			if inline {
				HStack(alignment: .top) {
					Button {
					} label: {
						Text("")
							.frame(width: 35)
					}
					.buttonStyle(.borderless)
					.height(1)
					.disabled(true)  // btn used for spacing only

					content
				}
			} else {
				VStack {
					if let ref = message.referenced_message {
						HStack {
							// line thing
							//   ________  (pfp) <username> <content>
							//  /
							// |

							ReplyLine()
								.padding(.leading, 18)  // align with pfp

							Text("\(ref.author?.username ?? "Unknown") • \(ref.content)")
								.font(.caption)
								.foregroundStyle(.secondary)
								.lineLimit(1)
								.frame(maxWidth: .infinity, alignment: .leading)
						}
					}
					HStack(alignment: .top) {
						Button {
							profileOpen = true
						} label: {
							AnimatedImage(
								url: avatarURL(animated: avatarAnimated)
							)
							.resizable()
							.scaledToFill()
							.frame(width: 35, height: 35)
							.clipShape(.circle)
						}
						.buttonStyle(.borderless)
						.popover(isPresented: $profileOpen) {
							Text("Profile for \(message.author?.username ?? "Unknown")")
								.padding()
						}

						VStack {
							HStack {
								Text(message.author?.username ?? "Unknown")
									.font(.headline)
								Text(message.timestamp.date, style: .time)
									.font(.caption)
									.foregroundStyle(.secondary)
							}
							.frame(maxWidth: .infinity, alignment: .leading)

							content
						}
					}
				}
				.onHover { self.avatarAnimated = $0 }
				.padding(.top)
			}
		}

		@ViewBuilder
		var content: some View {
			#warning("make this show markdown")
			Text(markdown: message.content)
				.font(.body)
				.foregroundStyle(.primary)
				.frame(maxWidth: .infinity, alignment: .leading)
		}

		func avatarURL(animated: Bool) -> URL? {
			if let id = message.author?.id,
				let avatar = message.author?.avatar
			{
				if avatar.starts(with: "a_"), animated {
					return URL(
						string: CDNEndpoint.userAvatar(userId: id, avatar: avatar).url
							+ ".gif?size=128&animated=true"
					)
				} else {
					return URL(
						string: CDNEndpoint.userAvatar(userId: id, avatar: avatar).url
							+ ".png?size=128&animated=false"
					)
				}
			} else {
				let discrim = message.author?.discriminator ?? "0"
				return URL(
					string: CDNEndpoint.defaultUserAvatar(discriminator: discrim).url
						+ "?size=128"
				)
			}
		}

		struct ReplyLine: View {
			var body: some View {
				RoundedRectangle(cornerRadius: 5)
					.trim(from: 0.5, to: 0.75)
					.stroke(.gray.opacity(0.4), lineWidth: 2)
					.frame(width: 60, height: 20)
					.padding(.top, 8)
					.padding(.bottom, -12)
					.padding(.trailing, -30)
			}
		}
	}
}

extension View {
	func detectScrollStates(
		isNearBottom: Binding<Bool>,
		isScrolling: Binding<Bool>
	) -> some View {
		self.modifier(
			ScrollStateDetector(
				isNearBottom: isNearBottom,
				isScrolling: isScrolling
			)
		)
	}
}

struct ScrollStateDetector: ViewModifier {
	@Binding var isNearBottom: Bool
	@Binding var isScrolling: Bool
	@State private var cancellables = Set<AnyCancellable>()
	func body(content: Content) -> some View {
		content
			#if os(iOS)
				.introspect(.scrollView, on: .iOS(.v17...)) {
					(scrollView: UIScrollView) -> Void in
					// im really sorry
					DispatchQueue.main.async {
						cancellables.forEach { $0.cancel() }
						cancellables.removeAll()

						scrollView.publisher(for: \.contentOffset)
						.sink { offset in
							let bottomEdge = offset.y + scrollView.frame.size.height
							let distanceFromBottom =
								scrollView.contentSize.height - bottomEdge
							DispatchQueue.main.async {
								self.isNearBottom = distanceFromBottom < 100
							}
						}
						.store(in: &cancellables)

						let dragging = scrollView.publisher(for: \.isDragging)
						let decelerating = scrollView.publisher(for: \.isDecelerating)

						dragging.combineLatest(decelerating)
						.map { $0 || $1 }
						.removeDuplicates()
						.sink { scrolling in
							DispatchQueue.main.async {
								self.isScrolling = scrolling
							}
						}
						.store(in: &cancellables)
					}

				}
			#elseif os(macOS)
				.introspect(.scrollView, on: .macOS(.v14...)) {
					(scrollView: NSScrollView) -> Void in
					// im really sorry again
					DispatchQueue.main.async {
						cancellables.forEach { $0.cancel() }
						cancellables.removeAll()

						let clipView = scrollView.contentView
						NotificationCenter.default.publisher(
							for: NSView.boundsDidChangeNotification,
							object: clipView
						)
						.compactMap { (notification: Notification) -> CGPoint? in
							guard let clipView = notification.object as? NSClipView else {
								return nil
							}
							return clipView.bounds.origin
						}
						.sink { bounds in
							let contentHeight = scrollView.documentView?.frame.height ?? 0
							let visibleHeight = clipView.bounds.height
							let scrollOffset = bounds.y

							let bottomEdge = scrollOffset + visibleHeight
							let distanceFromBottom = contentHeight - bottomEdge

							DispatchQueue.main.async {
								self.isNearBottom = distanceFromBottom < 100
							}
						}
						.store(in: &cancellables)

						NotificationCenter.default.publisher(
							for: NSScrollView.willStartLiveScrollNotification,
							object: scrollView
						)
						.sink { _ in
							DispatchQueue.main.async {
								self.isScrolling = true
							}
						}
						.store(in: &cancellables)

						NotificationCenter.default.publisher(
							for: NSScrollView.didEndLiveScrollNotification,
							object: scrollView
						)
						.sink { _ in
							DispatchQueue.main.async {
								self.isScrolling = false
							}
						}
						.store(in: &cancellables)
					}
				}
			#endif
			.onDisappear {
				cancellables.forEach { $0.cancel() }
				cancellables.removeAll()
			}
	}
}

extension Text {
	init(
		markdown: String,
		fallback: AttributedString = "",
		syntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax =
			.inlineOnlyPreservingWhitespace
	) {
		self.init(
			(try? AttributedString(
				markdown: markdown,
				options: AttributedString.MarkdownParsingOptions(
					interpretedSyntax: syntax
				)
			)) ?? fallback
		)
	}
}
