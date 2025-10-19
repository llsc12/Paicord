//
//  CaptchaSheet.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 10/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import HCaptcha
import PaicordLib
import SwiftUI

#if os(iOS)
  private typealias ViewControllerRepresentable = UIViewControllerRepresentable
#elseif os(macOS)
  private typealias ViewControllerRepresentable = NSViewControllerRepresentable
#endif

struct CaptchaSheet: ViewControllerRepresentable {
  let challenge: CaptchaChallengeData
  let onToken: (CaptchaSubmitData?) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(challenge: challenge, onToken: onToken)
  }

  @Environment(\.colorScheme) private var colorScheme

  #if os(iOS)
    func makeUIViewController(context: Context) -> UIViewController {
      let controller = UIViewController()
      let placeholder = UIView()
      placeholder.backgroundColor = .clear
      placeholder.translatesAutoresizingMaskIntoConstraints = false
      controller.view.addSubview(placeholder)
      NSLayoutConstraint.activate([
        placeholder.leadingAnchor.constraint(
          equalTo: controller.view.leadingAnchor
        ),
        placeholder.trailingAnchor.constraint(
          equalTo: controller.view.trailingAnchor
        ),
        placeholder.topAnchor.constraint(equalTo: controller.view.topAnchor),
        placeholder.bottomAnchor.constraint(
          equalTo: controller.view.bottomAnchor
        ),
      ])

      context.coordinator.startCaptcha(
        on: placeholder,
        theme: colorScheme == .dark ? "dark" : "light"
      )
      return controller
    }

    func updateUIViewController(
      _ uiViewController: UIViewController,
      context: Context
    ) {}
  #else
    func makeNSViewController(context: Context) -> NSViewController {
      let controller = NSViewController()
      let placeholder = NSView()
      placeholder.wantsLayer = true
      placeholder.layer?.backgroundColor = .clear
      placeholder.translatesAutoresizingMaskIntoConstraints = false
      controller.view.addSubview(placeholder)
      NSLayoutConstraint.activate([
        placeholder.leadingAnchor.constraint(
          equalTo: controller.view.leadingAnchor
        ),
        placeholder.trailingAnchor.constraint(
          equalTo: controller.view.trailingAnchor
        ),
        placeholder.topAnchor.constraint(equalTo: controller.view.topAnchor),
        placeholder.bottomAnchor.constraint(
          equalTo: controller.view.bottomAnchor
        ),
      ])

      context.coordinator.startCaptcha(
        on: placeholder,
        theme: colorScheme == .dark ? "dark" : "light"
      )
      return controller
    }

    func updateNSViewController(
      _ nsViewController: NSViewController,
      context: Context
    ) {}
  #endif

  class Coordinator: NSObject {
    let challenge: CaptchaChallengeData
    let onToken: (CaptchaSubmitData?) -> Void
    var hcaptcha: HCaptcha?

    init(
      challenge: CaptchaChallengeData,
      onToken: @escaping (CaptchaSubmitData?) -> Void
    ) {
      self.challenge = challenge
      self.onToken = onToken
    }

    #if os(iOS)
      func startCaptcha(on hostView: UIView, theme: String = "light") {
        guard let siteKey = challenge.captchaSiteKey else {
          DispatchQueue.main.async { [onToken] in onToken(nil) }
          return
        }
        hcaptcha = try? HCaptcha(
          apiKey: siteKey,
          baseURL: URL(string: "https://discord.com"),
          rqdata: challenge.captchaRqdata,
          theme: theme,
          diagnosticLog: true
        )
        hcaptcha?.configureWebView { webview in
          webview.frame = hostView.bounds
          webview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          hostView.addSubview(webview)
        }
        hcaptcha?.onEvent { event, _ in
          print("[HCaptcha] event: \(event.rawValue)")
        }
        hcaptcha?.validate(on: hostView) { result in
          do {
            let str = try result.dematerialize()
            self.handleResult(.success(str))
          } catch {
            self.handleResult(.failure(error))
          }
        }
      }
    #else
      func startCaptcha(on hostView: NSView, theme: String = "light") {
        guard let siteKey = challenge.captchaSiteKey else {
          DispatchQueue.main.async { [onToken] in onToken(nil) }
          return
        }
        hcaptcha = try? HCaptcha(
          apiKey: siteKey,
          baseURL: URL(string: "https://discord.com"),
          rqdata: challenge.captchaRqdata,
          theme: theme,
          diagnosticLog: true
        )
        hcaptcha?.configureWebView { webview in
          webview.frame = hostView.bounds
          webview.autoresizingMask = [.width, .height]
          hostView.addSubview(webview)
        }
        hcaptcha?.onEvent { event, _ in
          print("[HCaptcha] event: \(event.rawValue)")
        }
        hcaptcha?.validate(on: hostView) { result in
          do {
            let str = try result.dematerialize()
            self.handleResult(.success(str))
          } catch {
            self.handleResult(.failure(error))
          }
        }
      }
    #endif

    private func handleResult(_ result: Result<String, Error>) {
      switch result {
      case .success(let token):
        onToken(CaptchaSubmitData(challenge: challenge, token: token))
      case .failure:
        onToken(nil)
      }
      hcaptcha?.reset()
    }
  }
}
