//
//  LoginView.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 05/09/2025.
//

import SDWebImageSwiftUI
import SwiftUI
import MeshGradient

struct LoginView: View {
  @State var login: String = ""
  @FocusState private var loginFocused: Bool
  @State var password: String = ""
  @FocusState private var passwordFocused: Bool

  @State var forgotPasswordPopover = false
  var body: some View {
    ZStack {
      WebImage(
        url: .init(string: "https://discord.com/assets/d8680b1c1576ecc8.svg"),
        context: [.imageThumbnailPixelSize: CGSize(width: 1920, height: 1080)]
      )
      .resizable()
      .scaledToFill()
      .frame(minWidth: 500)
      .frame(minHeight: 500)
      .scaleEffect(1.15)
      .blur(radius: 4)

      VStack {
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
            .background(.appBackground)
            .clipShape(.rect(cornerSize: .init(10)))
            .overlay {
              RoundedRectangle(cornerSize: .init(10))
				.stroke(loginFocused ? .primaryButton : .clear, lineWidth: 1)
                .fill(.clear)
            }
            .padding(.bottom, 10)

          Text("Password")
          TextField("", text: $password)
            .textFieldStyle(.plain)
            .padding(10)
            .frame(maxWidth: .infinity)
            .focused($passwordFocused)
            .background(.appBackground)
            .clipShape(.rect(cornerSize: .init(10)))
            .overlay {
              RoundedRectangle(cornerSize: .init(10))
				.stroke(passwordFocused ? .primaryButton : .clear, lineWidth: 1)
                .fill(.clear)
            }
          Button("Forgot your password?") {
			
          }
          .buttonStyle(.plain)
          .foregroundStyle(.hyperlink)
          .disabled(login.isEmpty)
          .onHover { self.forgotPasswordPopover = $0 }
          .popover(isPresented: $forgotPasswordPopover) {
            Text("Enter a valid login above to send a reset link!")
              .padding()
          }
          .padding(.bottom)
        }

        Button {
          // Handle login action
          print("Logging in with \(login) and \(password)")
        } label: {
          Text("Log In")
            .frame(maxWidth: .infinity)
            .padding()
            .background(.primaryButton)
            .clipShape(.capsule)
            .font(.title3)
        }
        .buttonStyle(.plain)

        Spacer()
      }
      .padding(.horizontal, 20)
      .padding(.top, 20)
      .frame(maxWidth: 400)
      .frame(maxHeight: 350)
      .background(.tabBarBackground)
      .clipShape(.rect(cornerSize: .init(10)))
	  .shadow(radius: 10)
    }
  }
  
  struct MeshGradientBackground: View {
	typealias MeshColor = SIMD3<Float>

	// You can provide custom `locationRandomizer` and `turbulencyRandomizer` for advanced usage
	var meshRandomizer = MeshRandomizer(colorRandomizer: MeshRandomizer.arrayBasedColorRandomizer(availableColors: meshColors))

	private var meshColors: [simd_float3] {
	 return [
	  MeshRandomizer.randomColor(),
	  MeshRandomizer.randomColor(),
	  MeshRandomizer.randomColor(),
	 ]
	}

	// This methods prepares the grid model that will be sent to metal for rendering
	func generatePlainGrid(size: Int = 6) -> Grid<ControlPoint> {
	  let preparationGrid = Grid<MeshColor>(repeating: .zero, width: size, height: size)
	  
	  // At first we create grid without randomisation. This is smooth mesh gradient without
	  // any turbulency and overlaps
	  var result = MeshGenerator.generate(colorDistribution: preparationGrid)

	  // And here we shuffle the grid using randomizer that we created
	  for x in stride(from: 0, to: result.width, by: 1) {
	   for y in stride(from: 0, to: result.height, by: 1) {
		meshRandomizer.locationRandomizer(&result[x, y].location, x, y, result.width, result.height)
		meshRandomizer.turbulencyRandomizer(&result[x, y].uTangent, x, y, result.width, result.height)
		meshRandomizer.turbulencyRandomizer(&result[x, y].vTangent, x, y, result.width, result.height)

		meshRandomizer.colorRandomizer(&result[x, y].color, result[x, y].color, x, y, result.width, result.height)
	   }
	  }

	  return result
	}
	
	// MeshRandomizer is a plain struct with just the functions. So you can dynamically change it!
	 @State var meshRandomizer = MeshRandomizer(colorRandomizer: MeshRandomizer.arrayBasedColorRandomizer(availableColors: meshColors))

	 var body: some View {
	  MeshGradient(initialGrid: generatePlainGrid(),
				   animatorConfiguration: .init(animationSpeedRange: 2 ... 4, meshRandomizer: meshRandomizer)))
	 }
  }
}

#Preview {
  LoginView()
}
