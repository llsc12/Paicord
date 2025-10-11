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
				HStack {
					
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
