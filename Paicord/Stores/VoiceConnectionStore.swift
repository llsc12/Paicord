//
//  VoiceConnectionStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 23/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import AVFoundation
import Foundation
import Opus
import PaicordLib

@Observable
final class VoiceConnectionStore: DiscordDataStore {
  init() {
    // safe afaik bc all it throws for is invalid format
    self.opusEncoder = try! Opus.Encoder(
      format: Self.opusFormat,
      application: .voip
    )
  }

  var gateway: GatewayStore?
  var voiceGateway: VoiceGatewayManager? {
    didSet {
      if voiceGateway != nil {
        setupVoiceEventHandling()
        // trigger audio engine setup
        audioEngineSetup()
      } else {
        self.voiceEventTask?.cancel()
        self.voiceErrorEventTask?.cancel()
        // shutdown audio engine and release resources, also set status to stopped
        voiceStatus = .stopped
        audioEngineCleanup()

        // clear up state, reinit encoder.
        try? self.opusEncoder.reset()
        self.usersSpeakingState.removeAll()
        self.knownSSRCs.removeAll()
      }
    }
  }

  var eventTask: Task<Void, Never>?
  var voiceEventTask: Task<Void, Never>?
  var voiceErrorEventTask: Task<Void, Never>?

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

  func setupVoiceEventHandling() {
    guard let voiceGateway = voiceGateway else { return }

    voiceEventTask = Task { @MainActor in
      for await event in await voiceGateway.events {
        switch event.data {
        case .clientDisconnect(let payload):
          await handleClientDisconnect(payload)
        case .speaking(let payload):
          await handleSpeaking(payload)
        default: break
        }
      }
    }
    voiceErrorEventTask = Task { @MainActor in
      for await (error, buffer) in await voiceGateway.eventFailures {
        print("[Voice Error] \(error), \(String(buffer: buffer))")
      }
    }
  }

  // MARK: - State
  // our own voice state stuff
  private var channelId: ChannelSnowflake?
  private var guildId: GuildSnowflake?
  private var isMuted: Bool = false
  private var isDeafened: Bool = false
  private var isVideoEnabled: Bool = false
  private var preferredRegion: String?
  private var flags: IntBitField<VoiceStateUpdate.Flags> = []

  // if in a vc, this contains our speaking state and other ppl's speaking state.
  var usersSpeakingState:
    [UserSnowflake: IntBitField<VoiceGateway.Speaking.Flag>] = [:]
  private var knownSSRCs: [UInt: UserSnowflake] = [:]

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

    print(
      "[Voice] Attempting to connect to voice channel \(channelId.rawValue) in guild \(guildId?.rawValue ?? "DMs")"
    )
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
        print(
          "[Voice] Received voice server update with empty endpoint, disconnecting from voice"
        )
        Task { await voiceGateway?.disconnect() }
        voiceGateway = nil
        return
      }

      print(
        "[Voice] Received voice server update, connecting to voice gateway at endpoint \(endpoint) for guild \(guildId.rawValue) and channel \(channelId.rawValue)"
      )
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

  private func handleClientDisconnect(_ payload: VoiceGateway.ClientDisconnect)
    async
  {
    // someone other than us left the voice channel.
    let id = payload.user_id
    let ssrc = self.knownSSRCs.first(where: { $0.value == id })?.key
    if let ssrc {
      await removeIncomingStreamIfPresent(ssrc: .init(ssrc))
    }
  }

  private func handleSpeaking(_ payload: VoiceGateway.Speaking) async {
    // someone started or stopped speaking, we can use this to show speaking indicators.
    let ssrc = payload.ssrc

    if let id = payload.user_id {
      self.knownSSRCs[ssrc] = id
      self.usersSpeakingState[id] = payload.speaking
    }
    await ensureIncomingStreamExists(ssrc: .init(ssrc))
  }

  func cancelEventHandling() {
    // overrides default impl of protocol
    eventTask?.cancel()
    eventTask = nil
    Task {
      await voiceGateway?.disconnect()
      voiceGateway = nil
    }
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
  // NOTE: decoder is now created per-SSRC

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

  // one incoming audio stream per user's audio ssrc to mix.
  private final class IncomingStream {
    let ssrc: UInt32
    let decoder: Opus.Decoder
    let playerNode: AVAudioPlayerNode

    init(ssrc: UInt32) {
      self.ssrc = ssrc
      // safe afaik bc all it throws for is invalid format
      self.decoder = try! Opus.Decoder(
        format: VoiceConnectionStore.opusFormat,
        application: .voip
      )
      self.playerNode = AVAudioPlayerNode()
    }
  }

  @ObservationIgnored
  private var incomingStreamsBySSRC: [UInt32: IncomingStream] = [:]

  @ObservationIgnored
  private var incomingAudioTask: Task<Void, Never>? = nil

  @ObservationIgnored
  private let dummyPlayerNode = AVAudioPlayerNode()

  @ObservationIgnored
  private var dummyNodeAttached: Bool = false

  private func audioEngineSetup() {
    self.audioEngineCleanup()

    Task { @MainActor in
      self.ensureDummyNodeAttached()

      do {
        audioEngine.prepare()
        try audioEngine.start()
      } catch {
        print("[Voice] Failed to start audio engine:", error)
        return
      }
    }

    guard let voiceGateway = self.voiceGateway else { return }

    incomingAudioTask = Task.detached(priority: .userInitiated) { [weak self] in
      guard let self else { return }

      for await rtpPacket in await voiceGateway.incomingAudioChannel {
        if Task.isCancelled { break }

        let ssrc = rtpPacket.ssrc
        self.ensureIncomingStreamExists(ssrc: ssrc)

        guard
          let stream = self.incomingStreamsBySSRC[ssrc]
        else {
          continue
        }

        do {
          let opusFrame = rtpPacket.payload
          let decoded = try stream.decoder.decode(
            .init(buffer: opusFrame, byteTransferStrategy: .noCopy)
          )

          // manually de-interleave.
          guard
            let converted = AVAudioPCMBuffer(
              pcmFormat: Self.pcmFormat,
              frameCapacity: decoded.frameLength
            )
          else { continue }
          converted.frameLength = decoded.frameLength

          let src = decoded.floatChannelData![0]
          let dstL = converted.floatChannelData![0]
          let dstR = converted.floatChannelData![1]
          for i in 0..<Int(decoded.frameLength) {
            dstL[i] = src[i * 2]
            dstR[i] = src[i * 2 + 1]
          }

          Task {
            await stream.playerNode.scheduleBuffer(converted)
          }
        } catch {
          print("[Voice OPUS] Frame decode error for ssrc \(ssrc):", error)
        }
      }
    }
  }

  private func ensureDummyNodeAttached() {
    guard !dummyNodeAttached else { return }

    audioEngine.attach(dummyPlayerNode)
    audioEngine.connect(
      dummyPlayerNode,
      to: audioEngine.mainMixerNode,
      format: Self.pcmFormat
    )

    dummyNodeAttached = true
  }

  private func ensureIncomingStreamExists(ssrc: UInt32) {
    if incomingStreamsBySSRC[ssrc] != nil { return }

    let stream = IncomingStream(ssrc: ssrc)
    incomingStreamsBySSRC[ssrc] = stream

    audioEngine.attach(stream.playerNode)
    audioEngine.connect(
      stream.playerNode,
      to: audioEngine.mainMixerNode,
      format: Self.pcmFormat
    )
    stream.playerNode.play()

    print("[Voice] Created incoming stream for ssrc \(ssrc)")
  }

  private func removeIncomingStreamIfPresent(ssrc: UInt32) {
    guard let stream = incomingStreamsBySSRC.removeValue(forKey: ssrc) else {
      return
    }

    stream.playerNode.stop()

    if audioEngine.attachedNodes.contains(stream.playerNode) {
      audioEngine.detach(stream.playerNode)
    }

    print("[Voice] Removed incoming stream for ssrc \(ssrc)")
  }

  private func audioEngineCleanup() {
    incomingAudioTask?.cancel()
    incomingAudioTask = nil

    Task { @MainActor in
      for (ssrc, stream) in incomingStreamsBySSRC {
        stream.playerNode.stop()
        if audioEngine.attachedNodes.contains(stream.playerNode) {
          audioEngine.detach(stream.playerNode)
        }
        print("[Voice] Removed incoming stream for ssrc=\(ssrc) (cleanup)")
      }
      incomingStreamsBySSRC.removeAll()

      dummyPlayerNode.stop()
      if audioEngine.attachedNodes.contains(dummyPlayerNode) {
        audioEngine.detach(dummyPlayerNode)
      }
      dummyNodeAttached = false

      audioEngine.stop()
      audioEngine.reset()
      print("[Voice] Audio engine stopped")
    }
  }
}
