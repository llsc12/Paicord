//
//  MeshGradient.swift
//  Paicord
//
// Created by Lakhan Lothiyi on 05/09/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

import MeshGradient
import simd
import protocol SwiftUI.View
import struct SwiftUICore.Environment
import struct SwiftUICore.EnvironmentValues
import struct SwiftUICore.State

extension LoginView {
  struct MeshGradientBackground: View {
    typealias MeshColor = SIMD3<Float>

    // You can provide custom `locationRandomizer` and `turbulencyRandomizer` for advanced usage

    private static var meshColorsLight: [simd_float3] {
      return [
        .init(0.345, 0.396, 0.949),  // Blurple (#5865F2)
        .init(0.557, 0.631, 0.882),  // Soft Indigo (#8EA1E1)
        .init(0.655, 0.686, 1.000),  // Periwinkle (#A7AFFF)
        .init(0.765, 0.749, 0.992),  // Lavender (#C3BFFD)
        .init(0.278, 0.251, 0.631),  // Deep Purple (#4740A1)
      ]
    }

    private static var meshColorsDark: [simd_float3] {
      return [
        .init(0.345, 0.396, 0.949),  // Blurple (#5865F2)
        .init(0.227, 0.243, 0.675),  // Royal Blue (#3A3EAC)
        .init(0.157, 0.173, 0.329),  // Deep Indigo (#282C54)
        .init(0.118, 0.098, 0.231),  // Midnight Purple (#1E193B)
        .init(0.137, 0.153, 0.165),  // Slate (#23272A)
      ]
    }

    // This methods prepares the grid model that will be sent to metal for rendering
    func generatePlainGrid(size: Int = 6) -> Grid<ControlPoint> {
      let preparationGrid = Grid<MeshColor>(
        repeating: .zero, width: size, height: size)

      // At first we create grid without randomisation. This is smooth mesh gradient without
      // any turbulency and overlaps
      var result = MeshGenerator.generate(colorDistribution: preparationGrid)

      // And here we shuffle the grid using randomizer that we created
      for x in stride(from: 0, to: result.width, by: 1) {
        for y in stride(from: 0, to: result.height, by: 1) {
          meshRandomizer.locationRandomizer(
            &result[x, y].location, x, y, result.width, result.height)
          meshRandomizer.turbulencyRandomizer(
            &result[x, y].uTangent, x, y, result.width, result.height)
          meshRandomizer.turbulencyRandomizer(
            &result[x, y].vTangent, x, y, result.width, result.height)

          meshRandomizer.colorRandomizer(
            &result[x, y].color, result[x, y].color, x, y, result.width,
            result.height)
        }
      }

      return result
    }

    // MeshRandomizer is a plain struct with just the functions. So you can dynamically change it!
    @State var meshRandomizer: MeshRandomizer

    init() {
      self.meshRandomizer = MeshRandomizer(
        colorRandomizer: MeshRandomizer.arrayBasedColorRandomizer(
          availableColors: Self.meshColorsDark))
    }

    @Environment(\.colorScheme) var cs

    var body: some View {
      MeshGradient(
        initialGrid: generatePlainGrid(),
        animatorConfiguration: .init(
          animationSpeedRange: 2...4, meshRandomizer: meshRandomizer)
      )
      .onAppear {
        let colors = cs == .light ? Self.meshColorsLight : Self.meshColorsDark
        self.meshRandomizer = MeshRandomizer(
          colorRandomizer: MeshRandomizer.arrayBasedColorRandomizer(
            availableColors: colors))
      }
      .onChange(of: cs) {
        let colors = cs == .light ? Self.meshColorsLight : Self.meshColorsDark
        self.meshRandomizer = MeshRandomizer(
          colorRandomizer: MeshRandomizer.arrayBasedColorRandomizer(
            availableColors: colors))
      }
    }
  }
}
