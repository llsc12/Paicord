//
//  MFASheet.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 11/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUI

struct MFASheet: View {
	let verificationData: MFAVerificationData
	let onToken: (MFAResponse) -> Void

	@State var mfaTask: Task<Void, Never>? = nil
	@State var taskInProgress: Bool = false

	@State var chosenMethod: MFAVerificationData.MFAMethod? = nil
	@State var input = ""
	var body: some View {
		ZStack {
			VStack {
				Text("Multi-Factor Authentication")
					.font(.title2)
					.bold()
				Text("An action required MFA to continue.")

				VStack {
					if chosenMethod == nil {
						ForEach(verificationData.methods, id: \.type) { method in
							Button {
								chosenMethod = method
							} label: {
								userFriendlyName(for: method.type)
									.frame(maxWidth: .infinity)
									.padding(10)
									.background(.primaryButton)
									.clipShape(.rounded)
									.font(.title3)
							}
							.buttonStyle(.borderless)
						}
						.transition(.offset(x: -100).combined(with: .opacity))
					}
					if chosenMethod != nil {
						form
							.transition(.offset(x: 100).combined(with: .opacity))
					}
				}
				.padding(25)
			}

			VStack {
				Spacer()
				Text(
					"Further MFA restricted actions will be allowed for the next 5 minutes."
				)
				.font(.footnote)
				.foregroundStyle(.secondary)
			}
		}
		.padding(.top, 15)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(.appBackground)
		.overlay(alignment: .topLeading) {
			if chosenMethod != nil {
				Button {
					chosenMethod = nil
					input = ""
				} label: {
					// chevron left
					Image(systemName: "chevron.left")
						.padding(5)
						.background(.primaryButtonBackground)
						.clipShape(.circle)
				}
				.buttonStyle(.borderless)
				.padding()
			}
		}
		.animation(.default, value: chosenMethod == nil)
	}

	func userFriendlyName(for type: MFAVerificationData.MFAMethod.MFAKind) -> (
		some View
	)? {
		return switch type {
		case .sms:
			Label("SMS", systemImage: "message")
		case .totp:
			Label("Authenticator App", systemImage: "lock.rotation")
		case .backup:
			Label("Backup Code", systemImage: "key")
		case .password:
			Label("Password", systemImage: "lock")
		default: nil
		}
	}

	@ViewBuilder
	var form: some View {
		if let chosenMethod {
			switch chosenMethod.type {
			case .totp:
				VStack {
					Text("Enter your authentication code")
						.foregroundStyle(.secondary)
						.font(.caption)

					SixDigitInput(input: $input) {
						let input = $0
						self.taskInProgress = true
						self.mfaTask = .init {
							defer { self.taskInProgress = false }
							try? await Task.sleep(for: .seconds(2))
							print("auth \(input)")
						}
					}
					.disabled(taskInProgress)
				}
			default: Text("wip bro go do totp")
			}
		}
	}
}

#Preview {
	MFASheet(
		verificationData: .init(
			ticket: "gm",
			methods: [
				.init(
					type: .totp,
					backup_codes_allowed: false
				),
				.init(
					type: .sms
				),
			]
		)
	) {
		response in
		print(response)
	}
	.frame(width: 400, height: 300)
	.fontDesign(.rounded)
}

struct SixDigitInput: View {
	// check if view was disabled with environment values
	@Environment(\.isEnabled) var enabled

	@Binding var input: String
	let onCommit: (String) -> Void
	@FocusState var textfield
	
	var body: some View {
		HStack(spacing: 10) {
			ForEach(0..<6, id: \.self) { index in
				ZStack {
					let prevCharacter = character(at: index - 1)
					let character = character(at: index)
					RoundedRectangle(cornerRadius: 8)
						.stroke(
							(textfield && enabled)
								? (character.isEmpty && !prevCharacter.isEmpty
									? .hyperlink : .gray) : .gray, lineWidth: 1
						)
						.frame(width: 40, height: 50)
					if character.isEmpty && !prevCharacter.isEmpty && enabled {
						BlinkingCursor()
					} else {
						Text(verbatim: character)
							.font(.title)
					}
				}
			}
		}
		.opacity(enabled ? 1 : 0.25)
		.onTapGesture {
			textfield = true
		}
		.onAppear {
			textfield = true
		}
		.background(.appBackground.opacity(0.001))
		.background(
			TextField("", text: $input)
				.textContentType(.oneTimeCode)
				.opacity(0.01)
				.onChange(of: input) {
					let filtered = input.filter { $0.isNumber }
					if filtered.count > 6 {
						input = String(filtered.prefix(6))
					} else {
						input = filtered
					}
					if input.count == 6 {
						onCommit(input)
					}
				}
				.frame(width: 0, height: 0)
				.focused($textfield)
				.disabled(!enabled)  // redundant but whatevs
		)
	}

	struct BlinkingCursor: View {
		@State var blink = true
		var body: some View {
			Text("|")
				.font(.title)
				.opacity(blink ? 1 : 0)
				.onAppear {
					withAnimation(
						.easeInOut(duration: 0.15).delay(0.3).repeatForever(
							autoreverses: true)
					) {
						blink = false
					}
				}
		}
	}

	func character(at index: Int) -> String {
		// double check that the index isnt sub 0, if it is just return "0" so the first box can have cursor blink
		if index < 0 {
			return "0"
		}
		if index < input.count {
			let charIndex = input.index(input.startIndex, offsetBy: index)
			return String(input[charIndex])
		}
		return ""
	}
}
