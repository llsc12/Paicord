//
//  QuickSwitcherModifier.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 13/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import SwiftUIX

extension View {
  func quickSwitcher() -> some View {
    self.modifier(QuickSwitcherModifier())
  }
}

struct QuickSwitcherModifier: ViewModifier {
  @Environment(\.appState) var appState
  func body(content: Content) -> some View {
    content
      .overlay {
        if appState.showingQuickSwitcher {
          QuickSwitcherView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
              Color.black.opacity(0.4)
                .onTapGesture {
                  appState.showingQuickSwitcher = false
                }
            }
            .transition(.opacity.animation(.easeInOut(duration: 0.1)))
            .onKeyPress(.escape) {
              appState.showingQuickSwitcher = false
              return .handled
            }
        }
      }
  }
}

struct QuickSwitcherView: View {
  @State var query: String = ""
  @FocusState private var searchFieldFocused: Bool
  var body: some View {
    ScrollView {
      VStack {
        TextField("Where would you like to go?", text: $query)
          .textFieldStyle(LargeTextFieldStyle())
          .focused($searchFieldFocused)
          .onAppear {
            searchFieldFocused = true
          }
      }
      .padding(12)
    }
    .frame(maxWidth: 630, maxHeight: 350)
    .background(.ultraThinMaterial)
    .clipShape(.rounded)
  }
}

struct LargeTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .textFieldStyle(.plain)
      .font(.title)
      .padding(12)
      .background {
        RoundedRectangle(cornerRadius: 10)
          .fill(.black.opacity(0.25))
          .strokeBorder(.bar.opacity(0.5), lineWidth: 1)
      }
  }
}

#Preview {
  TextField("Where would you like to go?", text: .constant(""))
    .textFieldStyle(LargeTextFieldStyle())
    .width(600)
    .padding()
}
