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

  private init(
    inbound: NIOAsyncChannelInboundStream<AddressedEnvelope<ByteBuffer>>,
    outbound: NIOAsyncChannelOutboundWriter<AddressedEnvelope<ByteBuffer>>,
    socketAddress: SocketAddress
  ) {
    self.inbound = inbound
    self.outbound = outbound
    self.address = socketAddress
  }

  static func connect(
    host: String,
    port: Int,
    onConnect:
      @Sendable @escaping (VoiceConnection) async throws -> Void
  ) async throws {
    let socketAddress = try SocketAddress(ipAddress: host, port: port)
    let server = try await DatagramBootstrap(
      group: NIOSingletons.posixEventLoopGroup
    )
    .bind(to: socketAddress)
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
        socketAddress: socketAddress
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
    var buffer = ByteBufferAllocator().buffer(capacity: 74)
    buffer.writeInteger(UInt16(0x1))  // Type (Send)
    buffer.writeInteger(UInt16(70))  // Length
    buffer.writeInteger(ssrc)
    try await outbound.write(
      AddressedEnvelope(
        remoteAddress: address,
        data: buffer
      )
    )

    var iterator = inbound.makeAsyncIterator()
    guard let discoveryResponse = try await iterator.next() else {
      return nil
    }

    let data = discoveryResponse.data
    guard
      let address = data.getData(at: 6, length: 64),
      let address = String(
        data: address.prefix(
          upTo: address.firstIndex(of: 0) ?? address.endIndex
        ),
        encoding: .utf8,
      ),
      let port = data.getInteger(at: 70, as: UInt16.self)
    else {
      return nil
    }
    return (ip: address, port: port)
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
  func keepalive(ssrc: UInt32) async throws {
    for await _ in AsyncTimerSequence(
      interval: Self.keepaliveInterval,
      clock: .continuous
    ) {
      var buffer: ByteBuffer = ByteBufferAllocator().buffer(capacity: 4)
      buffer.writeInteger(ssrc, endianness: .big)
      try await send(buffer: buffer)
    }
  }
}
