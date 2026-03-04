//
//  VoiceConnection.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 22/02/2026.
//  Copyright © 2026 Lakhan Lothiyi.
//

import AsyncAlgorithms
import NIO

/// This contains the UDP connection. ``VoiceGatewayManager`` handles lifecycle and also handles send recv.
internal actor VoiceConnection {
  private static let keepaliveInterval: Duration = .seconds(5)

  let address: SocketAddress
  let inbound: NIOAsyncChannelInboundStream<AddressedEnvelope<ByteBuffer>>
  let outbound: NIOAsyncChannelOutboundWriter<AddressedEnvelope<ByteBuffer>>
  let audioStream: AsyncStream<ByteBuffer>
  private let audioContinuation: AsyncStream<ByteBuffer>.Continuation
  var discoveryContinuation:
    CheckedContinuation<(ip: String, port: UInt16)?, Never>?

  private init(
    inbound: NIOAsyncChannelInboundStream<AddressedEnvelope<ByteBuffer>>,
    outbound: NIOAsyncChannelOutboundWriter<AddressedEnvelope<ByteBuffer>>,
    socketAddress: SocketAddress
  ) {
    self.inbound = inbound
    self.outbound = outbound
    self.address = socketAddress

    var continuation: AsyncStream<ByteBuffer>.Continuation!
    self.audioStream = AsyncStream { continuation = $0 }
    self.audioContinuation = continuation

    Task {
      for try await envelope in inbound {
        await handleIncoming(envelope.data)
      }
      audioContinuation.finish()
    }
  }

  private func handleIncoming(_ data: ByteBuffer) {
    // Check packet type first
    if let type: UInt16 = data.getInteger(at: 0, endianness: .big),
      type == 2,
      let continuation = discoveryContinuation
    {

      discoveryContinuation = nil

      if let addressData = data.getData(at: 8, length: 64),
        let address = String(
          data: addressData.prefix(
            upTo: addressData.firstIndex(of: 0) ?? addressData.endIndex
          ),
          encoding: .utf8
        ),
        let port = data.getInteger(at: 72, endianness: .little, as: UInt16.self)
      {

        continuation.resume(returning: (address, port))
        return
      }

      continuation.resume(returning: nil)
      return
    }

    audioContinuation.yield(data)
  }

  static func connect(
    host: String,
    port: Int,
    onConnect:
      @Sendable @escaping (VoiceConnection) async throws -> Void
  ) async throws {
    let remoteAddress = try SocketAddress(ipAddress: host, port: port)

    let localAddress = try SocketAddress(ipAddress: "0.0.0.0", port: 0)

    let server = try await DatagramBootstrap(
      group: NIOSingletons.posixEventLoopGroup
    )
    .bind(to: localAddress)
    .flatMap { channel in
      channel.connect(to: remoteAddress).map { channel }
    }
    .flatMapThrowing { channel in
      return try NIOAsyncChannel(
        wrappingChannelSynchronously: channel,
        configuration: NIOAsyncChannel.Configuration(
          inboundType: AddressedEnvelope<ByteBuffer>.self,
          outboundType: AddressedEnvelope<ByteBuffer>.self
        )
      )
    }
    .get()

    try await server.executeThenClose { inbound, outbound in
      let connection = VoiceConnection(
        inbound: inbound,
        outbound: outbound,
        socketAddress: remoteAddress
      )

      try await onConnect(connection)
    }
  }

  /// Asks Discord to give us our IP address and port, punching a hole through our local network's NAT (to the wider internet).
  /// We can then send this IP to discord via voice gateway payload selectProtocol so they know where to send us audio data.
  /// We also keepalive so the route through NAT doesn't collapse.
  /// - Parameter ssrc: The SSRC of our audio stream.
  /// - Returns: Tuple of IP and port.
  func discoverExternalIP(
    ssrc: UInt32,
  ) async throws -> (ip: String, port: UInt16)? {
    guard self.discoveryContinuation == nil else { return nil }

    var buffer = ByteBufferAllocator().buffer(capacity: 74)
    buffer.writeInteger(UInt16(1), endianness: .big)  // Type
    buffer.writeInteger(UInt16(70), endianness: .big)  // Length
    buffer.writeInteger(ssrc, endianness: .big)  // SSRC
    buffer.writeBytes(Array(repeating: 0, count: 66))  // Padding
    try await outbound.write(
      AddressedEnvelope(
        remoteAddress: address,
        data: buffer
      )
    )

    return await withCheckedContinuation { continuation in
      self.discoveryContinuation = continuation
    }
  }

  func send(buffer: ByteBuffer) async throws {
    try await outbound.write(
      AddressedEnvelope(
        remoteAddress: address,
        data: buffer
      )
    )
  }

  /// Start sending keepalive packets at regular intervals, keeping the connection alive.
  var keepaliveCounter: UInt32 = 0
  func keepalive(ssrc: UInt32) async throws {
    // 13 37 CA FE [keepaliveCounter]
    // Discord will reply with:
    // 13 37 F0 0D [keepaliveCounter]
    // but we dont care lol
    for await _ in AsyncTimerSequence(
      interval: Self.keepaliveInterval,
      clock: .continuous
    ) {
      self.keepaliveCounter += 1

      var buffer: ByteBuffer = ByteBufferAllocator().buffer(capacity: 8)
      buffer.writeInteger(UInt16(0x1337), endianness: .big)
      buffer.writeInteger(UInt16(0xCAFE), endianness: .big)
      buffer.writeInteger(keepaliveCounter, endianness: .little)
      try await send(buffer: buffer)
    }
  }
}

