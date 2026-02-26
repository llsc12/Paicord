//
//  VoiceGatewayTests.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 22/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import Foundation
import NIOCore
import XCTest

@testable import DiscordVoice

class VoiceGatewayTests: XCTestCase {
  func testBinaryDataDecode() async throws {
    let gw = VoiceGatewayManager.init(
      connectionData: .init(
        token: "",
        guildID: try! .makeFake(),
        channelID: try! .makeFake(),
        userID: try! .makeFake(),
        sessionID: "",
        endpoint: ""
      )
    )
    let b64encoded = [
      "AAEZQEEEoNRlRXBSfG9sxtr5jJxzVcUuTfJslWTSDfqcEtPF8pnyvue1yLTrW24vmka5hnjp67V0c+0wPu5jYTTrJWEmAQABAQA=",
      "AAUbAEHwAAEAAQgUFa0c+EQQpQAAAAAAAAAAAgAAAAAAAgABAAEAAkBBBA6ffGO2L8WWMuAQ++A1Guoy24snd0uvi1PRIuJx+4dH6PMtRIfTH+ziN72vzIxctvdpozvYNHu67LyCakgni09AQQTWjD7BWWBExpHTTyoBuq1CF6wIIvSPKBMCYZoepq6kqKubOdIN/wLSlkZd0U118EVDVOMkt7+he3037GO6L0GjQEEEHjylB9FDUAK/ne9bxgQmSS8NdZy59gA4XrjkF4n1BQvbzepPUPln+KlzPUSJ9HazjqDXl19lUWG8YIxtS80K9wABCAVLf4aFQAAAAgABAgACAAACAAEBAAAAAAAAAAD//////////wBARzBFAiEAgAIMGdDd9QJBg489IMOK5grxwnrufTKc2kxwjPx+cgMCIAyukS8MJ9ifqTghaV6WPWTNenyK7W26KIbwpKu9RZhjAEBHMEUCIQCZpnz5onf5GTSD9EiQ4BU0iqZ5+017ntaXxZABk8f20AIgLkH7plqgAhSMUj3CWi7LM1wQJGAywVGlbJpV80In4GBASDBGAiEAz5mrzAcKQDdqgVEMNkUr53PM+Iki2TxZzsars+cAMwoCIQDjN91qFSm7pO8rbHiBLeod/tpwpKpsWk0QbzHpGHw/fw==",
      "AAYdAAAAAQABCBQVrRz4RBClAAAAAAAAAAABAAAAAAADIgIg+vGT+WKMUdMhzDRQuUmb7m8ucQBmF7Q8BhrtHiHlhiEAQEYwRAIgQXho5VoNJ9QZOPlcrr1cxQMUNEaUwgYyoUEyaJjqKh0CICWeFzuXJyFWqcJCs7rK21oz9Vu4zLKh8gFtQa0jYke/IGXRtM8sLvaABUM6F7GckyemC6gvCXr+0pfHdaE5EAF+IFehvFBjnOgQyENbJbqs/fHjXOTDSgJg+EMKijIYlUQv"
    ]
    for encoded in b64encoded {
      var data = ByteBuffer.init(data: Data(base64Encoded: encoded)!)
      let decoded = try await gw.tryDecodeBufferAsEvent(&data, binary: true)
      print(decoded)
    }
  }
}
