import CompressNIO
import Logging
import NIOCore
import NIOWebSocket
import WSClient

private let zlibAllocator = ByteBufferAllocator()
private let minimumAllocation = 4070
/// `4096` - `26` allocator margin

/// Will be used for only 1 WS connection so won't need concurrency guards.
struct ZlibDecompressorWSExtension: WebSocketExtension, @unchecked Sendable {
    let name = "zlib-stream"
    let decompressor: ZlibDecompressor
    let logger: Logger

    init(logger: Logger) throws {
        self.decompressor = try ZlibDecompressor(algorithm: .zlib, windowSize: 15)
        self.logger = logger
    }

    func processReceivedFrame(_ frame: WebSocketFrame, context: WebSocketExtensionContext) throws -> WebSocketFrame {
        var frame = frame
        let compressedBytes = frame.data.readableBytes
        frame.data = try self.decompress(
            compressedBytes: compressedBytes,
            from: &frame.data
        )
        logger.trace(
            "Decompressed a Discord message",
            metadata: [
                "compressedBytes": .stringConvertible(compressedBytes),
                "decompressedBytes": .stringConvertible(frame.data.readableBytes),
                "firstAllocation": .stringConvertible(
                    self.nextAllocation(
                        compressedBytes: compressedBytes,
                        currentlyAllocated: nil
                    )
                ),
            ]
        )
        return frame
    }

    func decompress(
        compressedBytes: Int,
        from frame: inout ByteBuffer
    ) throws -> ByteBuffer {
        var buffer = zlibAllocator.buffer(
            capacity: self.nextAllocation(
                compressedBytes: compressedBytes,
                currentlyAllocated: nil
            )
        )
        while true {
            do {
                try self.decompressor.inflate(
                    from: &frame,
                    to: &buffer
                )
                /// If no errors were thrown then the decompression must have fully succeeded.
                return buffer
            } catch let error as CompressNIOError where error == .bufferOverflow {
                /// If we have a `.bufferOverflow`, increase the capacity and continue the loop.
                buffer.reserveCapacity(
                    minimumWritableBytes: self.nextAllocation(
                        compressedBytes: compressedBytes,
                        currentlyAllocated: buffer.readableBytes
                    )
                )
                continue
            }
        }
    }

    func processFrameToSend(
        _ frame: WebSocketFrame,
        context: WebSocketExtensionContext
    ) -> WebSocketFrame {
        frame
    }

    func shutdown() {}

    private func nextAllocation(
        compressedBytes: Int,
        currentlyAllocated: Int?
    ) -> Int {
        switch currentlyAllocated {
        case let .some(currentlyAllocated):
            if compressedBytes > 10 || currentlyAllocated > 60 {
                return currentlyAllocated
            } else {
                return minimumAllocation - currentlyAllocated
            }
        case .none:
            if compressedBytes > 10 {
                return max(minimumAllocation, 8 * compressedBytes)
            } else {
                /// Frames smaller than 10 bytes usually don't take more than 4.5x space
                /// after decompression.
                return compressedBytes * 5
            }
        }
    }
}
