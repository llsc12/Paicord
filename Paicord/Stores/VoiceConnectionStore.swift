//
//  VoiceConnectionStore.swift
//  Paicord
//
//  Created by Lakhan Lothiyi on 23/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import AVFoundation
import AsyncAlgorithms
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

    if AVAudioApplication.shared.recordPermission == .granted {
      self.isMuted = false
    } else {
      self.isMuted = true
    }

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(audioEngineConfigurationChange),
      name: .AVAudioEngineConfigurationChange,
      object: audioEngine
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(
      self,
      name: .AVAudioEngineConfigurationChange,
      object: audioEngine
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
        cancelVoiceEventHandling()

        // shutdown audio engine and release resources
        audioEngineCleanup()
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
        case .resume(let payload):
          handleResume(payload)
        case .voiceServerUpdate(let payload):
          handleVoiceServerUpdate(payload)
        case .voiceStateUpdate(let payload):
          handleVoiceStateUpdate(payload)
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
  private(set) var channelId: ChannelSnowflake?
  private(set) var guildId: GuildSnowflake?
  private(set) var isMuted: Bool = false
  private(set) var isDeafened: Bool = false
  private(set) var isVideoEnabled: Bool = false
  private(set) var preferredRegion: String?
  private(set) var flags: IntBitField<VoiceStateUpdate.Flags> = []

  private(set) var voiceStatus: GatewayState = .stopped {
    didSet {
      print("[Voice] Voice connection status changed to \(voiceStatus)")
    }
  }

  // MARK: - Public methods

  func updateVoiceConnection(_ update: VoiceConnectionUpdate) async {
    if case .join(let channelId, let guildId) = update,
      self.channelId == channelId && self.guildId == guildId
    {
      return
    }
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
    if let isMuted = isMuted {
      if AVAudioApplication.shared.recordPermission == .granted {
        self.isMuted = isMuted
      } else {
        self.isMuted = true
      }
    }
    if let isDeafened = isDeafened { self.isDeafened = isDeafened }
    if let isVideoEnabled = isVideoEnabled {
      self.isVideoEnabled = isVideoEnabled
    }

    self.audioEngine.mainMixerNode.outputVolume = self.isDeafened ? 0 : 1

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
          flags: self.flags
        )
      )
    }
  }

  private func handleResume(_ payload: Gateway.Resume) {
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
          flags: self.flags
        )
      )
    }
  }

  private func handleVoiceServerUpdate(_ payload: Gateway.VoiceServerUpdate) {
    // if the endpoint is empty/nil, it means we got disconnected from voice, so disconnect from our voice gateway and return early
    // else we can start a new voice gateway connection with the new endpoint and token
    Task {
      guard let endpoint = payload.endpoint, !endpoint.isEmpty,
        let channelId,
        let sessionId = await gateway?.gateway?.getSessionID(),
        let userId = gateway?.user.currentUser?.id
      else {
        print(
          "[Voice] Received voice server update with empty endpoint, disconnecting from voice"
        )
        Task {
          await voiceGateway?.disconnect()
          voiceGateway = nil
          await gateway?.gateway?.updateVoiceState(
            payload: .init(
              guild_id: nil,
              channel_id: nil,
              self_mute: self.isMuted,
              self_deaf: self.isDeafened,
              self_video: self.isVideoEnabled,
              preferred_region: self.preferredRegion,
              preferred_regions: nil,
              flags: flags
            )
          )
        }
        return
      }

      print(
        "[Voice] Received voice server update, connecting to voice gateway at endpoint \(endpoint) for guild \(guildId?.rawValue ?? "nil") and channel \(channelId.rawValue)"
      )
      self.voiceGateway = VoiceGatewayManager.init(
        connectionData: .init(
          token: payload.token,
          guildID: self.guildId ?? .init(channelId.rawValue),
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

      if AVAudioApplication.shared.recordPermission != .granted {
        await AVAudioApplication.requestRecordPermission()
      }
      
      if self.guildId == nil {
        print("[Voice] Ringing DM recipients")
        try? await gateway?.client.ringChannelRecipients(channelID: channelId, payload: .init()).guardSuccess()
      }
    }
  }

  private func handleVoiceStateUpdate(_ payload: VoiceState) {
    // if we receie a voice state payload and it contains a session
    // id that isnt this client's current session id, we joined
    // from another client and we should destroy this connection.

    // criteria for disconnecting:
    // - there actually is a voice connection to disconnect from
    // - its a voice state update for our user id
    // - session id isnt ours
    // - payload guild id matches the current guild id

    Task {
      let vUserId = payload.user_id
      let vSessionID = payload.session_id
      let vGuildID = payload.guild_id

      if
        voiceGateway != nil,
        self.gateway?.user.currentUser?.id == vUserId,
        self.guildId == vGuildID,
        await self.gateway?.gateway?.getSessionID() != vSessionID
      {
        print("[Voice] Another client made this client disconnect")
        await voiceGateway?.disconnect()
        voiceGateway = nil
      }
    }
  }

  private func handleClientDisconnect(_ payload: VoiceGateway.ClientDisconnect)
    async
  {
    // someone other than us left the voice channel.
    let id = payload.user_id
    let ssrc = self.knownSSRCs.first(where: { $0.value == id })?.key
    if let ssrc {
      removeIncomingStreamIfPresent(ssrc: .init(ssrc))
    }
  }

  private func handleSpeaking(_ payload: VoiceGateway.Speaking) async {
    // someone started or stopped speaking, we can use this to show speaking indicators.
    let ssrc = payload.ssrc

    if let id = payload.user_id {
      self.knownSSRCs[ssrc] = id
      self.usersSpeakingState[id] = payload.speaking
    }
    ensureIncomingStreamExists(ssrc: .init(ssrc))
  }

  func cancelEventHandling() {
    // overrides default impl of protocol
    eventTask?.cancel()
    eventTask = nil
    cancelVoiceEventHandling()
    Task {
      await voiceGateway?.disconnect()
      voiceGateway = nil
    }
  }

  private func cancelVoiceEventHandling() {
    voiceEventTask?.cancel()
    voiceEventTask = nil
    voiceErrorEventTask?.cancel()
    voiceErrorEventTask = nil
    voiceStatus = .stopped
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
    let scheduler: PlayerScheduler

    init(ssrc: UInt32) {
      self.ssrc = ssrc
      // safe afaik bc all it throws for is invalid format
      self.decoder = try! Opus.Decoder(
        format: VoiceConnectionStore.opusFormat,
        application: .voip
      )
      self.playerNode = AVAudioPlayerNode()
      self.scheduler = PlayerScheduler(node: self.playerNode)
    }

    deinit {
      playerNode.stop()
      try? decoder.reset()
    }
  }

  private actor PlayerScheduler {
    private weak var node: AVAudioPlayerNode?
    private var queue: [AVAudioPCMBuffer] = []
    private var draining = false

    init(node: AVAudioPlayerNode) {
      self.node = node
    }

    func enqueue(_ buffer: AVAudioPCMBuffer) {
      queue.append(buffer)
      if !draining {
        draining = true
        Task { await drain() }
      }
    }

    private func drain() async {
      defer { draining = false }
      while !queue.isEmpty {
        guard let node else { return }
        let buf = queue.removeFirst()
        node.scheduleBuffer(buf, completionHandler: nil)
        await Task.yield()
      }
    }
  }

  @ObservationIgnored
  private var incomingStreamsBySSRC: [UInt32: IncomingStream] = [:]

  @ObservationIgnored
  private var incomingAudioTask: Task<Void, Never>? = nil

  @ObservationIgnored
  private var outgoingAudioTask: Task<Void, Never>? = nil

  @ObservationIgnored
  private let dummyPlayerNode = AVAudioPlayerNode()

  // MARK: - States

  // if in a vc, this contains our speaking state and other ppl's speaking state.
  var usersSpeakingState:
    [UserSnowflake: IntBitField<VoiceGateway.Speaking.Flag>] = [:]

  private var knownSSRCs: [UInt: UserSnowflake] = [:]

  private(set) var userVolumes: [UserSnowflake: Float] = [:]

  func setVolume(for userId: UserSnowflake, volume: Float) {
    userVolumes[userId] = volume

    guard let ssrc = knownSSRCs.first(where: { $0.value == userId })?.key,
      let stream = incomingStreamsBySSRC[UInt32(ssrc)]
    else { return }

    stream.playerNode.volume = volume
  }

  // MARK: - Audio engine setup and handling

  @objc private func audioEngineConfigurationChange() {
    print("[Voice] Audio engine configuration changed, resetting audio engine")
    self.audioEngineSetup()
  }

  private func audioEngineSetup() {
    Task {
      self.audioEngineCleanup()

      /// avaudioengine will throw a c++ exception if you start it when `inputNode == nullptr || outputNode == nullptr`.
      self.ensureDummyNodeAttached()

      /// microphone tap
      self.setupTap()

      /// voice processing mode
      do {
        try inputNode.setVoiceProcessingEnabled(true)
        inputNode.isVoiceProcessingAGCEnabled = true
        inputNode.isVoiceProcessingBypassed = false
        inputNode.isVoiceProcessingInputMuted = false

      } catch {
        print("[Voice] Failed to enable voice processing mode:", error)
      }

      do {
        try audioEngine.start()
      } catch {
        print("[Voice] Failed to start audio engine:", error)
        return
      }
      print("[Voice] Audio engine started")

      audioEngine.mainMixerNode.outputVolume = self.isDeafened ? 0 : 1

      guard let voiceGateway = self.voiceGateway else { return }

      incomingAudioTask = Task.detached(priority: .userInitiated) {
        [weak self] in
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

            // ensure buffer scheduling is immediate, avoiding actually awaiting.
            // awaiting causes stuttering bc callback happens when buffer finishes
            // playing and the node runs dry.
            Task {
              await stream.scheduler.enqueue(converted)
            }
          } catch {
            print("[Voice OPUS] Frame decode error for ssrc \(ssrc):", error)
          }
        }
      }
    }
  }

  @ObservationIgnored
  private let micChannel = AsyncChannel<AVAudioPCMBuffer>()

  private func setupTap() {
    let targetFormat = Self.pcmFormat

    let opusFrameCount: AVAudioFrameCount = 960
    let opusFrameSize = Int(opusFrameCount)

    var ring = PCMFloatRingBuffer(
      channels: Int(targetFormat.channelCount),
      capacityFrames: opusFrameSize * 8
    )

    let initialTapFormat = inputNode.inputFormat(forBus: 0)
    print("[Voice] Installing tap with format:", initialTapFormat)

    // Initialize upfront to prevent clicking artifacts and preserve internal converter state
    var converter = AVAudioConverter(from: initialTapFormat, to: targetFormat)
    var lastTapFormat = initialTapFormat

    inputNode.installTap(
      onBus: 0,
      bufferSize: opusFrameCount,
      format: nil
    ) { [weak self] buffer, _ in
      guard let self = self, buffer.frameLength > 0 else { return }

      if lastTapFormat != buffer.format {
        lastTapFormat = buffer.format
        converter = AVAudioConverter(from: buffer.format, to: targetFormat)
      }

      guard let activeConverter = converter else { return }

      let inputRate = buffer.format.sampleRate
      let outputRate = targetFormat.sampleRate
      let capacityRate = outputRate / inputRate
      let capacity = AVAudioFrameCount(
        ceil(Double(buffer.frameLength) * capacityRate) + 1
      )

      guard
        let convertedBuffer = AVAudioPCMBuffer(
          pcmFormat: targetFormat,
          frameCapacity: capacity
        )
      else { return }

      var error: NSError?
      var inputBlockProvided = false
      let status = activeConverter.convert(to: convertedBuffer, error: &error) {
        inNumPackets,
        outStatus in
        if inputBlockProvided {
          outStatus.pointee = .noDataNow
          return nil
        }
        inputBlockProvided = true
        outStatus.pointee = .haveData
        return buffer
      }

      if status == .error || error != nil {
        print("[Voice] Audio conversion error: \(String(describing: error))")
        return
      }

      guard convertedBuffer.frameLength > 0,
        let src = convertedBuffer.floatChannelData
      else { return }

      ring.write(
        from: src,
        frames: Int(convertedBuffer.frameLength),
        srcChannels: Int(targetFormat.channelCount)
      )

      while ring.availableFrames >= opusFrameSize {
        guard
          let chunk = AVAudioPCMBuffer(
            pcmFormat: Self.pcmFormat,
            frameCapacity: opusFrameCount
          )
        else {
          break
        }
        chunk.frameLength = opusFrameCount
        guard let dst = chunk.floatChannelData else { break }

        guard ring.read(into: dst, frames: opusFrameSize) else { break }
        Task { await self.micChannel.send(chunk) }
      }
    }

    outgoingAudioTask = Task(priority: .userInitiated) { [weak self] in
      guard let self else { return }
      var opusOutputBuffer = Data(count: 1275)

      for await buffer in self.micChannel {
        if Task.isCancelled { break }
        if self.isMuted { continue }

        do {
          guard let interleaved = self.interleavedBuffer(from: buffer) else {
            continue
          }
          let encodedSize = try self.opusEncoder.encode(
            interleaved,
            to: &opusOutputBuffer
          )
          await self.voiceGateway?.enqueueOpusFrame(
            opusOutputBuffer.prefix(encodedSize)
          )
        } catch {
          print("[Voice OPUS] Frame encode error:", error)
        }
      }
    }
  }

  @ObservationIgnored
  private var interleavedScratch: AVAudioPCMBuffer?

  private func interleavedBuffer(from planar: AVAudioPCMBuffer)
    -> AVAudioPCMBuffer?
  {
    let frames = Int(planar.frameLength)
    guard frames > 0 else { return nil }
    guard planar.format.channelCount == 2 else { return nil }
    guard let src = planar.floatChannelData else { return nil }

    let sampleRate = planar.format.sampleRate

    let needsNew: Bool = {
      guard let b = interleavedScratch else { return true }
      return b.format.sampleRate != sampleRate
        || b.format.channelCount != 2
        || !b.format.isInterleaved
        || Int(b.frameCapacity) < frames
    }()

    if needsNew {
      guard
        let fmt = AVAudioFormat(
          commonFormat: .pcmFormatFloat32,
          sampleRate: sampleRate,
          channels: 2,
          interleaved: true
        ),
        let b = AVAudioPCMBuffer(
          pcmFormat: fmt,
          frameCapacity: AVAudioFrameCount(max(frames, 960))
        )
      else { return nil }
      interleavedScratch = b
    }

    guard let out = interleavedScratch,
      let dst = out.floatChannelData?[0]
    else { return nil }

    out.frameLength = AVAudioFrameCount(frames)

    let l = src[0]
    let r = src[1]
    for i in 0..<frames {
      dst[i * 2] = l[i]
      dst[i * 2 + 1] = r[i]
    }

    return out
  }

  private func ensureDummyNodeAttached() {
    guard !self.audioEngine.attachedNodes.contains(dummyPlayerNode) else {
      return
    }

    audioEngine.attach(dummyPlayerNode)
    audioEngine.connect(
      dummyPlayerNode,
      to: audioEngine.mainMixerNode,
      format: Self.pcmFormat
    )
  }

  private func ensureIncomingStreamExists(ssrc: UInt32) {
    if incomingStreamsBySSRC[ssrc] != nil { return }
    // ensure it isn't us
    guard knownSSRCs[UInt(ssrc)] != gateway?.user.currentUser?.id else {
      return
    }

    let stream = IncomingStream(ssrc: ssrc)
    incomingStreamsBySSRC[ssrc] = stream

    audioEngine.attach(stream.playerNode)
    audioEngine.connect(
      stream.playerNode,
      to: audioEngine.mainMixerNode,
      format: Self.pcmFormat
    )

    if let userId = knownSSRCs[UInt(ssrc)] {
      stream.playerNode.volume = userVolumes[userId] ?? 1.0
    }

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
    outgoingAudioTask?.cancel()
    outgoingAudioTask = nil

    for (ssrc, stream) in incomingStreamsBySSRC {
      stream.playerNode.stop()
      if audioEngine.attachedNodes.contains(stream.playerNode) {
        audioEngine.detach(stream.playerNode)
      }
      print("[Voice] Removed incoming stream for ssrc \(ssrc) (cleanup)")
    }
    incomingStreamsBySSRC.removeAll()

    dummyPlayerNode.stop()
    if audioEngine.attachedNodes.contains(dummyPlayerNode) {
      audioEngine.detach(dummyPlayerNode)
    }

    inputNode.removeTap(onBus: 0)

    audioEngine.stop()
    audioEngine.reset()
    print("[Voice] Audio engine stopped")

    // clear up state, reinit encoder.
    try? self.opusEncoder.reset()

    self.usersSpeakingState.removeAll()
    self.knownSSRCs.removeAll()
    self.interleavedScratch = nil
  }
}
