//
//  LoginView.swift
//  PaiCord
//
// Created by Lakhan Lothiyi on 05/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib
import SDWebImageSwiftUI
import SwiftUI

struct LoginView: View {
	@Environment(GatewayStore.self) var gw
	@Environment(PaicordAppState.self) var appState

	@State var loginClient: (any DiscordClient)! = nil
	@AppStorage("Authentication.Fingerprint") var fingerprint: String?

	@State var addingNewAccount = false
	
	@State var login: String = ""
	@FocusState private var loginFocused: Bool
	@State var password: String = ""
	@FocusState private var passwordFocused: Bool

	@State var handleMFA: UserAuthentication? = nil

	@State var forgotPasswordPopover = false
	@State var forgotPasswordSent = false

	var body: some View {
		ZStack {
			MeshGradientBackground()
				.frame(minWidth: 500)
				.frame(minHeight: 500)

			if loginClient != nil {
				VStack {
					// if we have no accounts, show login.
					// if we have accounts, show a list or show login if addingNewAccount is true
					if gw.accounts.accounts.isEmpty || addingNewAccount {
						loginForm
					} else {
						accountPicker
					}
				}
				.padding(20)
				.frame(maxWidth: 400)
				.background(.tabBarBackground)
				.clipShape(.rounded)
				.shadow(radius: 10)
				.opacity(0.75)
				.frame(minHeight: 400)
				.transition(.scale(scale: 0.8).combined(with: .opacity))
			}
		}
		.ignoresSafeArea()
		.task {
			let loginClient = gw.client
			defer { self.loginClient = loginClient }
			do {
				if self.fingerprint == nil {
					let request = try await loginClient.getExperiments()
					try request.guardSuccess()
					let data = try request.decode()
					self.fingerprint = data.fingerprint
				}
			} catch {
				self.appState.error = error
			}
		}
		.animation(.default, value: loginClient == nil)
	}
	
	@ViewBuilder var loginForm: some View {
		Text("Welcome Back!")
			.font(.largeTitle)
			.padding(.bottom, 4)
		Text("We're so excited to see you again!")
			.padding(.bottom)

		VStack(alignment: .leading, spacing: 5) {
			Text("Email or Phone Number")
			TextField("", text: $login)
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
			SecureField("", text: $password)
				.textFieldStyle(.plain)
				.padding(10)
				.frame(maxWidth: .infinity)
				.focused($passwordFocused)
				.background(.appBackground.opacity(0.75))
				.clipShape(.rect(cornerSize: .init(10)))
				.overlay {
					RoundedRectangle()
						.stroke(
							passwordFocused ? .primaryButton : .clear, lineWidth: 1
						)
						.fill(.clear)
				}

			AsyncButton {
				guard let fingerprint else {
					throw "A tracking fingerprint couldn't be generated."
				}
				let login = self.login
				let res = try await self.loginClient.forgotPassword(
					fingerprint: fingerprint, login: login
				)
				if let error = res.asError() {
					throw error
				}
				self.forgotPasswordSent.toggle()
			} catch: { error in
				self.appState.error = error
			} label: {
				Text("Forgot your password?")
			}
			.buttonStyle(.borderless)
			.foregroundStyle(.hyperlink)
			.disabled(login.isEmpty)
			.onHover { self.forgotPasswordPopover = login.isEmpty ? $0 : false }
			.popover(isPresented: $forgotPasswordPopover) {
				Text("Enter a valid login above to send a reset link!")
					.padding()
			}
			.alert(
				"Forgot Password", isPresented: $forgotPasswordSent,
				actions: {
					Button("Dismiss", role: .cancel) {}
				},
				message: {
					Text("You will receive a password reset form shortly!")
				}
			)
			.padding(.bottom, 10)
		}

		AsyncButton {
			let login = self.login
			let password = self.password
			guard let fingerprint else {
				throw "A tracking fingerprint couldn't be generated."
			}

			let request = try await self.loginClient.userLogin(
				login: login, password: password, fingerprint: fingerprint)
			if let error = request.asError() {
				throw error
			}
			let data = try request.decode()
			if data.mfa == true {
				// handle mfa
				self.handleMFA = data
			} else {
				// token should exist then
				guard let token = data.token else {
					throw "No authentication token was sent despite MFA not being required."
				}
				
				let user = try await TokenStore.getSelf(token: token)
				gw.accounts.addAccount(token: token, user: user)
				// the app will switch to the main view automatically
			}
			
		} catch: { error in
			self.appState.error = error
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
	
	@ViewBuilder var accountPicker: some View {
		Text("Choose an account")
			.font(.largeTitle)
			.padding(.bottom, 4)
		Text("Select an account to continue or add a new one.")
			.padding(.bottom)

		VStack(spacing: 10) {
			ScrollView {
				VStack(spacing: 10) {
					ForEach(gw.accounts.accounts) { account in
						Button {
							gw.accounts.currentAccountID = account.user.id
						} label: {
							HStack {
								Text(account.user.username)
									.font(.title3)
								Spacer()
							}
							.padding(10)
							.frame(maxWidth: .infinity)
							.background(.primaryButtonBackground)
							.clipShape(.rounded)
						}
						.buttonStyle(.borderless)
					}
				}
			}
			.frame(maxHeight: 200)

			Button {
				withAnimation {
					self.addingNewAccount = true
				}
			} label: {
				HStack {
					Image(systemName: "plus")
					Text("Add Account")
						.font(.title3)
				}
				.frame(maxWidth: .infinity)
				.padding(10)
				.background(.primaryButton)
				.clipShape(.rounded)
			}
			.buttonStyle(.borderless)
			.padding(.top, 10)
		}
	}
}

#Preview {
	LoginView()
}
