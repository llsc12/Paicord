//
//  ChatView.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 31/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

struct ChatView: View {
	var vm: ChannelStore
	@Environment(GatewayStore.self) var gw
	@Environment(PaicordAppState.self) var appState
	@Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion

	@State private var text = ""

	@State private var showChannelInfo = false  // topic description popover
	@ViewStorage private var isNearBottom = true  // used to track if we are near the bottom, if so scroll.

	init(vm: ChannelStore) { self.vm = vm }

	var body: some View {
		VStack(spacing: 0) {
			ScrollViewReader { proxy in
				ScrollView {
					LazyVStack(alignment: .leading, spacing: 0) {
						ForEach(Array(vm.messages.values)) { msg in
							let prior = vm.getMessage(before: msg)
							MessageCell(for: msg, prior: prior, guild: vm.guildStore)
								.onAppear {
									guard msg == vm.messages.values.last else { return }
									self.isNearBottom = true
								}
								.onDisappear {
									guard msg == vm.messages.values.last else { return }
									self.isNearBottom = false
								}
						}
					}
					.scrollTargetLayout()
				}
				.defaultScrollAnchor(.bottom)
				.scrollDismissesKeyboard(.interactively)
				.onAppear {
					guard let lastID = vm.messages.values.last?.id else { return }
					DispatchQueue.main.async {
						withAnimation(accessibilityReduceMotion ? .none : .default) {
							proxy.scrollTo(lastID, anchor: .top)
						}
					}
				}
				.onChange(of: vm.messages.count) {
					if isNearBottom, let lastID = vm.messages.values.last?.id {
						DispatchQueue.main.async {
							withAnimation(accessibilityReduceMotion ? .none : .default) {
								proxy.scrollTo(lastID, anchor: .top)
							}
						}
					}
				}
			}
		}
		.safeAreaInset(edge: .bottom) {
			HStack {
				TextField("Message", text: $text)
					.textFieldStyle(.roundedBorder)
					#if os(iOS)
						.disabled(appState.chatOpen == false)
					#endif
					.onSubmit(sendMessage)
				#if os(iOS)
					if text.isEmpty == false {
						Button(action: sendMessage) {
							Image(systemName: "paperplane.fill")
								.imageScale(.large)
								.padding(5)
								.foregroundStyle(.white)
								.background(.primaryButton)
								.clipShape(.circle)
						}
						.buttonStyle(.borderless)
						.foregroundStyle(.primaryButton)
						.transition(.move(edge: .trailing).combined(with: .opacity))
					}
				#endif
			}
			.padding(5)
			.background(.regularMaterial)
		}
		.background(.tableBackground)
		.animation(.default.speed(2), value: text.isEmpty)
		#if os(iOS)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						appState.chatOpen.toggle()
					} label: {
						Image(systemName: "arrow.left")
					}
				}
			}
		#endif
		.toolbar {
			#warning("make channel headers nicer")
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

	private func sendMessage() {
		let msg = text.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !msg.isEmpty else { return }
		text = ""
		Task.detached {
			try await gw.client.createMessage(
				channelId: vm.channelId,
				payload: .init(content: msg)
			)
		}
	}
}

// it doesnt seem to want to let us push new messages and have the view scroll by itself.
struct TrackableScrollView<Content: View>: View {
	@Binding var isNearBottom: Bool
	@ViewBuilder var content: Content

	@State private var contentHeight: CGFloat = 0
	@State private var scrollViewHeight: CGFloat = 0
	@State private var scrollOffset: CGFloat = 0

	var body: some View {
		ScrollView {
			content
				.background(
					GeometryReader { proxy in
						Color.clear
							.onAppear { contentHeight = proxy.size.height }
							.onChange(of: proxy.size.height) {
								contentHeight = proxy.size.height
							}
					}
				)
		}
		.background(
			GeometryReader { proxy in
				Color.clear
					.onAppear { scrollViewHeight = proxy.size.height }
					.onChange(of: proxy.size.height) {
						scrollViewHeight = proxy.size.height
					}
			}
		)
		.overlay(
			GeometryReader { proxy in
				Color.clear
					.preference(
						key: ScrollOffsetKey.self,
						value: proxy.frame(in: .named("scroll")).minY
					)
			}
		)
		.coordinateSpace(name: "scroll")
		.onPreferenceChange(ScrollOffsetKey.self) { value in
			scrollOffset = -value
			let distanceFromBottom = contentHeight - scrollOffset - scrollViewHeight
			isNearBottom = distanceFromBottom < 150  // threshold
		}
	}
}
struct ScrollOffsetKey: PreferenceKey {
	static var defaultValue: CGFloat = 0
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
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
