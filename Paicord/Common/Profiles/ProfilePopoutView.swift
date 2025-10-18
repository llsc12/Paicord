//
//  ProfilePopoutView.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/10/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//  

import PaicordLib
import SwiftUIX

struct ProfilePopoutView: View {
  let member: Guild.PartialMember?
  let user: DiscordUser
  
  var body: some View {
    VStack {
      Profile.Avatar(member: member, user: user)
        .frame(width: 80, height: 80)
        
    }
    .padding()
  }
}
