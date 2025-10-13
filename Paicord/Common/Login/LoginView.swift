//
//  LoginView.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 05/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SwiftUI

struct LoginView: View {
	@Environment(GatewayStore.self) var gw
	@Environment(PaicordAppState.self) var appState
	var viewModel: LoginViewModel = .init()

	// Focus states must be here (cannot live in viewmodel)
	@FocusState var loginFocused: Bool
	@FocusState var passwordFocused: Bool

	// used for form background animation
	@State var chosenMFAMethod: Payloads.MFASubmitData.MFAKind?

	var body: some View {
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
								passwordFocused: $passwordFocused
							)
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
				.frame(maxWidth: 400)
				.background(.tabBarBackground.opacity(0.75))
				.clipShape(.rounded)
				.shadow(radius: 10)
				.padding(5)
				.transition(.scale(scale: 0.8).combined(with: .opacity))
			} else {
				ProgressView()
					.task {
						try? await Task.sleep(for: .seconds(0.5)) // edge case problem when logging out ???
						viewModel.gw = gw
						viewModel.appState = appState
						Task {
							await viewModel.fingerprintSetup()
						}
					}
			}
		}
		.animation(.default, value: viewModel.gw == nil)
		.animation(.default, value: viewModel.handleMFA == nil)
		.animation(.default, value: viewModel.gw?.accounts.accounts.isEmpty)
		.animation(.default, value: viewModel.addingNewAccount)
		.animation(.default, value: chosenMFAMethod)
	}
}

// MARK: - LoginForm

struct LoginForm: View {
	@Bindable var viewModel: LoginViewModel
	@FocusState.Binding var loginFocused: Bool
	@FocusState.Binding var passwordFocused: Bool

	var body: some View {
		VStack {
			Text("Welcome Back!")
				.font(.largeTitle)
				.padding(.bottom, 4)
			Text("We're so excited to see you again!")
				.padding(.bottom)

			VStack(alignment: .leading, spacing: 5) {
				Text("Email or Phone Number")
				TextField("", text: $viewModel.login)
					.textFieldStyle(.plain)
					.padding(10)
					.frame(maxWidth: .infinity)
					.focused($loginFocused)
					.background(.appBackground.opacity(0.75))
					.clipShape(.rounded)
					.overlay {
						RoundedRectangle()
							.stroke(loginFocused ? .primaryButton : .clear, lineWidth: 1)
							.fill(.clear)
					}
					.padding(.bottom, 10)

				Text("Password")
				SecureField("", text: $viewModel.password)
					.textFieldStyle(.plain)
					.padding(10)
					.frame(maxWidth: .infinity)
					.focused($passwordFocused)
					.background(.appBackground.opacity(0.75))
					.clipShape(.rect(cornerSize: .init(10)))
					.overlay {
						RoundedRectangle()
							.stroke(
								passwordFocused ? .primaryButton : .clear,
								lineWidth: 1
							)
							.fill(.clear)
					}

				ForgotPasswordButton(viewModel: viewModel)
					.padding(.bottom, 10)
			}

			LoginButton(viewModel: viewModel)
		}
	}
}

private struct ForgotPasswordButton: View {
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
		.foregroundStyle(.hyperlink)
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
				.background(.primaryButton)
				.clipShape(.rounded)
				.font(.title3)
		}
		.buttonStyle(.borderless)
	}
}

#Preview {
	LoginView()
}
