//
//  PaicordApp.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 31/08/2025.
//  Copyright © 2025 Lakhan Lothiyi. All rights reserved.
//

import PaicordLib
@_spi(Advanced) import SwiftUIIntrospect
import SwiftUIX
import Logging

#if canImport(Sparkle)
  import Sparkle
#endif

@main
struct PaicordApp: App {
  let gatewayStore = GatewayStore.shared
  var challenges = Challenges()
    let console = StdOutInterceptor.shared

  #if os(iOS)
    class AppDelegate: NSObject, UIApplicationDelegate {

      // This method is called by the system to check if state restoration should occur.
      func application(
        _ application: UIApplication,
        shouldRestoreSecureApplicationState coder: NSCoder
      ) -> Bool {
        // Return false to prevent the app from restoring its previous state and windows.
        return false
      }

      // You might also want to prevent the system from saving the state in the first place:
      func application(
        _ application: UIApplication,
        shouldSaveSecureApplicationState coder: NSCoder
      ) -> Bool {
        // Return false to prevent the app from saving its current state when it is terminated.
        return false
      }
    }
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  #endif

  init() {
//    DiscordGlobalConfiguration.makeLogger = { label in
//      let stdoutHandler = StreamLogHandler.standardOutput(label: label) // stdout
//      return Logger(label: label, factory: { _ in stdoutHandler })
//    }
    console.startIntercepting()
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
        gatewayStore: gatewayStore
      )
      .preferredColorScheme(Color.theme.common.colorScheme)
      #if os(macOS)
        .introspect(.window, on: .macOS(.v14...)) { window in
          window.isRestorable = false
        }
      #endif
    }
    #if os(macOS)
      .windowToolbarStyle(.unified)
      //      .commands {
      //        CommandGroup(after: .appInfo) {
      //          CheckForUpdatesView(updater: updaterController.updater)
      //        }
      //      }
      .commands { AccountCommands(gatewayStore: gatewayStore) }
    #endif
    .environment(\.challenges, challenges)

    #if os(macOS)
      Settings {
        SettingsView()
          .toolbar(removing: .sidebarToggle)
      }
      .windowToolbarStyle(.unifiedCompact)
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
