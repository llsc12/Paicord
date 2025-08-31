//
//  ChatView.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 31/08/2025.
//

import Observation
import SwiftUI

struct ChatView: View {
	var viewModel = ChatViewModel()
	var body: some View {
		List {
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
			
			Text("soon")
		}
	}
}

@Observable
class ChatViewModel {
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
}

#Preview {
	ContentView()
}
