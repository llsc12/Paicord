import Logging
import NIOCore
import NIOWebSocket
import XCTest

@testable import DiscordGateway
@testable import WSCore

class DecompressionTests: XCTestCase {
    let logger = Logger(label: "TestDecompression")

    func testDeflateDecompression() throws {
        let decompressor = try ZlibDecompressorWSExtension(logger: logger)

        for (data, decodedString) in zip(deflatedData, deflatedDataDecodedStrings) {
            let frame = WebSocketFrame(fin: true, data: ByteBuffer(data: data))
            let decodedFrame = try decompressor.processReceivedFrame(
                frame,
                context: .init(logger: logger)
            )

            XCTAssertEqual(String(buffer: decodedFrame.data).count, decodedString.count)
        }
    }
}

let deflatedData: [Data] = [
    Data([
        120, 156, 52, 201, 77, 10, 131, 48, 16, 6, 208, 187, 124, 235, 164, 36, 253, 91, 204, 85, 140, 200, 24, 7, 43,
        164, 42, 201, 216, 82, 66, 238, 222, 110, 186, 123, 240, 42, 20, 180, 30, 41, 25, 148, 63, 182, 29, 228, 157,
        193, 4, 170, 120, 8, 103, 29, 133, 117, 88, 86, 149, 252, 226, 4, 186, 250, 243, 237, 247, 131, 102, 142, 2,
        234, 208, 5, 204, 172, 242, 230, 143, 221, 243, 100, 143, 98, 133, 139, 122, 27, 237, 229, 62, 206, 1, 166, 6,
        60, 151, 152, 183, 18, 64, 238, 228, 90, 143, 190, 181, 47, 0, 0, 0, 255, 255,
    ]),
    Data([
        156, 85, 77, 111, 156, 48, 16, 253, 47, 156, 179, 13, 54, 224, 181, 123, 107, 149, 222, 218, 75, 213, 75, 213,
        70, 150, 129, 97, 215, 141, 49, 212, 54, 169, 146, 104, 255, 123, 199, 124, 52, 93, 200, 42, 85, 181, 210, 10,
        204, 155, 153, 55, 111, 222, 192, 83, 172, 157, 124, 254, 240, 238, 230, 107, 50, 150, 39, 83, 237, 165, 244,
        253, 68, 99, 240, 224, 164, 135, 16, 180, 61, 32, 232, 233, 52, 29, 141, 8, 112, 186, 209, 128, 232, 224, 6,
        152, 206, 173, 106, 145, 83, 114, 163, 253, 251, 79, 31, 117, 249, 5, 124, 120, 223, 5, 44, 208, 54, 74, 130,
        85, 165, 121, 198, 107, 188, 74, 72, 154, 165, 132, 240, 61, 221, 231, 132, 179, 156, 49, 42, 16, 221, 24, 21,
        171, 97, 125, 104, 149, 54, 139, 54, 181, 246, 149, 211, 173, 182, 42, 116, 72, 33, 73, 57, 35, 136, 46, 177,
        194, 156, 83, 221, 171, 160, 220, 132, 71, 170, 30, 188, 215, 157, 149, 225, 161, 143, 180, 108, 231, 90, 148,
        240, 249, 124, 164, 80, 54, 28, 74, 206, 33, 23, 153, 128, 130, 214, 77, 42, 50, 202, 72, 147, 169, 178, 172,
        88, 198, 17, 239, 192, 15, 45, 200, 89, 102, 57, 56, 164, 148, 252, 242, 254, 237, 245, 245, 34, 253, 179, 236,
        111, 34, 205, 206, 213, 111, 14, 135, 49, 212, 168, 128, 181, 252, 81, 247, 216, 210, 183, 219, 171, 164, 119,
        26, 105, 130, 172, 142, 202, 90, 48, 127, 78, 193, 131, 173, 96, 190, 61, 12, 218, 212, 241, 250, 41, 25, 44,
        182, 165, 77, 20, 239, 76, 59, 193, 246, 69, 154, 226, 63, 45, 246, 130, 113, 198, 211, 228, 116, 117, 25, 142,
        82, 51, 206, 137, 40, 82, 38, 24, 229, 156, 238, 247, 201, 105, 169, 36, 127, 116, 218, 74, 7, 63, 7, 28, 217,
        66, 1, 58, 137, 125, 128, 131, 90, 186, 80, 225, 211, 67, 108, 36, 122, 174, 197, 252, 54, 118, 215, 5, 244,
        101, 173, 218, 56, 98, 85, 59, 44, 132, 243, 24, 176, 51, 236, 38, 206, 221, 135, 174, 186, 59, 118, 166, 77,
        48, 161, 234, 123, 163, 171, 81, 142, 104, 160, 215, 13, 80, 176, 130, 230, 252, 244, 223, 110, 23, 44, 43, 178,
        171, 239, 73, 165, 140, 137, 247, 24, 172, 107, 89, 57, 220, 40, 168, 87, 88, 146, 114, 241, 55, 244, 246, 132,
        119, 139, 81, 76, 215, 221, 13, 189, 12, 186, 133, 85, 24, 229, 249, 107, 81, 141, 182, 218, 31, 183, 5, 249,
        38, 112, 118, 206, 110, 78, 224, 119, 165, 25, 96, 236, 147, 238, 8, 97, 235, 238, 114, 28, 250, 121, 119, 30,
        221, 31, 228, 28, 190, 130, 231, 140, 166, 244, 28, 190, 212, 83, 189, 222, 137, 166, 44, 27, 209, 176, 124,
        231, 31, 91, 42, 214, 193, 132, 103, 252, 60, 248, 0, 65, 198, 157, 95, 33, 121, 193, 105, 236, 37, 62, 158, 76,
        188, 2, 20, 148, 138, 73, 37, 91, 75, 95, 161, 48, 3, 190, 21, 100, 13, 6, 162, 51, 100, 139, 236, 213, 97, 173,
        51, 201, 198, 164, 91, 175, 174, 231, 17, 97, 106, 8, 199, 206, 233, 71, 76, 171, 123, 137, 45, 118, 235, 108,
        249, 233, 246, 52, 205, 42, 42, 134, 47, 183, 137, 43, 98, 113, 37, 171, 176, 78, 74, 139, 205, 172, 150, 125,
        149, 99, 134, 205, 116, 115, 70, 178, 253, 38, 104, 18, 228, 66, 8, 201, 182, 6, 156, 3, 94, 166, 69, 46, 147,
        186, 16, 128, 203, 191, 137, 153, 161, 23, 109, 42, 138, 109, 243, 229, 40, 22, 238, 81, 253, 240, 186, 171,
        187, 30, 247, 6, 135, 241, 34, 126, 203, 199, 227, 75, 34, 252, 35, 182, 50, 160, 236, 203, 60, 206, 177, 227,
        47, 126, 247, 126, 3, 0, 0, 255, 255,
    ]),
    Data([
        188, 91, 93, 111, 219, 70, 22, 253, 43, 134, 94, 23, 14, 230, 123, 56, 122, 218, 198, 113, 221, 5, 106, 236,
        182, 113, 90, 236, 67, 33, 140, 68, 202, 226, 134, 34, 85, 138, 178, 227, 20, 249, 239, 123, 46, 63, 68, 43,
        145, 52, 110, 144, 201, 67, 28, 67, 20, 201, 51, 119, 238, 61, 247, 92, 242, 184, 235, 123, 55, 239, 254, 245,
        243, 155, 217, 21, 218, 223, 221, 117, 215, 254, 196, 97, 251, 163, 126, 85, 100, 15, 89, 209, 126, 84, 110,
        151, 143, 147, 233, 210, 23, 91, 144, 233, 67, 149, 119, 187, 222, 12, 92, 221, 17, 35, 46, 155, 102, 216, 128,
        5, 145, 203, 164, 37, 244, 117, 190, 91, 131, 52, 168, 95, 182, 189, 172, 250, 95, 222, 81, 58, 122, 231, 182,
        61, 133, 17, 135, 22, 227, 133, 254, 220, 229, 53, 237, 94, 209, 18, 109, 199, 222, 125, 83, 253, 101, 151, 101,
        101, 203, 179, 37, 202, 35, 221, 227, 25, 122, 129, 77, 156, 100, 138, 97, 139, 45, 186, 150, 152, 180, 221,
        240, 176, 15, 248, 50, 95, 183, 232, 186, 115, 169, 91, 124, 13, 146, 31, 106, 84, 109, 189, 13, 96, 17, 86, 42,
        197, 172, 2, 183, 71, 197, 82, 87, 143, 33, 40, 202, 9, 110, 165, 99, 134, 197, 132, 242, 218, 207, 159, 222, 4,
        144, 128, 177, 185, 97, 212, 130, 93, 68, 36, 63, 87, 85, 32, 83, 148, 2, 61, 161, 35, 128, 172, 227, 134, 164,
        76, 243, 38, 0, 69, 39, 70, 42, 193, 32, 1, 226, 66, 169, 231, 248, 7, 61, 22, 128, 147, 48, 225, 164, 54, 137,
        142, 14, 231, 167, 93, 32, 52, 154, 9, 173, 148, 212, 90, 186, 36, 50, 150, 64, 9, 105, 129, 124, 17, 218, 65,
        171, 177, 168, 72, 154, 0, 16, 103, 37, 115, 142, 227, 71, 84, 32, 63, 101, 190, 0, 109, 159, 135, 226, 64, 110,
        204, 72, 1, 102, 137, 27, 147, 166, 200, 126, 237, 53, 246, 9, 52, 142, 49, 161, 140, 178, 92, 89, 173, 163,
        162, 169, 214, 243, 187, 234, 241, 124, 108, 128, 70, 105, 158, 8, 252, 176, 58, 106, 21, 1, 77, 16, 138, 101,
        138, 107, 105, 20, 55, 38, 42, 148, 199, 64, 198, 0, 138, 179, 206, 114, 103, 12, 99, 58, 34, 148, 43, 204, 149,
        85, 121, 5, 141, 121, 30, 14, 70, 10, 48, 140, 76, 148, 141, 218, 23, 59, 56, 1, 40, 24, 185, 53, 18, 24, 29,
        50, 102, 100, 22, 248, 44, 11, 32, 209, 10, 52, 151, 88, 109, 77, 204, 22, 157, 250, 250, 253, 166, 206, 161,
        213, 3, 112, 172, 4, 249, 115, 153, 36, 81, 73, 6, 112, 154, 251, 106, 94, 228, 161, 125, 34, 121, 153, 168, 68,
        49, 22, 179, 35, 209, 115, 175, 213, 159, 59, 255, 62, 16, 29, 116, 37, 166, 57, 51, 74, 58, 30, 19, 78, 129, 1,
        169, 174, 210, 218, 223, 135, 18, 25, 195, 45, 244, 157, 115, 12, 138, 38, 34, 162, 235, 155, 220, 151, 129,
        242, 22, 90, 90, 11, 241, 96, 173, 137, 10, 229, 237, 38, 175, 207, 139, 60, 96, 73, 172, 18, 74, 105, 101, 141,
        141, 137, 229, 247, 252, 227, 121, 32, 146, 65, 241, 82, 246, 10, 21, 147, 243, 174, 131, 154, 10, 80, 132, 106,
        165, 21, 170, 41, 42, 253, 86, 5, 165, 111, 21, 232, 77, 82, 161, 31, 72, 201, 173, 19, 49, 43, 251, 250, 6, 95,
        12, 72, 25, 169, 173, 230, 244, 116, 19, 115, 91, 76, 40, 31, 2, 236, 34, 193, 189, 137, 161, 71, 147, 70, 69,
        196, 241, 35, 142, 188, 164, 134, 176, 65, 152, 146, 180, 1, 197, 196, 172, 103, 130, 51, 247, 197, 217, 49,
        169, 165, 55, 5, 229, 64, 19, 74, 76, 85, 69, 96, 22, 181, 95, 188, 15, 73, 43, 101, 180, 3, 20, 195, 226, 10,
        206, 31, 233, 17, 89, 189, 246, 129, 46, 128, 146, 150, 9, 218, 64, 34, 121, 84, 52, 197, 211, 173, 95, 172,
        242, 144, 166, 209, 160, 61, 145, 40, 3, 249, 25, 53, 115, 234, 44, 251, 24, 130, 34, 48, 51, 113, 206, 21, 143,
        27, 153, 93, 93, 250, 144, 182, 210, 74, 24, 135, 94, 96, 208, 156, 34, 98, 185, 121, 27, 128, 97, 48, 88, 83,
        174, 0, 74, 68, 24, 111, 203, 234, 49, 92, 215, 244, 48, 134, 51, 109, 19, 33, 99, 214, 245, 11, 228, 11, 74,
        153, 37, 202, 1, 9, 139, 138, 164, 122, 193, 99, 33, 160, 145, 204, 104, 97, 45, 198, 37, 25, 23, 205, 21, 32,
        4, 176, 88, 170, 102, 8, 42, 19, 117, 162, 125, 83, 231, 129, 108, 193, 212, 230, 148, 99, 14, 83, 129, 136, 90,
        65, 213, 252, 198, 151, 247, 1, 44, 96, 57, 141, 134, 45, 161, 50, 35, 99, 9, 38, 47, 61, 92, 181, 24, 218, 156,
        136, 76, 45, 85, 232, 33, 162, 227, 74, 75, 7, 154, 51, 152, 6, 34, 215, 17, 166, 199, 243, 146, 151, 43, 75, 2,
        83, 26, 167, 117, 220, 42, 42, 210, 172, 124, 93, 61, 5, 208, 56, 97, 185, 16, 152, 29, 101, 220, 77, 10, 41,
        94, 174, 153, 131, 94, 80, 204, 74, 21, 117, 143, 254, 27, 128, 33, 32, 88, 164, 114, 32, 221, 23, 141, 211,
        127, 208, 11, 254, 156, 196, 89, 127, 247, 117, 70, 207, 227, 122, 219, 66, 239, 19, 121, 230, 11, 185, 245,
        171, 52, 191, 120, 125, 75, 111, 199, 118, 72, 151, 197, 172, 127, 209, 175, 184, 83, 146, 169, 30, 140, 32, 1,
        133, 108, 229, 26, 154, 78, 209, 243, 187, 201, 17, 243, 135, 230, 118, 48, 127, 244, 43, 25, 220, 31, 19, 50,
        113, 120, 198, 93, 146, 49, 54, 247, 66, 206, 151, 34, 93, 88, 145, 44, 84, 58, 119, 42, 117, 147, 79, 7, 49,
        27, 222, 212, 109, 219, 199, 49, 189, 217, 100, 147, 149, 105, 14, 206, 25, 46, 94, 98, 157, 195, 177, 245, 174,
        201, 246, 7, 232, 109, 116, 150, 206, 60, 189, 87, 20, 152, 255, 47, 153, 186, 20, 242, 142, 187, 41, 147, 83,
        161, 95, 33, 201, 24, 99, 255, 96, 108, 218, 182, 247, 209, 219, 146, 102, 126, 185, 191, 202, 162, 90, 175,
        119, 101, 239, 142, 152, 97, 177, 173, 87, 102, 182, 43, 155, 209, 255, 114, 232, 110, 57, 26, 225, 95, 171, 39,
        95, 100, 23, 63, 20, 139, 21, 214, 212, 90, 48, 14, 35, 205, 246, 27, 206, 209, 96, 33, 195, 104, 202, 17, 6,
        115, 206, 145, 24, 107, 163, 147, 227, 6, 155, 201, 130, 47, 156, 97, 203, 84, 75, 159, 241, 68, 167, 204, 42,
        238, 93, 202, 209, 16, 192, 55, 243, 249, 119, 10, 177, 96, 83, 174, 94, 105, 253, 29, 67, 220, 37, 241, 237,
        237, 145, 52, 30, 131, 107, 36, 233, 5, 122, 207, 135, 73, 64, 105, 123, 36, 184, 40, 122, 117, 34, 129, 123,
        251, 82, 196, 248, 37, 151, 92, 222, 49, 55, 229, 114, 202, 196, 171, 4, 154, 252, 187, 197, 239, 75, 115, 216,
        241, 32, 30, 119, 6, 253, 109, 15, 88, 188, 32, 114, 70, 65, 228, 106, 42, 245, 84, 177, 87, 150, 70, 137, 111,
        31, 68, 224, 206, 62, 144, 111, 42, 111, 200, 213, 209, 100, 37, 89, 53, 138, 166, 55, 21, 172, 253, 135, 217,
        67, 158, 102, 213, 96, 39, 107, 61, 57, 100, 104, 208, 136, 10, 125, 82, 239, 61, 134, 155, 194, 111, 87, 251,
        155, 140, 102, 172, 214, 7, 215, 125, 74, 78, 135, 103, 198, 135, 194, 215, 247, 99, 4, 158, 159, 66, 235, 240,
        37, 25, 102, 0, 157, 156, 129, 19, 222, 218, 106, 176, 194, 209, 214, 118, 216, 165, 58, 23, 30, 72, 126, 83,
        109, 243, 102, 248, 116, 131, 113, 58, 239, 252, 82, 21, 190, 253, 88, 231, 123, 95, 69, 159, 48, 119, 217, 135,
        230, 226, 106, 184, 234, 231, 230, 55, 103, 57, 212, 176, 107, 159, 20, 13, 49, 255, 188, 63, 126, 237, 157,
        127, 35, 171, 71, 248, 214, 50, 120, 107, 250, 165, 218, 228, 139, 33, 204, 53, 249, 255, 10, 164, 113, 51, 3,
        138, 89, 87, 37, 236, 229, 248, 54, 190, 166, 60, 56, 29, 137, 126, 1, 247, 25, 246, 191, 181, 60, 98, 235, 155,
        193, 90, 53, 27, 235, 11, 35, 68, 130, 185, 6, 39, 105, 217, 190, 4, 58, 126, 73, 117, 102, 133, 173, 69, 180,
        93, 203, 179, 5, 11, 172, 113, 111, 25, 252, 46, 171, 150, 227, 170, 111, 78, 175, 186, 3, 114, 252, 10, 250,
        160, 106, 231, 121, 67, 120, 39, 83, 67, 101, 253, 173, 182, 149, 127, 147, 109, 133, 10, 187, 207, 182, 39,
        118, 21, 194, 8, 67, 60, 13, 172, 232, 63, 78, 181, 130, 242, 249, 33, 173, 141, 224, 164, 123, 33, 76, 78, 109,
        43, 55, 70, 27, 203, 173, 118, 206, 37, 95, 191, 90, 241, 77, 86, 91, 228, 243, 75, 156, 212, 92, 246, 204, 114,
        42, 155, 201, 221, 42, 104, 204, 17, 60, 65, 203, 125, 182, 238, 54, 209, 45, 166, 101, 137, 102, 34, 156, 57,
        224, 138, 63, 136, 161, 151, 126, 87, 140, 87, 44, 171, 38, 95, 246, 76, 215, 101, 131, 95, 190, 111, 221, 159,
        21, 166, 173, 169, 100, 108, 108, 38, 155, 186, 186, 175, 113, 222, 108, 238, 235, 209, 226, 220, 51, 38, 177,
        243, 182, 161, 75, 30, 229, 104, 70, 250, 185, 93, 66, 137, 255, 71, 243, 239, 41, 123, 111, 119, 193, 189, 200,
        198, 97, 70, 80, 86, 187, 121, 111, 113, 238, 91, 218, 161, 149, 248, 111, 54, 46, 156, 189, 204, 106, 50, 253,
        22, 213, 194, 23, 237, 251, 175, 242, 242, 29, 61, 196, 202, 23, 99, 49, 55, 43, 178, 221, 245, 183, 32, 68,
        105, 74, 55, 89, 52, 249, 3, 118, 127, 184, 119, 135, 181, 235, 18, 29, 3, 15, 61, 120, 55, 167, 70, 190, 233,
        155, 73, 123, 152, 237, 165, 192, 110, 147, 146, 189, 110, 31, 175, 177, 116, 211, 108, 127, 218, 240, 81, 225,
        63, 62, 13, 205, 191, 115, 113, 142, 174, 82, 116, 178, 114, 240, 51, 87, 143, 160, 133, 217, 233, 9, 227, 192,
        56, 221, 111, 224, 160, 30, 62, 163, 60, 52, 240, 42, 205, 102, 173, 163, 111, 31, 16, 63, 56, 228, 79, 240,
        217, 182, 205, 69, 203, 161, 9, 141, 97, 174, 149, 51, 125, 138, 255, 19, 56, 235, 167, 254, 221, 52, 16, 227,
        219, 7, 48, 78, 205, 108, 95, 38, 200, 243, 45, 90, 85, 52, 1, 12, 231, 140, 212, 70, 179, 97, 221, 167, 126,
        23, 176, 21, 132, 65, 182, 237, 93, 253, 219, 129, 169, 250, 197, 255, 53, 169, 80, 227, 205, 179, 219, 175, 90,
        29, 49, 249, 247, 245, 218, 166, 191, 144, 210, 95, 103, 141, 199, 142, 249, 51, 95, 94, 220, 253, 39, 173, 30,
        39, 7, 2, 225, 228, 151, 229, 253, 245, 59, 137, 47, 127, 234, 42, 239, 203, 52, 232, 254, 248, 160, 215, 34,
        163, 94, 121, 192, 132, 218, 180, 6, 253, 25, 109, 208, 94, 213, 244, 47, 124, 104, 187, 46, 222, 102, 53, 206,
        190, 224, 189, 152, 36, 86, 122, 154, 29, 106, 163, 237, 211, 182, 201, 214, 251, 219, 142, 145, 251, 236, 192,
        233, 102, 89, 35, 251, 142, 165, 239, 50, 243, 205, 174, 238, 170, 227, 211, 167, 255, 3, 0, 0, 255, 255,
    ]),
]

let deflatedDataDecodedStrings: [String] = [
    #"{"t":null,"s":null,"op":10,"d":{"heartbeat_interval":41250,"_trace":["[\"gateway-prd-us-east1-c-36bg\",{\"micros\":0.0}]"]}}"#,
    #"{"t":"READY","s":1,"op":0,"d":{"v":10,"user_settings":{},"user":{"verified":true,"username":"DisBMLibTestBot","mfa_enabled":true,"id":"1030118727418646629","flags":0,"email":null,"discriminator":"0861","bot":true,"avatar":null},"session_type":"normal","session_id":"bf8eb88e4939e52df093261f3abbc638","resume_gateway_url":"wss://gateway-us-east1-c.discord.gg","relationships":[],"private_channels":[],"presences":[],"guilds":[{"unavailable":true,"id":"967500967257968680"},{"unavailable":true,"id":"1036881950696288277"}],"guild_join_requests":[],"geo_ordered_rtc_regions":["milan","rotterdam","madrid","bucharest","stockholm"],"application":{"id":"1030118727418646629","flags":565248},"_trace":["[\"gateway-prd-us-east1-c-36bg\",{\"micros\":96353,\"calls\":[\"id_created\",{\"micros\":1089,\"calls\":[]},\"session_lookup_time\",{\"micros\":284,\"calls\":[]},\"session_lookup_finished\",{\"micros\":18,\"calls\":[]},\"discord-sessions-blue-prd-2-116\",{\"micros\":94686,\"calls\":[\"start_session\",{\"micros\":46202,\"calls\":[\"discord-api-9fbbf9f64-szm29\",{\"micros\":41838,\"calls\":[\"get_user\",{\"micros\":8582},\"get_guilds\",{\"micros\":5229},\"send_scheduled_deletion_message\",{\"micros\":13},\"guild_join_requests\",{\"micros\":2},\"authorized_ip_coro\",{\"micros\":14}]}]},\"starting_guild_connect\",{\"micros\":225,\"calls\":[]},\"presence_started\",{\"micros\":46137,\"calls\":[]},\"guilds_started\",{\"micros\":139,\"calls\":[]},\"guilds_connect\",{\"micros\":1,\"calls\":[]},\"presence_connect\",{\"micros\":1950,\"calls\":[]},\"connect_finished\",{\"micros\":1955,\"calls\":[]},\"build_ready\",{\"micros\":18,\"calls\":[]},\"optimize_ready\",{\"micros\":0,\"calls\":[]},\"split_ready\",{\"micros\":0,\"calls\":[]},\"clean_ready\",{\"micros\":1,\"calls\":[]}]}]}]"]}}"#,
    #"{"t":"GUILD_CREATE","s":2,"op":0,"d":{"mfa_level":0,"nsfw":false,"voice_states":[],"region":"deprecated","premium_tier":0,"emojis":[{"version":0,"roles":[],"require_colons":true,"name":"Queen","managed":false,"id":"967789304095076382","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Archers","managed":false,"id":"967789327344074872","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Arrows","managed":false,"id":"967789349217390602","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"BabyD","managed":false,"id":"967789368616050699","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Loon","managed":false,"id":"967789441374625822","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Bandit","managed":false,"id":"967789458634207272","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"BarbBarrel","managed":false,"id":"967789480293568572","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"BarbHut","managed":false,"id":"967789502544355398","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Barbs","managed":false,"id":"967789521372590110","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Bats","managed":false,"id":"967789973099130910","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Healer","managed":false,"id":"967789997480632390","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"BattleRam","managed":false,"id":"967790024647147550","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"BombTower","managed":false,"id":"967790045182451752","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Bomber","managed":false,"id":"967790070415364166","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Bowler","managed":false,"id":"967790097971966005","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"CannonCart","managed":false,"id":"967790116502384702","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Cannon","managed":false,"id":"967790132654649365","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"clone","managed":false,"id":"967790154590875769","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"darkprince","managed":false,"id":"967790173398138890","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"dartgoblin","managed":false,"id":"967790195078484008","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"earthquake","managed":false,"id":"967790213051064391","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"electrodragon","managed":false,"id":"967790229605990420","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"EGiant","managed":false,"id":"967790253773557760","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"ESpirit","managed":false,"id":"967790287424454767","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"EWiz","managed":false,"id":"967790308224008242","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"EBarbs","managed":false,"id":"967790324778954842","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Collector","managed":false,"id":"967790340113317928","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"EGolem","managed":false,"id":"967790357519675492","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Exe","managed":false,"id":"967790373386727464","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"FireSpirit","managed":false,"id":"967790401207562290","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Fireball","managed":false,"id":"967790420438450256","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Firecracker","managed":false,"id":"967790465925660752","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Fisherman","managed":false,"id":"967790484380598312","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"FlyMachine","managed":false,"id":"967790503028469790","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Freeze","managed":false,"id":"967790524801114112","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Furnace","managed":false,"id":"967790542694006874","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"GS","managed":false,"id":"967790562595983400","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Snowball","managed":false,"id":"967790586310578236","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Giant","managed":false,"id":"967790607084978206","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"GobBarrel","managed":false,"id":"967790630652772383","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"GobCage","managed":false,"id":"967790670284742666","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Drill","managed":false,"id":"967791329490919524","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"GobGang","managed":false,"id":"967791350353383454","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"GobGiant","managed":false,"id":"967791374713892874","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"GobHut","managed":false,"id":"967791453969465376","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Goblins","managed":false,"id":"967791473179369553","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"GoldenBoy","managed":false,"id":"967791492712239134","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"Golem","managed":false,"id":"967791509380407346","available":true,"animated":false},{"version":0,"roles":[],"require_colons":true,"name":"GY","managed":false,"id":"967791528313499781","available":true,"animated":false}],"stickers":[],"members":[{"user":{"username":"Mahdi BM","public_flags":4194304,"id":"290483761559240704","discriminator":"0517","bot":false,"avatar":"2df0a0198e00ba23bf2dc728c4db94d9"},"roles":[],"premium_since":null,"pending":false,"nick":null,"mute":false,"joined_at":"2022-04-23T19:03:25.927000+00:00","flags":0,"deaf":false,"communication_disabled_until":null,"avatar":null},{"user":{"username":"Royale Alchemist","public_flags":0,"id":"961607141037326386","discriminator":"5658","bot":true,"avatar":"c1c960fd53ae185d0741a9d1294539bb"},"roles":[],"premium_since":null,"pending":false,"nick":null,"mute":false,"joined_at":"2022-04-23T19:20:14.557000+00:00","flags":0,"deaf":false,"communication_disabled_until":null,"avatar":null},{"user":{"username":"Mahdi MMBM","public_flags":0,"id":"966330655069843457","discriminator":"1504","bot":false,"avatar":null},"roles":[],"premium_since":null,"pending":false,"nick":null,"mute":false,"joined_at":"2022-08-13T09:13:02.848000+00:00","flags":0,"deaf":false,"communication_disabled_until":null,"avatar":null},{"user":{"username":"DisBMLibTestBot","public_flags":0,"id":"1030118727418646629","discriminator":"0861","bot":true,"avatar":null},"roles":[],"premium_since":null,"pending":false,"nick":null,"mute":false,"joined_at":"2022-10-13T14:35:40.794000+00:00","flags":0,"deaf":false,"communication_disabled_until":null,"avatar":null}],"explicit_content_filter":0,"max_video_channel_users":25,"banner":null,"splash":null,"application_id":null,"nsfw_level":0,"large":false,"application_command_counts":{"1":14},"channels":[{"version":0,"type":4,"position":0,"permission_overwrites":[],"name":"Text Channels","id":"967500967971028992","flags":0},{"version":0,"type":4,"position":0,"permission_overwrites":[],"name":"Voice Channels","id":"967500967971028993","flags":0},{"version":0,"type":0,"topic":null,"rate_limit_per_user":0,"position":0,"permission_overwrites":[],"parent_id":"967500967971028992","name":"general","last_message_id":"1030126686529925302","id":"967500967971028994","flags":0},{"version":0,"user_limit":0,"type":2,"rtc_region":null,"rate_limit_per_user":0,"position":0,"permission_overwrites":[],"parent_id":"967500967971028993","name":"General","last_message_id":null,"id":"967500967971028995","flags":0,"bitrate":64000},{"version":0,"type":0,"topic":null,"rate_limit_per_user":0,"position":1,"permission_overwrites":[],"parent_id":"967500967971028992","name":"images","last_message_id":"1005158606305509446","id":"1005158556217122927","flags":0},{"version":1665671759998,"type":0,"topic":null,"rate_limit_per_user":0,"position":2,"permission_overwrites":[],"parent_id":"967500967971028992","name":"lib-test-channel","last_message_id":"1036881265372184576","id":"1030126766632742962","flags":0}],"default_message_notifications":0,"afk_timeout":300,"premium_progress_bar_enabled":false,"max_stage_video_channel_users":0,"stage_instances":[],"id":"967500967257968680","max_members":500000,"hub_type":null,"presences":[],"joined_at":"2022-10-13T14:35:40.794000+00:00","preferred_locale":"en-US","icon":null,"threads":[],"embedded_activities":[],"member_count":4,"premium_subscription_count":0,"public_updates_channel_id":null,"description":null,"lazy":true,"guild_scheduled_events":[],"owner_id":"290483761559240704","unavailable":false,"roles":[{"version":0,"unicode_emoji":null,"tags":{},"position":0,"permissions":"1071698660929","name":"@everyone","mentionable":false,"managed":false,"id":"967500967257968680","icon":null,"hoist":false,"flags":0,"color":0}],"guild_hashes":{"version":1,"roles":{"omitted":false,"hash":"OEm7dQ"},"metadata":{"omitted":false,"hash":"cTPdow"},"channels":{"omitted":false,"hash":"3gEU3w"}},"afk_channel_id":null,"verification_level":0,"vanity_url_code":null,"name":"Emoji Server 1","discovery_splash":null,"system_channel_flags":0,"system_channel_id":"967500967971028994","rules_channel_id":null,"features":[]}}"#,
]
