//
//  GradientText.swift
//  PaiCord
//
//  Created by Lakhan Lothiyi on 02/09/2025.
//

import SwiftUI

struct TextGradientModifier: ViewModifier {
  var gradient: LinearGradient

  func body(content: Content) -> some View {
    content
      .foregroundStyle(gradient)
      .mask(content)
  }
}

struct Test: View {
  @State var start = UnitPoint(x: 0, y: -2)
  @State var end = UnitPoint(x: 4, y: 0)

  let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
  let colors = [
    Color(
      #colorLiteral(
        red: 0.9843137255, green: 0.9176470588, blue: 0.6470588235, alpha: 1)),
    Color(
      #colorLiteral(red: 1, green: 0.3333333333, blue: 0.6117647059, alpha: 1)),
    Color(
      #colorLiteral(
        red: 0.4156862745, green: 0.7098039216, blue: 0.9294117647, alpha: 1)),
    Color(
      #colorLiteral(
        red: 0.337254902, green: 0.1137254902, blue: 0.7490196078, alpha: 1)),
    Color(
      #colorLiteral(
        red: 0.337254902, green: 0.9215686275, blue: 0.8509803922, alpha: 1)),
  ]

  var body: some View {
    LinearGradient(
      gradient: Gradient(colors: colors), startPoint: start, endPoint: end
    )
    .animation(
      Animation.easeInOut(duration: 10).repeatForever(autoreverses: true).speed(
        0.5)
    )
    .onReceive(
      timer,
      perform: { _ in
        self.start = UnitPoint(x: 4, y: 0)
        self.end = UnitPoint(x: 0, y: 2)
        self.start = UnitPoint(x: -4, y: 20)
        self.start = UnitPoint(x: 4, y: 0)
      })
  }
}

#Preview {
  Test()
    .frame(width: 200, height: 200)
}
