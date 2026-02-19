//
//  UDPEncodable.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 19/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation

public protocol UDPEncodable {
  /// The binary representation of the RTP packet, ready to be sent over UDP.
  func encode() -> Data
}
