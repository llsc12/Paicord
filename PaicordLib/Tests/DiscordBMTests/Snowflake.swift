import XCTest

@testable import PaicordLib

class SnowflakeTests: XCTestCase {
  let messageSnowflake: MessageSnowflake = "1030118727418646629"

  func testSnowflakeParse() throws {
    XCTAssertEqual(messageSnowflake.description, #"Snowflake<Message>("1030118727418646629")"#)

    let snowflakeInfo = try XCTUnwrap(messageSnowflake.parse())

    XCTAssertEqual(snowflakeInfo.timestamp, 1_665_669_843_297)
    XCTAssertEqual(snowflakeInfo.workerId, 2)
    XCTAssertEqual(snowflakeInfo.processId, 1)
    XCTAssertEqual(snowflakeInfo.sequenceNumber, 101)
    XCTAssertEqual(snowflakeInfo.date.description, "2022-10-13 14:04:03 +0000")

    let snowflake = AnySnowflake(info: snowflakeInfo)
    XCTAssertTrue(
      snowflake == messageSnowflake, "\(snowflake) was not equal to \(messageSnowflake)")
  }

  func testInitializers() throws {
    let parsedSnowflakeInfo = try XCTUnwrap(messageSnowflake.parse())

    let snowflakeInfoWithTimestamp = try SnowflakeInfo(
      timestamp: parsedSnowflakeInfo.timestamp,
      workerId: parsedSnowflakeInfo.workerId,
      processId: parsedSnowflakeInfo.processId,
      sequenceNumber: parsedSnowflakeInfo.sequenceNumber
    )

    XCTAssertEqual(parsedSnowflakeInfo.timestamp, snowflakeInfoWithTimestamp.timestamp)
    XCTAssertEqual(parsedSnowflakeInfo.workerId, snowflakeInfoWithTimestamp.workerId)
    XCTAssertEqual(parsedSnowflakeInfo.processId, snowflakeInfoWithTimestamp.processId)
    XCTAssertEqual(parsedSnowflakeInfo.sequenceNumber, snowflakeInfoWithTimestamp.sequenceNumber)

    let snowflakeInfoWithDate = try SnowflakeInfo(
      date: parsedSnowflakeInfo.date,
      workerId: parsedSnowflakeInfo.workerId,
      processId: parsedSnowflakeInfo.processId,
      sequenceNumber: parsedSnowflakeInfo.sequenceNumber
    )

    XCTAssertEqual(parsedSnowflakeInfo.timestamp, snowflakeInfoWithDate.timestamp)
    XCTAssertEqual(parsedSnowflakeInfo.workerId, snowflakeInfoWithDate.workerId)
    XCTAssertEqual(parsedSnowflakeInfo.processId, snowflakeInfoWithDate.processId)
    XCTAssertEqual(parsedSnowflakeInfo.sequenceNumber, snowflakeInfoWithDate.sequenceNumber)
  }

  func testDecodesNumericSnowflake() throws {
    let snowflake = try JSONDecoder().decode(
      ApplicationSnowflake.self,
      from: Data("1030118727418646629".utf8)
    )

    XCTAssertEqual(snowflake.rawValue, "1030118727418646629")
  }

  func testMakeFake() throws {
    _ = try AnySnowflake.makeFake(date: Date())
    _ = try AnySnowflake.makeFake(date: Date(timeIntervalSince1970: 1_420_070_400))
    _ = try AnySnowflake.makeFake(date: Date(timeIntervalSince1970: 4_398_046_511))

    XCTAssertThrowsError(try AnySnowflake.makeFake(date: Date.distantPast)) { error in
      let error = error as! SnowflakeInfo.Error
      switch error {
      case .fieldTooSmall("date", value: "-62135769600000.0", min: 1_420_070_400_000): break
      default:
        XCTFail("Unexpected SnowflakeInfo.Error: \(error)")
      }
    }

    XCTAssertThrowsError(try AnySnowflake.makeFake(date: Date.distantFuture)) { error in
      let error = error as! SnowflakeInfo.Error
      switch error {
      case .fieldTooBig("date", value: "64092211200000.0", max: 5_818_116_911_103): break
      default:
        XCTFail("Unexpected SnowflakeInfo.Error: \(error)")
      }
    }
  }

  func testEdgeCases() throws {
    XCTAssertThrowsError(
      try SnowflakeInfo(
        timestamp: .max,
        workerId: 0,
        processId: 0,
        sequenceNumber: 0
      )
    ) { error in
      let error = error as! SnowflakeInfo.Error
      switch error {
      case .fieldTooBig("timestamp", value: "18446744073709551615", max: 5_818_116_911_103): break
      default:
        XCTFail("Unexpected SnowflakeInfo.Error: \(error)")
      }
    }

    XCTAssertThrowsError(
      try SnowflakeInfo(
        timestamp: SnowflakeInfo.discordEpochConstant,
        workerId: .max,
        processId: 0,
        sequenceNumber: 0
      )
    ) { error in
      let error = error as! SnowflakeInfo.Error
      switch error {
      case .fieldTooBig("workerId", value: "255", max: 31): break
      default:
        XCTFail("Unexpected SnowflakeInfo.Error: \(error)")
      }
    }

    XCTAssertThrowsError(
      try SnowflakeInfo(
        timestamp: SnowflakeInfo.discordEpochConstant,
        workerId: 0,
        processId: .max,
        sequenceNumber: 0
      )
    ) { error in
      let error = error as! SnowflakeInfo.Error
      switch error {
      case .fieldTooBig("processId", value: "255", max: 31): break
      default:
        XCTFail("Unexpected SnowflakeInfo.Error: \(error)")
      }
    }

    XCTAssertThrowsError(
      try SnowflakeInfo(
        timestamp: SnowflakeInfo.discordEpochConstant,
        workerId: 0,
        processId: 0,
        sequenceNumber: .max
      )
    ) { error in
      let error = error as! SnowflakeInfo.Error
      switch error {
      case .fieldTooBig("sequenceNumber", value: "65535", max: 4095): break
      default:
        XCTFail("Unexpected SnowflakeInfo.Error: \(error)")
      }
    }

    XCTAssertThrowsError(
      try SnowflakeInfo(timestamp: .min, workerId: 0, processId: 0, sequenceNumber: 0)
    )

    _ = try SnowflakeInfo(
      timestamp: SnowflakeInfo.discordEpochConstant,
      workerId: .min,
      processId: 0,
      sequenceNumber: 0
    )

    _ = try SnowflakeInfo(
      timestamp: SnowflakeInfo.discordEpochConstant,
      workerId: 0,
      processId: .min,
      sequenceNumber: 0
    )

    _ = try SnowflakeInfo(
      timestamp: SnowflakeInfo.discordEpochConstant,
      workerId: 0,
      processId: 0,
      sequenceNumber: .min
    )
  }

  func testMemberListIDSnowflakes() throws {
    let memberListSnowflake: MemberListSnowflake = .init("3991716185")
    let everyoneListSnowflake: MemberListSnowflake = .init("everyone")
    print(memberListSnowflake, everyoneListSnowflake)
  }

  func testMurmurHash() {
    let testString = "Hello, World!"
    let hash = murmurhash32(key: testString)
    print("\(testString) -> \(hash)")
    XCTAssertEqual(hash, 592_631_239)
  }
}
