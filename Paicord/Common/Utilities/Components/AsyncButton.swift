//
//  AsyncButton.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 16/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SwiftUI

struct AsyncButton<Label>: View where Label: View {
	let action: @MainActor () async throws -> Void
	let `catch`: (Error) -> Void
	let label: () -> Label

	@State var task: Task<Void, Never>? = nil

	init(
		action: @escaping @MainActor @Sendable () async throws -> Void,
		`catch`: @escaping (Error) -> Void,
		@ViewBuilder label: @escaping () -> Label
	) {
		self.action = action
		self.catch = `catch`
		self.label = label
	}

	var body: some View {
		Button {
			if task == nil {
				task = Task {
					defer { task = nil }
					do {
						try await action()
					} catch {
						self.catch(error)
					}
				}
			}
		} label: {
			label()
				.opacity(task == nil ? 1 : 0.5)
		}
		.disabled(task != nil)
	}
}

extension AsyncButton where Label == Text {
	init(
		_ titleKey: LocalizedStringKey,
		action: @escaping @MainActor @Sendable () async throws -> Void,
		`catch`: @escaping (Error) -> Void
	) {
		self.init(action: action, catch: `catch`) {
			Text(titleKey)
		}
	}

	init<S>(
		_ title: S, action: @escaping @MainActor @Sendable () async throws -> Void,
		`catch`: @escaping (Error) -> Void
	)
	where S: StringProtocol {
		self.init(action: action, catch: `catch`) {
			Text(title)
		}
	}
}
