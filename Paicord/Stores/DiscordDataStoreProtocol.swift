//
//  DiscordDataStoreProtocol.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 20/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//

import PaicordLib

protocol DiscordDataStore: AnyObject {
	var gateway: (any GatewayManager)? { get set }
	var eventTask: Task<Void, Never>? { get set }
	
	func setGateway(_ gateway: (any GatewayManager)?)
	func setupEventHandling()
	func cancelEventHandling()
}
