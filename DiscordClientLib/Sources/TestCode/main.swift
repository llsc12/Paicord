//
//  main.swift
//  DiscordClientLib
//
//  Created by Lakhan Lothiyi on 04/09/2025.
//

import DiscordClientLib

let client = await DefaultDiscordClient(token: .none)

client.getBotGateway()
