//
//  VoiceConnectionStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 23/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import AVFoundation
import Opus
import PaicordLib

final class VoiceConnectionStore: DiscordDataStore {
  init() {
    self.opusEncoder = try! Opus.Encoder(format: Self.opusFormat, application: .voip)
    self.opusDecoder = try! Opus.Decoder(format: Self.opusFormat, application: .voip)
  }
  
  var gateway: GatewayStore?
  var voiceGateway: VoiceGatewayManager? {
    didSet {
      if let voiceGateway {
        // trigger audio engine setup
        audioEngineSetup()
      } else {
        // shutdown audio engine and release resources, also set status to stopped
        voiceStatus = .stopped
        audioEngineCleanup()
      }
    }
  }

  var eventTask: Task<Void, Never>?

  func setupEventHandling() {
    guard let gateway = gateway?.gateway else { return }

    eventTask = Task { @MainActor in
      for await event in await gateway.events {
        switch event.data {
        case .ready(let payload):
          handleReady(payload)
        case .voiceServerUpdate(let payload):
          handleVoiceServerUpdate(payload)
        // capture and store voice events
        default:
          break
        }
      }
    }
  }

  // state
  private var channelId: ChannelSnowflake?
  private var guildId: GuildSnowflake?
  private var isMuted: Bool = false
  private var isDeafened: Bool = false
  private var isVideoEnabled: Bool = false
  private var preferredRegion: String?
  private var flags: IntBitField<VoiceStateUpdate.Flags> = []

  private var voiceStatus: GatewayState = .stopped
  // MARK: - Public methods

  func updateVoiceConnection(_ update: VoiceConnectionUpdate) async {
    // for changing currently connected channel or disconnecting from voice, we still stop everything
    await voiceGateway?.disconnect()
    voiceGateway = nil
    // if we wanted to disconnect, just return here
    if case .disconnect = update {
      self.channelId = nil
      self.guildId = nil
      return
    }
    // well at this point we know we want to connect to a new channel.
    // to start a new voice connection, we need to get the necessary data from the gateway.
    // we update our voice state on the gateway so we get a voice server update.
    guard case .join(let channelId, let guildId) = update else { return }
    self.channelId = channelId
    self.guildId = guildId

    await gateway?.gateway?.updateVoiceState(
      payload: .init(
        guild_id: guildId,
        channel_id: channelId,
        self_mute: self.isMuted,
        self_deaf: self.isDeafened,
        self_video: self.isVideoEnabled,
        preferred_region: self.preferredRegion,
        preferred_regions: nil,
        flags: flags
      )
    )
  }
  enum VoiceConnectionUpdate {
    case join(channelId: ChannelSnowflake, guildId: GuildSnowflake?)
    case disconnect
  }

  func updateVoiceState(
    isMuted: Bool? = nil,
    isDeafened: Bool? = nil,
    isVideoEnabled: Bool? = nil
  ) async {
    if let isMuted = isMuted { self.isMuted = isMuted }
    if let isDeafened = isDeafened { self.isDeafened = isDeafened }
    if let isVideoEnabled = isVideoEnabled {
      self.isVideoEnabled = isVideoEnabled
    }

    await gateway?.gateway?.updateVoiceState(
      payload: .init(
        guild_id: self.guildId,
        channel_id: self.channelId,
        self_mute: self.isMuted,
        self_deaf: self.isDeafened,
        self_video: self.isVideoEnabled,
        preferred_region: self.preferredRegion,
        preferred_regions: nil,
        flags: flags
      )
    )
  }

  // MARK: - Event handling

  private func handleReady(_ payload: Gateway.Ready) {
    // send voice states, temporary until paicord has proper voice handling
    Task {
      await gateway?.gateway?.updateVoiceState(
        payload: .init(
          guild_id: self.guildId,
          channel_id: self.channelId,
          self_mute: self.isMuted,
          self_deaf: self.isDeafened,
          self_video: false,
          preferred_region: self.preferredRegion,
          preferred_regions: nil,
          flags: []
        )
      )
    }
  }

  private func handleVoiceServerUpdate(_ payload: Gateway.VoiceServerUpdate) {
    // if the endpoint is empty/nil, it means we got disconnected from voice, so disconnect from our voice gateway and return early
    // else we can start a new voice gateway connection with the new endpoint and token
    Task {
      guard let endpoint = payload.endpoint, !endpoint.isEmpty,
        let guildId, let channelId,
        let sessionId = await gateway?.gateway?.getSessionID(),
        let userId = gateway?.user.currentUser?.id
      else {
        Task { await voiceGateway?.disconnect() }
        voiceGateway = nil
        return
      }

      self.voiceGateway = VoiceGatewayManager.init(
        connectionData: .init(
          token: payload.token,
          guildID: guildId,
          channelID: channelId,
          userID: userId,
          sessionID: sessionId,
          endpoint: endpoint
        ),
        stateCallback: { state in
          Task { @MainActor in
            self.voiceStatus = state
          }
        }
      )
    }
  }

  func cancelEventHandling() {
    // overrides default impl of protocol
    eventTask?.cancel()
    eventTask = nil
    Task { await voiceGateway?.disconnect() }
  }

  // MARK: - Audio Engine implementation
  private static let opusFormat = AVAudioFormat(
    opusPCMFormat: .int16,
    sampleRate: .opus48khz,
    channels: 2
  )!
  private static let pcmFormat = AVAudioFormat(
    commonFormat: .pcmFormatInt16,
    sampleRate: .opus48khz,
    channels: 2,
    interleaved: true
  )!
  private let opusEncoder: Opus.Encoder
  private let opusDecoder: Opus.Decoder

  private let audioEngine = AVAudioEngine()
  private lazy var inputNode: AVAudioInputNode = {
    return audioEngine.inputNode
  }()
  private lazy var outputNode: AVAudioOutputNode = {
    return audioEngine.outputNode
  }()

  // audio player node for playing incoming audio frames
  private let playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
  
  private var incomingAudioTask: Task<Void, Never>? = nil

  private func audioEngineSetup() {
    self.audioEngineCleanup()  // cleanup any existing engine before setting up a new one

    // attach player node to engine
    audioEngine.attach(playerNode)
    
    // connect player node to output
    audioEngine.connect(playerNode, to: outputNode, format: Self.pcmFormat)
    
    // start the engine and player node
    do {
      try audioEngine.start()
      playerNode.play()
    } catch {
      print("[Voice] Failed to start audio engine: \(error)")
      return
    }
    
    // make player node schedule buffers as they come in from the gateway in task
    self.incomingAudioTask = Task {
      guard let voiceGateway else { return }

      for await opusFrame in await voiceGateway.incomingOpusPackets {
        if Task.isCancelled { break }

        guard let buffer = try? opusDecoder.decode(opusFrame) else {
          continue
        }

        await MainActor.run {
          self.playerNode.scheduleBuffer(buffer, completionHandler: nil)
        }
      }
    }
  }
  
  private func audioEngineCleanup() {
    // cancel incoming audio task
    incomingAudioTask?.cancel()
    
    // stop the engine and reset everything
    audioEngine.stop()
    playerNode.stop()
    audioEngine.reset()
    // remove player node from engine
    audioEngine.detach(playerNode)
  }
}
