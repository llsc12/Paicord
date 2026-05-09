//
//  ProfileBannerView.swift
//  Paicord
//
//  Created by tiramisu on 2026.05.03.
//

import SwiftUI

struct ProfileBannerView: View {
  var body: some View {
    Label("Private Profile", systemImage: "lock.fill")
      .padding()
      .frame(maxWidth: .infinity)
      .background(.background)
  }
}
