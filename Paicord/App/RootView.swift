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
  @State var appState: PaicordAppState = .init()
  @Environment(\.challenges) var challenges
  @Environment(\.userInterfaceIdiom) var idiom
  @Environment(\.horizontalSizeClass) var hSizeClass

  #if os(macOS)
    @Weak var window: NSWindow?
  #endif

  #if os(iOS)
    @ViewStorage var hasLaunchedAlready: Bool = false
  #endif

  #if os(iOS)
    var isConnecting: Bool {
      hasLaunchedAlready == false && gatewayStore.state != .connected
    }
  #else
    var isConnecting: Bool {
      gatewayStore.state != .connected
    }
  #endif

  var body: some View {
    Group {
      if gatewayStore.accounts.currentAccountID == nil {
        LoginView()
          .tint(.primary)  // text tint in buttons etc.
      } else if isConnecting {
        ConnectionStateView(state: gatewayStore.state)
          .transition(.opacity.combined(with: .scale(scale: 1.1)))
          .task { await gatewayStore.connectIfNeeded() }
      } else {
        Group {
          if idiom == .phone || (idiom == .pad && hSizeClass == .compact) {
            #if os(iOS)
              SmallBaseplate(appState: self.appState)
            #endif
          } else {
            LargeBaseplate()
          }
        }
        .quickSwitcher()
        .sponsorSheet()
        .updateSheet()
        .task {
          appState.loadPrevGuild()
          #if os(iOS)
            self.hasLaunchedAlready = true
          #endif
        }
      }
    }
    .environment(\.appState, appState)
    .focusedSceneValue(\.appState, appState)
    .navigationTitle(Text(verbatim: ""))
    .animation(.default, value: gatewayStore.state.hashValue)
    .fontDesign(.rounded)
    .modifier(
      PaicordSheetsAlerts(
        gatewayStore: gatewayStore,
        appState: appState,
        challenges: challenges!  // always exists, ref made in PaicordApp.swift
      )
    )
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
    #else
      .onChange(of: gatewayStore.accounts.currentAccountID) {
        if gatewayStore.accounts.currentAccountID == nil {
          self.hasLaunchedAlready = false  // when logged out, allow connection screen. else connection wont be attempted.
        }
      }
    #endif
  }

  // MARK: - Gateway Callbacks

  private func setupGatewayCallbacks() {
    gatewayStore.captchaCallback = { captcha in
      await challenges?.presentCaptcha(captcha)
    }
    gatewayStore.mfaCallback = { mfaData in
      await challenges?.presentMFA(mfaData)
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
