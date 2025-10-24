//
//  PaicordApp.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 31/08/2025.
//  Copyright © 2025 Lakhan Lothiyi. All rights reserved.
//

import Logging
import PaicordLib
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX

#if canImport(Sparkle)
  import Sparkle
#endif

#if canImport(FLEX)
  import FLEX
#endif

@main
struct PaicordApp: App {
  let gatewayStore = GatewayStore.shared
  var appState = PaicordAppState.shared
  var challenges = Challenges()

  @Environment(\.userInterfaceIdiom) var idiom

  init() {
    //     i foubnd out this rly cool thing if u avoid logging 40mb of data to console the client isnt slow !!!!
    //    #if DEBUG
    //      DiscordGlobalConfiguration.makeLogger = { loggerLabel in
    //        var logger = Logger(label: loggerLabel)
    //        logger.logLevel = .trace
    //        return logger
    //      }
    //    #endif
    //    #if os(macOS)
    //      updaterController = SPUStandardUpdaterController(
    //        startingUpdater: true,
    //        updaterDelegate: nil,
    //        userDriverDelegate: nil
    //      )
    //    #endif
  }

  //  private let updaterController: SPUStandardUpdaterController

  var body: some Scene {
    WindowGroup {
      RootView(
        gatewayStore: gatewayStore,
        appState: appState
      )
      .onAppear {
        #if canImport(FLEX)
          FLEXManager.shared.showExplorer()
        #endif
      }
    }
    #if os(macOS)
      .windowToolbarStyle(.unified)
    //      .commands {
    //        CommandGroup(after: .appInfo) {
    //          CheckForUpdatesView(updater: updaterController.updater)
    //        }
    //      }
    #endif
    .commands { AccountCommands(gatewayStore: gatewayStore) }
    .environment(challenges)
    .environment(appState)
    .environment(gatewayStore)

    #if os(macOS)
      Settings {
        SettingsView()
          .environment(gatewayStore)
          .environment(appState)
      }
    #endif
  }
}

// https://sparkle-project.org/documentation/programmatic-setup/

//#if os(macOS)
//  final class CheckForUpdatesViewModel: ObservableObject {
//    @Published var canCheckForUpdates = false
//
//    init(updater: SPUUpdater) {
//      updater.publisher(for: \.canCheckForUpdates)
//        .assign(to: &$canCheckForUpdates)
//    }
//  }
//
//  // This is the view for the Check for Updates menu item
//  // Note this intermediate view is necessary for the disabled state on the menu item to work properly before Monterey.
//  // See https://stackoverflow.com/questions/68553092/menu-not-updating-swiftui-bug for more info
//  struct CheckForUpdatesView: View {
//    @ObservedObject private var checkForUpdatesViewModel:
//      CheckForUpdatesViewModel
//    private let updater: SPUUpdater
//
//    init(updater: SPUUpdater) {
//      self.updater = updater
//
//      // Create our view model for our CheckForUpdatesView
//      self.checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)
//    }
//
//    var body: some View {
//      Button("Check for Updates…", action: updater.checkForUpdates)
//        .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
//    }
//  }
//#endif
