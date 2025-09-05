//
//  PaiCordApp.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 31/08/2025.
//

import SwiftUI
import SDWebImageSVGCoder

@main
struct PaiCordApp: App {
  init() {
	let SVGCoder = SDImageSVGCoder.shared
	SDImageCodersManager.shared.addCoder(SVGCoder)
  }
	var body: some Scene {
		WindowGroup {
		  Group {
			//			ContentView()
			LoginView()
		  }
		  .fontDesign(.rounded)
		}
		.windowStyle(.hiddenTitleBar)
	}
}

struct ContentView: View {
	var body: some View {
		#if os(iOS)
			SmallBaseplate()
		#else
			LargeBaseplate()
		#endif
	}
}

#Preview {
	ContentView()
}
