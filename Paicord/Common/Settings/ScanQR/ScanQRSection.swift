//
//  ScanQRSection.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 23/01/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import CodeScanner
import SettingsKit
import SwiftUIX

extension SettingsView {
  @SettingsContentBuilder
  var scanQRSection: some SettingsContent {
    #if os(iOS)
      CustomSettingsGroup("Scan QR Code", systemImage: "qrcode") {
        QRCodeScanView()
          .listRowInsets(.zero)
          .listRowBackground(Color.clear)
      }
    #endif
  }
}
#if os(iOS)
  private struct QRCodeScanView: View {
    @Environment(\.gateway) var gw
    @Environment(\.appState) var appState
    @Environment(\.dismiss) var dismiss
    @State var isScanning: Bool = false
    @State var scannedData: String? = nil
    @State var handshake_token: String? = nil
    var body: some View {
      if scannedData == nil {
        CodeScannerView(
          codeTypes: [.qr],
          scanMode: .once,
          showViewfinder: true,
          shouldVibrateOnSuccess: true,
          isTorchOn: false,
        ) {
          response in
          switch response {
          case .success(let result):
            do {
              try self.handleScannedString(result.string)
            } catch {
              appState.error = error
            }
          case .failure(let error):
            appState.error = error
          }
        }
        .frame(maxWidth: 300, maxHeight: 300)
      } else {
        VStack(spacing: 16) {
          if let token = handshake_token {
            Text("Remote Authentication")
              .font(.title2)
              .frame(maxWidth: .infinity, alignment: .center)

            AsyncButton("Log In") {
              try await gw.client.finishRemoteAuthSession(
                payload: .init(handshake_token: token)
              )
              .guardSuccess()
              dismiss()
            } catch: { error in
              appState.error = error
            }
            .buttonStyle(.borderedProminent)

            AsyncButton("Cancel") {
              try await gw.client.cancelRemoteAuthSession(
                payload: .init(handshake_token: token)
              )
              .guardSuccess()
              self.scannedData = nil
              self.handshake_token = nil
            } catch: { error in
              appState.error = error
            }
            .buttonStyle(.bordered)

            Text(
              "You are giving access to your Discord account to another device."
            )
            .foregroundStyle(.red)
          } else {
            ProgressView()
          }
        }
        .task {
          do {
            let req = try await gw.client.createRemoteAuthSession(
              payload: .init(fingerprint: self.scannedData!)
            )
            try req.guardSuccess()
            let data = try req.decode()
            self.handshake_token = data.handshake_token
          } catch {
            appState.error = error
            scannedData = nil
          }
        }
      }
    }

    enum QRCodeScanError: Error {
      case invalidURL
      case unrelatedURL
    }

    func handleScannedString(_ string: String) throws {
      // Check that the string is a valid URL
      guard let url = URL(string: string), UIApplication.shared.canOpenURL(url)
      else {
        throw QRCodeScanError.invalidURL
      }
      // ensure url is discord.com
      guard url.host?.contains("discord.com") == true else {
        throw QRCodeScanError.invalidURL
      }

      // ensure it has /ra/<data> path
      guard url.pathComponents.count >= 3,
        url.pathComponents[1] == "ra"
      else {
        throw QRCodeScanError.unrelatedURL
      }

      // must be a remote auth URL, extract fingerprint
      let fingerprint = url.pathComponents[2]
      self.scannedData = fingerprint
    }
  }
#endif
