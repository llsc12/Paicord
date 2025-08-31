//
//  PaiCordApp.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 31/08/2025.
//

import SwiftUI

@main
struct PaiCordApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
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
