import DiscordClientLib
import XCTest

class DiscordColorTests: XCTestCase {

    func testInitFromRGB() throws {
        let color = try XCTUnwrap(DiscordColor(red: 100, green: 67, blue: 188))
        XCTAssertEqual(color.value, 6_570_940)
        let rgb = color.asRGB()
        XCTAssertEqual(rgb.red, 100)
        XCTAssertEqual(rgb.green, 67)
        XCTAssertEqual(rgb.blue, 188)
    }

    func testInitFromHex() throws {
        let color = try XCTUnwrap(DiscordColor(hex: "#A0B9FF"))
        try XCTAssertEqual(color.value, XCTUnwrap(DiscordColor(hex: "A0B9FF")).value)
        XCTAssertEqual(color.value, 10_533_375)
        let hex = color.asHex()
        XCTAssertEqual(hex, "#A0B9FF")
    }

    func testInsensitiveHex() throws {
        try XCTAssertEqual(XCTUnwrap(DiscordColor(hex: "#FFFFFF")).value, 16_777_215)
        try XCTAssertEqual(XCTUnwrap(DiscordColor(hex: "FFFFFF")).value, 16_777_215)
        try XCTAssertEqual(XCTUnwrap(DiscordColor(hex: "#ffffff")).value, 16_777_215)
        try XCTAssertEqual(XCTUnwrap(DiscordColor(hex: "ffffff")).value, 16_777_215)
    }

    func testLowerBound() throws {
        _ = try XCTUnwrap(DiscordColor(value: 0))
        _ = try XCTUnwrap(DiscordColor(red: 0, green: 0, blue: 0))
        _ = try XCTUnwrap(DiscordColor(hex: "#000000"))
    }

    func testUpperBound() throws {
        _ = try XCTUnwrap(DiscordColor(value: 16_777_215))
        _ = try XCTUnwrap(DiscordColor(red: 255, green: 255, blue: 255))
        _ = try XCTUnwrap(DiscordColor(hex: "#FFFFFF"))
    }
}
