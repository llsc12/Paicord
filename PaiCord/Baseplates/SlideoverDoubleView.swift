import SwiftUI

struct SlideoverDoubleView<Primary: View, Secondary: View>: View {
	@Binding var swap: Bool
	var primary: Primary
	var secondary: Secondary

	@State private var dragOffset: CGFloat = 0
	private let animationDuration: Double = 0.2
	@State var width: CGFloat = 0

	@Environment(\.slideoverDisabled) var slideoverDisabled

	init(
		swap: Binding<Bool>,
		@ViewBuilder primary: () -> Primary,
		@ViewBuilder secondary: () -> Secondary
	) {
		self._swap = swap
		self.primary = primary()
		self.secondary = secondary()
	}

	var body: some View {
		ZStack {
			primary
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			// paul hudson said this fixes swift 6 concurrency issues with visualEffect
			// since its closure doesn't always run on the main thread.
			let swap = swap
			let dragOffset = dragOffset
			secondary
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(.background)
				.shadow(radius: 10)
				.visualEffect { vs, proxy in
					vs
						.offset(x: swap ? dragOffset : proxy.size.width + 10 + dragOffset)
				}
		}
		.onGeometryChange(for: CGFloat.self, of: { $0.size.width }) {
			self.width = $0
		}
		.gesture(
			DragGesture()
				.onChanged { drag in
					guard !slideoverDisabled else { return }
					let translation = drag.translation.width

					if swap {
						self.dragOffset = translation < 0 ? 0 : translation
					} else {
						self.dragOffset = translation
					}
					print("dragOffset", dragOffset, swap)
				}
				.onEnded { drag in
					guard !slideoverDisabled else {
						swap = false
						return
					}
					let translation = drag.translation.width
					let velocity = drag.velocity.width

					let shouldSwap: Bool = {
						if abs(velocity) > 600 { return velocity < 0 }
						if abs(translation) > self.width / 2 { return translation < 0 }
						return swap
					}()

					withAnimation(.easeOut(duration: animationDuration)) {
						swap = shouldSwap
						dragOffset = 0
					}
				}
		)
		.onChange(of: swap) {
			withAnimation(.easeOut(duration: animationDuration)) {
				dragOffset = 0
			}
		}
		.onChange(of: slideoverDisabled) {
			if slideoverDisabled {
				withAnimation(.easeOut(duration: animationDuration)) {
					swap = false
					dragOffset = 0
				}
			}
		}
	}
}

extension EnvironmentValues {
	@Entry var slideoverDisabled: Bool = false
}

extension View {
	func slideoverDisabled(_ disabled: Bool) -> some View {
		environment(\.slideoverDisabled, disabled)
	}
}

#Preview {
	struct PreviewWrapper: View {
		@State var current: Bool = true
		var body: some View {
			SlideoverDoubleView(swap: $current) {
				Text("im 1")
					.font(.largeTitle)
					.foregroundColor(.white)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(.appBackground)
			} secondary: {
				Text("im 2")
					.font(.largeTitle)
					.foregroundColor(.white)
			}
		}
	}
	return PreviewWrapper()
}
