//
//  Test.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import SDWebImage
import SwiftUI

struct TestMessageView: View {
	var content: String
	var renderer: MessageRenderer = .init()

	var body: some View {
		Text(renderer.finalString)
			.task(id: content) {
				await renderer.update(content)
			}
	}
}

@Observable
class MessageRenderer {
	init() { }
	
	func update(_ rawContent: String) async {
		self.rawContent = rawContent
		createAST()
		self.finalString = render(ast: ())
	}
	
	func createAST() {
		
	}
	
	func render(ast: Void) -> AttributedString {
		return .init(rawContent)
	}
	
	private var rawContent: String = ""
	
	var finalString: AttributedString = "if you see this, it aint it pal"
}

#Preview {
	@Previewable @State var input = "hello **world**"
	@Previewable @State var content = "hello **world**"
	VStack {
		TextField("markdown", text: $input)
			.onSubmit {
				content = input
			}
		Divider()
		TestMessageView(content: content)
	}
	.frame(maxWidth: 230)
}
