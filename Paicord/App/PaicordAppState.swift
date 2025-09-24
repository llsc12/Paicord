//
//  PaicordAppState.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 18/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import Foundation
import PaicordLib

// Will probably expand this later

@Observable
final class PaicordAppState {
	private var _selectedGuild: GuildSnowflake? = nil
	var selectedGuild: GuildSnowflake? {
		get {
			access(keyPath: \.selectedGuild)
			return _selectedGuild
		}
		set {
			// If the guild is changing, reset the selected channel to nil or get the last selected one.
			// the view will handle when the channel is nil automatically.
			withMutation(keyPath: \.selectedGuild) {
				selectedChannel = prevSelectedChannels[newValue]
				_selectedGuild = newValue
			}
		}
	}
	var selectedChannel: ChannelSnowflake? = nil {
		didSet {
			prevSelectedChannels[selectedGuild] = selectedChannel
		}
	}
	
	var chatOpen: Bool = false

	private var prevSelectedChannels: [GuildSnowflake?: ChannelSnowflake] = {
		// load from user defaults
		if let data = UserDefaults.standard.data(
			forKey: "AppState.PrevSelectedChannels"
		),
			let dict = try? JSONSerialization.jsonObject(with: data)
				as? [String: String]
		{
			var result: [GuildSnowflake?: ChannelSnowflake] = [:]
			for (key, value) in dict {
				let guildID = key == "nil" ? nil : GuildSnowflake(key)
				let channelID = ChannelSnowflake(value)
				result[guildID] = channelID
			}
			return result
		}
		return [:]
	}()
	{
		didSet {
			// store new previous selected channel in the dictionary
			let data = try? JSONSerialization.data(withJSONObject: prevSelectedChannels)
			UserDefaults.standard.set(data, forKey: "AppState.PrevSelectedChannels")
		}
	}

	var showingError = false
	var showingErrorSheet = false
	var error: Error? = nil {
		didSet { showingError = error != nil }
	}
}
