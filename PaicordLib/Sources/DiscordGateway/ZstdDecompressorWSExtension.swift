import SkipFuse
import NIOCore
import NIOWebSocket
import WSClient
import libzstd

private let zstdAllocator = ByteBufferAllocator()
private let minimumAllocation = 4096

/// Will be used for only 1 WS connection so won't need concurrency guards.
struct ZstdDecompressorWSExtension: WebSocketExtension, @unchecked Sendable {
  let decompressor: ZstdStreamingDecompressor
  let name = "zstd-stream-decompressor"
  let logger: Logger

  init(logger: Logger) throws {
    self.decompressor = try ZstdStreamingDecompressor(
      outBufferSize: 128  // * 1024
    )
    self.logger = logger
  }

  func processReceivedFrame(
    _ frame: WebSocketFrame,
    context: WebSocketExtensionContext
  ) throws -> WebSocketFrame {
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
    // Estimate decompressed size - typically 4x compressed size, minimum 4KB
    let initialCapacity = self.nextAllocation(
      compressedBytes: compressedBytes,
      currentlyAllocated: nil
    )
    var buffer = zstdAllocator.buffer(capacity: initialCapacity)

    var offset = 0
    while true {
      let result = try self.decompressor.decompressStreamingChunk(
        from: frame,
        into: &buffer,
        offset: offset
      )
      switch result {
      case .ok:
        return buffer
      case .continue(let newOffset):
        if buffer.writableBytes == 0 {
          buffer.reserveCapacity(
            minimumWritableBytes: self.nextAllocation(
              compressedBytes: compressedBytes,
              currentlyAllocated: buffer.readableBytes
            )
          )
        }
        offset = newOffset
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
    case .some(let currentlyAllocated):
      if compressedBytes > 10 || currentlyAllocated > 60 {
        return currentlyAllocated
      } else {
        return minimumAllocation - currentlyAllocated
      }
    case .none:
      if compressedBytes >= 800 {
        return max(minimumAllocation, 8 * compressedBytes)
      } else if compressedBytes > 10 {
        return max(minimumAllocation, 16 * compressedBytes)
      } else {
        /// Frames smaller than 10 bytes usually don't take more than 4.5x space
        /// after decompression.
        return compressedBytes * 5
      }
    }
  }
}

enum DecompressStreamingResult {
  case ok
  case `continue`(newOffset: Int)
}

enum DecompressionError: Error {
  case initializationFailed
  case incompleteFrame
  case unknownFailure(resultCode: Int)
  case decompressionError(description: String)
}

final class ZstdStreamingDecompressor {
  private let dctx: OpaquePointer

  init(outBufferSize: Int) throws {
    guard let dctx = ZSTD_createDCtx() else {
      throw DecompressionError.initializationFailed
    }
    self.dctx = dctx
  }

  deinit {
    ZSTD_freeDCtx(dctx)
  }

  func decompressStreamingChunk(
    from buffer: ByteBuffer,
    into outBuffer: inout ByteBuffer,
    offset: Int
  ) throws -> DecompressStreamingResult {
    var writtenBytes = 0
    let result: DecompressStreamingResult = try buffer.withUnsafeReadableBytes {
      srcBytes in
      try outBuffer.withUnsafeMutableWritableBytes { dstBytes in
        var input = ZSTD_inBuffer(
          src: srcBytes.baseAddress,
          size: srcBytes.count,
          pos: offset
        )
        var output = ZSTD_outBuffer(
          dst: dstBytes.baseAddress,
          size: dstBytes.count,
          pos: 0
        )

        let resultCode = ZSTD_decompressStream(dctx, &output, &input)

        writtenBytes = output.pos

        if resultCode < 0 {
          let errorName = ZSTD_getErrorName(resultCode).map {
            String(cString: $0)
          }
          let description =
            errorName ?? "Failed with error result '\(resultCode)'"
          throw DecompressionError.decompressionError(description: description)
        }

        if input.pos < input.size {
          throw DecompressionError.incompleteFrame
        }

        if output.pos < output.size {
          return .ok
        } else {
          return .continue(newOffset: input.pos)
        }
      }
    }

    outBuffer.moveWriterIndex(forwardBy: writtenBytes)

    return result
  }
}
