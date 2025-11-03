//
//  RootView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

// Handles using phone suitable layout or desktop suitable layout

struct RootView: View {
  let gatewayStore: GatewayStore
  @Bindable var appState: PaicordAppState
  @Environment(Challenges.self) var challenges
  @Environment(\.userInterfaceIdiom) var idiom

  #if os(macOS)
    @Weak var window: NSWindow?
  #endif

  var body: some View {
    Group {
      if gatewayStore.accounts.currentAccountID == nil {
        LoginView()
          .tint(.primary) // text tint in buttons etc.
          .environment(gatewayStore)
          .environment(appState)
      } else if gatewayStore.state != .connected {
        ConnectionStateView(state: gatewayStore.state)
          .transition(.opacity.combined(with: .scale(scale: 1.1)))
          .task { await gatewayStore.connectIfNeeded() }
      } else {
        if idiom == .phone {
          #if os(iOS)
            SmallBaseplate(appState: self.appState)
          #endif
        } else {
          LargeBaseplate()
        }
      }
    }
    .navigationTitle("")
    .animation(.default, value: gatewayStore.state.hashValue)
    .fontDesign(.rounded)
    .modifier(
      PaicordSheetsAlerts(
        gatewayStore: gatewayStore,
        appState: appState
      )
    )
    .environment(gatewayStore)
    .environment(appState)
    .onAppear { setupGatewayCallbacks() }
    #if os(macOS)
      .introspect(.window, on: .macOS(.v14...)) { window in
        self.window = window
        DispatchQueue.main.async {
          updateWindow(window)
        }
      }
      .onAppear {
        DispatchQueue.main.async {
          updateWindow(window)
        }
      }
      .onChange(of: gatewayStore.accounts.currentAccountID) {
        DispatchQueue.main.async {
          updateWindow(window)
        }
      }
    #endif
  }

  // MARK: - Gateway Callbacks

  private func setupGatewayCallbacks() {
    gatewayStore.captchaCallback = { captcha in
      await challenges.presentCaptcha(captcha)
    }
    gatewayStore.mfaCallback = { mfaData in
      await challenges.presentMFA(mfaData)
    }
  }

  // MARK: - Helpers
  #if os(macOS)
    func updateWindow(_ window: NSWindow?) {
      guard let window else { return }
      // copy swiftui's windowStyle hidden title bar style if we are logging in (currentAccountID is nil)
      if gatewayStore.accounts.currentAccountID == nil {
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
      } else {
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
      }
    }
  #endif
}
