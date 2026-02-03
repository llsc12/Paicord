//
//  LoginView.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 05/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PaicordLib
import SwiftUIX

struct LoginView: View {
  @Environment(\.gateway) var gw
  @Environment(\.appState) var appState
  var viewModel: LoginViewModel = .init()
  @Environment(\.theme) var theme

  // Focus states must be here (cannot live in viewmodel)
  @FocusState var loginFocused: Bool
  @FocusState var passwordFocused: Bool

  // used for form background animation
  @State var chosenMFAMethod: Payloads.MFASubmitData.MFAKind?

  init() {
    setup()
  }
  func setup() {
    Task {
      try? await Task.sleep(for: .seconds(0.5))  // edge case problem when logging out ???
      viewModel.gw = gw
      viewModel.appState = appState
      await viewModel.fingerprintSetup()
    }
  }
  var body: some View {
    IntrinsicSizeReader { size in
      ZStack {
        MeshGradientBackground()
          .ignoresSafeArea()
          .frame(maxWidth: .infinity, maxHeight: .infinity)

        if viewModel.gw != nil {
          VStack {
            if viewModel.gw.accounts.accounts.isEmpty
              || viewModel.addingNewAccount
            {
              if let mfa = viewModel.handleMFA,
                let fingerprint = viewModel.fingerprint
              {
                MFAView(
                  authentication: mfa,
                  fingerprint: fingerprint,
                  loginClient: viewModel.loginClient,
                  chosenMethod: $chosenMFAMethod,
                  onFinish: viewModel.finishMFA(token:)
                )
              } else {
                LoginForm(
                  viewModel: viewModel,
                  loginFocused: $loginFocused,
                  passwordFocused: $passwordFocused,
                  size: size
                )
                .overlay(alignment: .topLeading) {
                  if !viewModel.gw.accounts.accounts.isEmpty {
                    Button {
                      withAnimation {
                        viewModel.addingNewAccount = false
                      }
                    } label: {
                      Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .padding(8)
                        .background(theme.common.primaryButtonBackground)
                        .clipShape(.circle)
                    }
                    .buttonStyle(.borderless)
                  }
                }
              }
            } else {
              AccountPicker(
                accounts: viewModel.gw.accounts.accounts,
                onSelect: { viewModel.gw.accounts.currentAccountID = $0 },
                onAdd: { withAnimation { viewModel.addingNewAccount = true } }
              )
            }
          }
          .padding(20)
          .background(theme.common.tertiaryBackground.opacity(0.75))
          .clipShape(.rounded)
          .shadow(radius: 10)
          .padding(5)
          .transition(.scale(scale: 0.8).combined(with: .opacity))
        } else {
          ProgressView()
        }
      }
      .animation(.default, value: viewModel.gw == nil)
      .animation(.default, value: viewModel.handleMFA == nil)
      .animation(.default, value: viewModel.gw?.accounts.accounts.isEmpty)
      .animation(.default, value: viewModel.addingNewAccount)
      .animation(.default, value: viewModel.raUser)
      .animation(.default, value: viewModel.raFingerprint)
      .animation(.default, value: chosenMFAMethod)
      .animation(.default, value: size)
    }
  }
}

// MARK: - LoginForm

struct LoginForm: View {
  @Environment(\.theme) var theme
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  var viewWidthValidForQRCode: Bool {
    (self.size?.width ?? .infinity) > 600
  }
  @Bindable var viewModel: LoginViewModel
  @FocusState.Binding var loginFocused: Bool
  @FocusState.Binding var passwordFocused: Bool
  var size: CGSize?

  var body: some View {
    HStack(spacing: 20) {
      VStack {
        Text("Welcome Back!")
          .font(.largeTitle)
          .padding(.bottom, 4)
        Text("We're so excited to see you again!")
          .padding(.bottom)

        VStack(alignment: .leading, spacing: 5) {
          Text("Email or Phone Number")
          TextField(text: $viewModel.login)
          .textFieldStyle(.plain)
          .padding(10)
          .frame(maxWidth: .infinity)
          .focused($loginFocused)
          .background(theme.common.primaryBackground.opacity(0.75))
          .clipShape(.rounded)
          .overlay {
            RoundedRectangle()
              .stroke(
                loginFocused ? theme.common.primaryButton : Color.clear,
                lineWidth: 1
              )
              .fill(.clear)
          }
          .padding(.bottom, 10)

          Text("Password")
          SecureField(text: $viewModel.password)
            .textFieldStyle(.plain)
            .padding(10)
            .frame(maxWidth: .infinity)
            .focused($passwordFocused)
            .background(theme.common.primaryBackground.opacity(0.75))
            .clipShape(.rect(cornerSize: .init(10)))
            .overlay {
              RoundedRectangle()
                .stroke(
                  passwordFocused
                    ? theme.common.primaryButton : Color.clear,
                  lineWidth: 1
                )
                .fill(.clear)
            }

          ForgotPasswordButton(viewModel: viewModel)
            .padding(.bottom, 10)
        }

        LoginButton(viewModel: viewModel)
      }
      .maxWidth(360)

      if horizontalSizeClass == .regular, self.viewWidthValidForQRCode {
        // qr code login
        VStack {
          // qr code url
          if let user = viewModel.raUser {
            VStack(spacing: 15) {
              Profile.Avatar(member: nil, user: user)
                .frame(maxWidth: 100)

              Text("Check your phone!")
                .font(.title2.weight(.semibold))

              Text("Logging in as \(user.username ?? "Unknown")")

              AsyncButton("Not me, start over") {
                viewModel.raUser = nil
                viewModel.raFingerprint = nil
                await viewModel.remoteAuthGatewayManager.disconnect()
                await viewModel.remoteAuthGatewayManager.connect()
              } catch: { error in
                viewModel.appState.error = error
              }
            }
            .padding(.horizontal)
            .transition(.blurReplace)
          } else if let fingerprint = viewModel.raFingerprint {
            let url = "https://discord.com/ra/" + fingerprint
            VStack(spacing: 15) {
              QRCodeView(data: url)
                .clipShape(.rect(cornerSize: .init(4), style: .continuous))
                .frame(width: 150, height: 150)

              Text("Log in with QR Code")
                .font(.title.weight(.semibold))

              Text(
                "Scan this with the Paicord or Discord mobile app to log in instantly."
              )
              .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .transition(.blurReplace)
          } else {
            ProgressView()
              .frame(width: 150, height: 150)
          }
        }
        .maxWidth(280)
        .transition(.blurReplace)
      }
    }
  }

  struct QRCodeView: View {
    let data: String
    @State var image: CGImage? = nil

    var body: some View {
      VStack {
        if let image {
          Image(cgImage: image)
            .resizable()
            .interpolation(.none)
            .scaledToFit()
        } else {
          ProgressView()
        }
      }
      .task(id: data) {
        var filter: CIFilter
        if #available(iOS 26.0, macOS 26.0, *) {
          let rfilter = CIFilter.roundedQRCodeGenerator()
          rfilter.roundedData = true
          rfilter.roundedMarkers = 2
          rfilter.message = data.data(using: .ascii) ?? Data()
          rfilter.correctionLevel = "L"
          filter = rfilter
        } else {
          let nfilter = CIFilter.qrCodeGenerator()
          nfilter.message = data.data(using: .ascii) ?? Data()
          nfilter.correctionLevel = "L"
          filter = nfilter
        }

        if let outputImage = filter.outputImage {
          let context = CIContext()
          if let cgImage = context.createCGImage(
            outputImage,
            from: outputImage.extent
          ) {
            self.image = cgImage
          } else {
            self.image = nil
          }
        } else {
          self.image = nil
        }
      }
    }
  }
}

private struct ForgotPasswordButton: View {
  @Environment(\.theme) var theme
  @Bindable var viewModel: LoginViewModel

  var body: some View {
    AsyncButton {
      await viewModel.forgotPassword()
    } catch: { error in
      viewModel.appState.error = error
    } label: {
      Text("Forgot your password?")
    }
    .buttonStyle(.borderless)
    .foregroundStyle(theme.common.hyperlink)
    .disabled(viewModel.login.isEmpty)
    .onHover {
      viewModel.forgotPasswordPopover = viewModel.login.isEmpty ? $0 : false
    }
    .popover(isPresented: $viewModel.forgotPasswordPopover) {
      Text("Enter a valid login above to send a reset link!").padding()
    }
    .alert(
      "Forgot Password",
      isPresented: $viewModel.forgotPasswordSent,
      actions: { Button("Dismiss", role: .cancel) {} },
      message: { Text("You will receive a password reset form shortly!") }
    )
  }
}

private struct LoginButton: View {
  @Environment(\.theme) var theme
  @Bindable var viewModel: LoginViewModel

  var body: some View {
    AsyncButton {
      await viewModel.loginAction()
    } catch: { error in
      viewModel.appState.error = error
    } label: {
      Text("Log In")
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(theme.common.primaryButton)
        .clipShape(.rounded)
        .font(.title3)
    }
    .buttonStyle(.borderless)
  }
}

#Preview {
  LoginView()
}
