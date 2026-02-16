//
//  QuickSwitcherModifier.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import SwiftUIX
import Loupe

extension View {
  func quickSwitcher() -> some View {
    self.modifier(QuickSwitcherModifier())
  }
}

struct QuickSwitcherModifier: ViewModifier {
  @Environment(\.appState) var appState
  @AppStorage("Paicord.QuickSwitcher.Position") @Storage var persistedPosition: CGPoint = .zero
  
  @State private var currentPosition: CGPoint = .zero
  @ViewStorage var disableValidation = false
  @State var switcherFrame: CGRect = .zero
  @State var viewableFrame: CGRect = .zero

  func body(content: Content) -> some View {
    content
      .overlay {
        if appState.showingQuickSwitcher {
          QuickSwitcherView()
            .onGeometryChange(
              for: CGRect.self,
              of: { $0.frame(in: .local) },
              action: { newValue in
                switcherFrame = newValue
              }
            )
            .position(x: currentPosition.x, y: currentPosition.y + (switcherFrame.height / 2))
            .gesture(barDragGesture)
            .task(id: viewableFrame, validatePosition)
            .task(id: switcherFrame, validatePosition)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
              Color.black.opacity(0.25)
                .onTapGesture {
                  appState.showingQuickSwitcher = false
                }
            }
            .onGeometryChange(
              for: CGRect.self,
              of: { $0.frame(in: .local) },
              action: { newValue in
                viewableFrame = newValue
              }
            )
            .transition(.opacity.animation(.easeInOut(duration: 0.1)))
            .onKeyPress(.escape) {
              appState.showingQuickSwitcher = false
              return .handled
            }
            .onAppear {
              currentPosition = persistedPosition
            }
        }
      }
  }

  @Sendable
  func validatePosition() async {
    guard !disableValidation else { return }
    let switcherSize = switcherFrame.size
    guard switcherSize.width > 0 else { return }

    // if the position is zero (first launch), center it
    if persistedPosition == .zero {
      let centerPos = CGPoint(
        x: viewableFrame.midX,
        y: viewableFrame.midY - (switcherSize.height / 2)
      )
      currentPosition = centerPos
      persistedPosition = centerPos
      return
    }

    let newX = min(
      max(currentPosition.x, switcherSize.width / 2),
      viewableFrame.width - switcherSize.width / 2
    )
    let newY = min(
      max(currentPosition.y, 0),
      viewableFrame.height - switcherSize.height
    )

    let validatedPos = CGPoint(x: newX, y: newY)
    currentPosition = validatedPos
    persistedPosition = validatedPos
  }

  @ViewStorage private var dragStartPosition: CGPoint = .zero

  var barDragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        self.disableValidation = true
        if dragStartPosition == .zero {
          dragStartPosition = currentPosition
        }

        let switcherSize = switcherFrame.size

        let targetX = dragStartPosition.x + value.translation.width
        let targetY = dragStartPosition.y + value.translation.height

        let newX = min(
          max(targetX, switcherSize.width / 2),
          viewableFrame.width - switcherSize.width / 2
        )
        let newY = min(
          max(targetY, 0),
          viewableFrame.height - switcherSize.height
        )

        currentPosition = CGPoint(x: newX, y: newY)
      }
      .onEnded { _ in
        self.disableValidation = false
        dragStartPosition = .zero
        persistedPosition = currentPosition
      }
  }
}
struct QuickSwitcherView: View {
  @Environment(\.appState) var appState
  @FocusState private var searchFieldFocused: Bool

  @State var query: String = ""
  @State var results: [String] = []

  private let cornerRadius: CGFloat = 14

  var body: some View {
    VStack(spacing: 0) {
      TextField("Where would you like to go?", text: $query)
        .textFieldStyle(LargeTextFieldStyle())
        .focused($searchFieldFocused)
        .onAppear {
          searchFieldFocused = true
        }
        .padding(14)
        .maxHeight(50)

      if !query.isEmpty {
        Divider()
        LazyVStack {
          ForEach(0..<5) { i in
            Text("Result \(i + 1) for \"\(query)\"")
              .padding(.horizontal, 14)
              .padding(.vertical, 10)
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(i % 2 == 0 ? Color.gray.opacity(0.1) : Color.clear)
          }
        }
      }
    }
    .maxWidth(600)
    .background(.ultraThinMaterial.blendMode(.darken))
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .circular))
    .overlay {
      RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
        .strokeBorder(.black, lineWidth: 0.5)
    }
    .overlay {
      RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
        .strokeBorder(.gray.opacity(0.4), lineWidth: 0.85)
        .padding(0.5)
    }
    .shadow(color: .black.opacity(0.65), radius: 20, x: 0, y: 20)
    // dismiss on unfocus
    .onChange(of: searchFieldFocused) {
      if !searchFieldFocused {
        appState.showingQuickSwitcher = false
      }
    }
  }
}

struct LargeTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(.secondary)
        .font(.title)
      configuration
        .textFieldStyle(.plain)
        .font(.largeTitle)
    }
  }
}

#Preview {
  TextField("Where would you like to go?", text: .constant(""))
    .textFieldStyle(LargeTextFieldStyle())
    .width(600)
    .padding()
}

extension CGPoint: AppStorageConvertible {
  init?(_ storedValue: String) {
    let components = storedValue.split(separator: ",").compactMap { Double($0) }
    guard components.count == 2 else { return nil }
    self.init(x: components[0], y: components[1])
  }

  var storedValue: String {
    "\(x),\(y)"
  }
}
