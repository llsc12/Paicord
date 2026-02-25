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
import Foundation 

@Observable
final class VoiceConnectionStore: DiscordDataStore {
  init() {
    // safe afaik bc all it throws for is invalid format
    self.opusEncoder = try! Opus.Encoder(format: Self.opusFormat, application: .voip)
    self.opusDecoder = try! Opus.Decoder(format: Self.opusFormat, application: .voip)
  }
  
  var gateway: GatewayStore?
  var voiceGateway: VoiceGatewayManager? {
    didSet {
      if voiceGateway != nil {
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

  private var voiceStatus: GatewayState = .stopped {
    didSet {
      print("[Voice] Voice connection status changed to \(voiceStatus)")
    }
  }
  // MARK: - Public methods

  func updateVoiceConnection(_ update: VoiceConnectionUpdate) async {
    // for changing currently connected channel or disconnecting from voice, we still stop everything
    await voiceGateway?.disconnect()
    voiceGateway = nil
    // if we wanted to disconnect, just return here
    if case .disconnect = update {
      self.channelId = nil
      self.guildId = nil
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
      print("[Voice] Disconnected from voice channel")
      return
    }
    // well at this point we know we want to connect to a new channel.
    // to start a new voice connection, we need to get the necessary data from the gateway.
    // we update our voice state on the gateway so we get a voice server update.
    guard case .join(let channelId, let guildId) = update else { return }
    self.channelId = channelId
    self.guildId = guildId

    print("[Voice] Attempting to connect to voice channel \(channelId.rawValue) in guild \(guildId?.rawValue ?? "DMs")")
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
        print("[Voice] Received voice server update with empty endpoint, disconnecting from voice")
        Task { await voiceGateway?.disconnect() }
        voiceGateway = nil
        return
      }

      print("[Voice] Received voice server update, connecting to voice gateway at endpoint \(endpoint) for guild \(guildId.rawValue) and channel \(channelId.rawValue)")
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
      await self.voiceGateway?.connect()
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
    opusPCMFormat: .float32,
    sampleRate: .opus48khz,
    channels: 2
  )!
  private static let pcmFormat = AVAudioFormat(
    commonFormat: .pcmFormatFloat32,
    sampleRate: .opus48khz,
    channels: 2,
    interleaved: false
  )!
  @ObservationIgnored
  private let opusEncoder: Opus.Encoder
  @ObservationIgnored
  private let opusDecoder: Opus.Decoder

  @ObservationIgnored
  private let audioEngine = AVAudioEngine()
  @ObservationIgnored
  private lazy var inputNode: AVAudioInputNode = {
    return audioEngine.inputNode
  }()
  @ObservationIgnored
  private lazy var outputNode: AVAudioOutputNode = {
    return audioEngine.outputNode
  }()

  // audio player node for playing incoming audio frames
  @ObservationIgnored
  private let playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
  
  @ObservationIgnored
  private var incomingAudioTask: Task<Void, Never>? = nil


  private func audioEngineSetup() {
    self.audioEngineCleanup()
    Task { @MainActor in
      

//      if !audioEngine.attachedNodes.contains(playerNode) {
//        audioEngine.attach(playerNode)
//      }
//
//      let engineOutputFormat = audioEngine.outputNode.inputFormat(forBus: 0)
//
//      audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: engineOutputFormat)
//
//      audioEngine.prepare()
//      do {
//        try audioEngine.start()
//        playerNode.play()
//      } catch {
//        print("[Voice] Failed to start audio engine: \(error)")
//        return
//      }

      incomingAudioTask = Task { [weak self] in
        guard let self = self, let voiceGateway = self.voiceGateway else { return }

        for await opusFrame in await voiceGateway.incomingOpusPackets {
          if Task.isCancelled { break }

          guard let decoded = try? self.opusDecoder.decode(opusFrame) else {
            continue
          }
         
          print(decoded.format.debugDescription)
 
        }
      }

      print("[Voice] Audio engine started")
    }
  }

  private func audioEngineCleanup() {
    Task { @MainActor in
      // cancel incoming audio task
      self.incomingAudioTask?.cancel()
      
      // stop the engine and reset everything
      self.audioEngine.stop()
      self.playerNode.stop()
      self.audioEngine.reset()
      // remove player node from engine
      self.audioEngine.detach(self.playerNode)
      
      print("[Voice] Audio engine stopped")
    }
  }
}
